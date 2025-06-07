import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:gym_management_flutter/features/member/presentation/providers/member_workout_provider.dart';

// Color constants
const Color primaryBlue = Color(0xFF1A18C6);
const Color primaryGreen = Color(0xFF4CAF50);
const Color lightGrey = Color(0xFFF8F9FB);
const Color backgroundColor = Color(0xFFF5F5F5);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Daily Workout',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
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
        // Progress Card (no separate app bar needed as we have a regular AppBar)
        const SliverToBoxAdapter(
          child: SizedBox.shrink(),
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
                  color: Colors.black,
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
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            if (workout.imageUri != null && workout.imageUri!.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: workout.imageUri!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                ),
              ),
            
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Complete Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Workout Name with Pill Background
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          workout.eventTitle.isNotEmpty 
                              ? workout.eventTitle 
                              : 'Workout',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      // Complete Button
                      ElevatedButton(
                        onPressed: isCompleting ? null : onToggleCompletion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: workout.isCompleted ? primaryGreen : primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          elevation: 2,
                        ),
                        child: isCompleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                workout.isCompleted ? 'Completed' : 'Mark Complete',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Workout Details with Pill Backgrounds
                  Row(
                    children: [
                      _buildPill('${workout.sets} Sets', Icons.repeat),
                      const SizedBox(width: 8),
                      _buildPill('${workout.repsOrSecs} Reps', Icons.fitness_center),
                      const SizedBox(width: 8),
                      _buildPill('${workout.restTime}s Rest', Icons.timer),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryBlue),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}