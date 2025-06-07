import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:gym_management_flutter/features/member/presentation/providers/member_workout_provider.dart';

// Color constants
const deepBlue = Color(0xFF0000CD);
const green = Color(0xFF4CAF50);
const lightGrey = Color(0xFFF8F9FB);
const darkBlue = Color(0xFF1A18C6);

class MemberWorkoutsScreen extends ConsumerStatefulWidget {
  const MemberWorkoutsScreen({super.key});

  @override
  ConsumerState<MemberWorkoutsScreen> createState() => _MemberWorkoutsScreenState();
}

class _MemberWorkoutsScreenState extends ConsumerState<MemberWorkoutsScreen> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Load workouts when the screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkouts();
    });
  }

  Future<void> _loadWorkouts() async {
    final notifier = ref.read(memberWorkoutProvider.notifier);
    await notifier.loadWorkouts();
  }

  Future<void> _refreshWorkouts() async {
    final notifier = ref.read(memberWorkoutProvider.notifier);
    await notifier.refreshWorkouts();
  }

  Future<void> _toggleWorkoutCompletion(String workoutId, bool isCompleted) async {
    final notifier = ref.read(memberWorkoutProvider.notifier);
    await notifier.markWorkoutAsCompleted(workoutId, !isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberWorkoutProvider);
    
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshWorkouts,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(MemberWorkoutState state) {
    if (state.isLoading && state.workouts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWorkouts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No workouts assigned yet.\nCheck back later for your personalized workout plan!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWorkouts,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          title: const Text('Daily Workout'),
          backgroundColor: deepBlue,
          expandedHeight: 60,
          floating: true,
          pinned: true,
        ),
        // Progress Card
        SliverToBoxAdapter(
          child: _buildProgressCard(state),
        ),
        // Workouts List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final workout = state.workouts[index];
                return WorkoutCard(
                  workout: workout,
                  onToggleCompletion: () => _toggleWorkoutCompletion(
                    workout.id.toString(),
                    workout.isCompleted,
                  ),
                );
              },
              childCount: state.workouts.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(MemberWorkoutState state) {
    final completedWorkouts = state.workouts.where((w) => w.isCompleted).length;
    final totalWorkouts = state.workouts.length;
    final progress = totalWorkouts > 0 ? completedWorkouts / totalWorkouts : 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      color: lightGrey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 16,
              borderRadius: BorderRadius.circular(8),
              valueColor: const AlwaysStoppedAnimation<Color>(darkBlue),
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final WorkoutResponse workout;
  final VoidCallback onToggleCompletion;
  final bool isCompleting;

  const WorkoutCard({
    Key? key,
    required this.workout,
    required this.onToggleCompletion,
    this.isCompleting = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            // Background Image
            if (workout.imageUri != null && workout.imageUri!.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: workout.imageUri!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  ),
                ),
              )
            else
              Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.fitness_center, size: 50, color: Colors.grey),
                ),
              ),

            // Top left: Title in white rounded box
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  workout.eventTitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Top right: Complete button
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: workout.isCompleted ? green : deepBlue,
                borderRadius: BorderRadius.circular(8),
                elevation: 4,
                child: InkWell(
                  onTap: isCompleting ? null : onToggleCompletion,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Text(
                      workout.isCompleted ? 'Done' : 'Finish',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom: Workout details in white rounded box
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem('Sets', '${workout.sets}'),
                    _buildDetailItem('Reps/Secs', '${workout.repsOrSecs}'),
                    _buildDetailItem('Rest', '${workout.restTime}s'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}