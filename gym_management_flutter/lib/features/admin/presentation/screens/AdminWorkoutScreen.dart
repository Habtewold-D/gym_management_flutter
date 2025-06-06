import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
// import your workout models & utils as needed
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/utils/image_picker_util.dart';
import '../providers/admin_provider.dart';

// Color constants reused from AdminEventScreen
const DeepBlue = Color(0xFF0000CD);
const LightBlue = Color(0xFFE6E9FD);

class AdminWorkoutScreen extends ConsumerStatefulWidget {
  final int userId;
  const AdminWorkoutScreen({Key? key, required this.userId}) : super(key: key);
  
  @override
  _AdminWorkoutScreenState createState() => _AdminWorkoutScreenState();
}

class _AdminWorkoutScreenState extends ConsumerState<AdminWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    // Load workouts when the screen is initialized
    Future.microtask(() => ref.read(adminProvider.notifier).loadWorkouts());
  }
  
  Future<void> _refreshWorkouts() async {
    await ref.read(adminProvider.notifier).loadWorkouts();
  }
  
  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(adminProvider.select((p) => p.workouts));
    final isLoading = ref.watch(adminProvider.select((p) => p.isLoading));
    final error = ref.watch(adminProvider.select((p) => p.error));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Workouts"),
        backgroundColor: const Color(0xFF241A87),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWorkouts,
        child: _buildBody(workouts, isLoading, error),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF241A87),
        child: const Icon(Icons.add),
        onPressed: () {
          // Show UI to create a workout
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Create Workout"),
              content: const Text("Workout creation UI goes here."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(List<WorkoutResponse> workouts, bool isLoading, String? error) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshWorkouts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (workouts.isEmpty) {
      return const Center(child: Text('No workouts found'));
    }
    
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(workout.eventTitle ?? 'No Title'),
            subtitle: Text('Sets: ${workout.sets}  Reps/Secs: ${workout.repsOrSecs}'),
            trailing: Icon(
              workout.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: workout.isCompleted ? Colors.green : Colors.grey,
            ),
            onTap: () {
              // Show workout details
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(workout.eventTitle ?? 'Workout Details'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sets: ${workout.sets}'),
                      Text('Reps/Secs: ${workout.repsOrSecs}'),
                      Text('Completed: ${workout.isCompleted ? 'Yes' : 'No'}'),
                      if (workout.notes != null) Text('Notes: ${workout.notes}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Dummy placeholder widgets for compilation:
Widget WorkoutCard({required dynamic workout}) =>
    Card(child: ListTile(title: Text(workout.toString())));
Widget EditWorkoutDialog({required dynamic workout, required Function onConfirm}) =>
    AlertDialog(title: const Text("Edit Workout"), content: const Text("Edit workout details here"));
