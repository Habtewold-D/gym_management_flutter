import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:gym_management_flutter/features/member/presentation/providers/member_workout_provider.dart';

// Color constants
const Color primaryBlue = Color(0xFF0000CD);
const Color primaryGreen = Color(0xFF4CAF50);
const Color lightGreyBackground = Color(0xFFF5F5F5);
const Color white = Colors.white;
const Color black = Colors.black;

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
      backgroundColor: lightGreyBackground,
      appBar: AppBar(
        title: const Text(
          'Daily workout',
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: white),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshWorkouts,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(MemberWorkoutState state) {
    if (state.isLoading && state.workouts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
        ),
      );
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
        // Progress Card
        SliverToBoxAdapter(
          child: _buildProgressCard(state),
        ),
        // Your Workouts Title
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text(
              'Your Workouts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ),
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
                  isCompleting: state.isCompletingWorkout(workout.id.toString()),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedWorkouts of $totalWorkouts completed',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
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
    Widget imageWidget;
    if (workout.imageUri != null && workout.imageUri!.isNotEmpty) {
      if (workout.imageUri!.startsWith('http') || (kIsWeb && workout.imageUri!.startsWith('blob'))) {
        imageWidget = Image.network(
          workout.imageUri!,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 150,
            color: Colors.grey[300],
            child: Center(child: Icon(Icons.broken_image, color: Colors.grey[600])),
          ),
        );
      } else if (!kIsWeb) {
        final file = File(workout.imageUri!);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            fit: BoxFit.cover,
            height: 150,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              color: Colors.grey[300],
              child: Center(child: Icon(Icons.broken_image, color: Colors.grey[600])),
            ),
          );
        } else {
          imageWidget = Container(
            height: 150,
            color: Colors.grey[300],
            child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey[600], size: 50)),
          );
        }
      } else { // Web, but not http/blob (e.g. invalid local path for web)
        imageWidget = Container(
          height: 150,
          color: Colors.grey[300],
          child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey[600], size: 50)),
        );
      }
    } else {
      imageWidget = Container(
        height: 150,
        color: Colors.grey[300],
        child: Center(child: Icon(Icons.fitness_center, size: 50, color: Colors.grey[600])),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          imageWidget,
          // Completion Button
          Positioned(
            top: 8,
            right: 8,
            child: ElevatedButton(
              onPressed: onToggleCompletion,
              style: ElevatedButton.styleFrom(
                backgroundColor: workout.isCompleted ? primaryGreen : primaryBlue,
                foregroundColor: white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: isCompleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(white),
                      ),
                    )
                  : Text(
                      workout.isCompleted ? 'Done' : 'Finish',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          // Workout Details
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.eventTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${workout.sets} sets ${workout.repsOrSecs} reps ${workout.restTime} sec',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}