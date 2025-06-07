import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:gym_management_flutter/features/member/presentation/providers/member_workout_provider.dart';

// Color constants reused
const DeepBlue = Color(0xFF0000CD);
const LightBlue = Color(0xFFE6E9FD);

// WorkoutCard Widget for Member
class MemberWorkoutCard extends StatelessWidget {
  final WorkoutResponse workout;
  final ValueChanged<bool> onToggleComplete;

  const MemberWorkoutCard({
    Key? key,
    required this.workout,
    required this.onToggleComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (workout.imageUri != null && workout.imageUri!.isNotEmpty) {
      if (workout.imageUri!.startsWith('http') || (kIsWeb && workout.imageUri!.startsWith('blob'))) {
        imageWidget = Image.network(
          workout.imageUri!,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
        );
      } else if (!kIsWeb) {
        final file = File(workout.imageUri!);
        imageWidget = Image.file(
          file,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
        );
      } else {
        imageWidget = _buildPlaceholderIcon();
      }
    } else {
      imageWidget = _buildPlaceholderIcon();
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              imageWidget,
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  workout.eventTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sets: ${workout.sets}, Reps/Secs: ${workout.repsOrSecs}", 
                     style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text("Rest: ${workout.restTime}s", 
                     style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text("Notes: ${workout.notes}", 
                       style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[600])),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Completed: ${workout.isCompleted ? 'Yes' : 'No'}", 
                      style: TextStyle(
                        fontSize: 16, 
                        color: workout.isCompleted ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Switch(
                      value: workout.isCompleted,
                      onChanged: (value) => onToggleComplete(value),
                      activeColor: DeepBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      height: 150,
      color: Colors.grey[300],
      child: Center(child: Icon(Icons.fitness_center, size: 50, color: Colors.grey[600])),
    );
  }
}

class MemberWorkoutsScreen extends ConsumerStatefulWidget {
  const MemberWorkoutsScreen({super.key});

  @override
  ConsumerState<MemberWorkoutsScreen> createState() => _MemberWorkoutsScreenState();
}

class _MemberWorkoutsScreenState extends ConsumerState<MemberWorkoutsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkouts();
    });
  }

  Future<void> _loadWorkouts() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      await ref.read(memberWorkoutProvider.notifier).loadWorkouts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load workouts')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberWorkoutProvider);
    final authState = ref.watch(authProvider);

    // Redirect to login if not authenticated
    if (authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show loading indicator if initial load is in progress
    if (_isLoading && state.workouts.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Redirect to login if not authenticated
    if (authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
        backgroundColor: DeepBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkouts,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _loadWorkouts,
        child: _buildBody(state),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  Widget _buildBody(MemberWorkoutState state) {
    // Show error state
    if (state.error != null) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 24),
                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _loadWorkouts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('TRY AGAIN'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: DeepBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Show empty state
    if (state.workouts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'No Workouts Assigned',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You don\'t have any workouts assigned yet.\nCheck back later or contact your trainer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _loadWorkouts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('REFRESH WORKOUTS'),
                  style: FilledButton.styleFrom(
                    backgroundColor: DeepBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Show workout list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.workouts.length,
      itemBuilder: (context, index) {
        final workout = state.workouts[index];
        return MemberWorkoutCard(
          key: ValueKey('workout-${workout.id}'),
          workout: workout,
          onToggleComplete: (isCompleted) {
            ref.read(memberWorkoutProvider.notifier).markWorkoutAsCompleted(
                  workout.id.toString(),
                  isCompleted,
                );
          },
        );
      },
    );
  }
}
