import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/features/admin/presentation/providers/admin_workout_provider.dart';

// Color constants
const DeepBlue = Color(0xFF0000CD);
const LightBlue = Color(0xFFE6E9FD);
const Green = Color(0xFF4CAF50);

class EditWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutResponse workout;
  final int userId;

  const EditWorkoutScreen({
    Key? key,
    required this.workout,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workout'),
        backgroundColor: DeepBlue,
        foregroundColor: Colors.white,
      ),
      body: _EditWorkoutForm(workout: widget.workout, userId: widget.userId),
    );
  }
}

class _EditWorkoutForm extends ConsumerStatefulWidget {
  final WorkoutResponse workout;
  final int userId;

  const _EditWorkoutForm({
    Key? key,
    required this.workout,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<_EditWorkoutForm> createState() => _EditWorkoutFormState();
}

class _EditWorkoutFormState extends ConsumerState<_EditWorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.workout.eventTitle);
    _setsController = TextEditingController(text: widget.workout.sets.toString());
    _repsController = TextEditingController(text: widget.workout.repsOrSecs.toString());
    _restController = TextEditingController(text: widget.workout.restTime.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text;
      final sets = int.tryParse(_setsController.text) ?? 0;
      final reps = int.tryParse(_repsController.text) ?? 0;
      final rest = int.tryParse(_restController.text) ?? 0;

      final workoutUpdateRequest = WorkoutUpdateRequest(
        id: widget.workout.id,
        eventTitle: title,
        sets: sets,
        repsOrSecs: reps,
        restTime: rest,
        imageUri: widget.workout.imageUri,
        userId: widget.userId,
      );

      await ref.read(adminWorkoutNotifierProvider.notifier).updateWorkout(workoutUpdateRequest);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout updated successfully!'),
            backgroundColor: Green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Are you sure you want to delete ${widget.workout.eventTitle}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminWorkoutNotifierProvider.notifier).deleteWorkout(widget.workout.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout deleted successfully'),
              backgroundColor: Green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting workout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Workout Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            
            // Sets Field
            TextFormField(
              controller: _setsController,
              decoration: const InputDecoration(
                labelText: 'Number of Sets',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Please enter number of sets' : null,
            ),
            const SizedBox(height: 16),
            
            // Reps Field
            TextFormField(
              controller: _repsController,
              decoration: const InputDecoration(
                labelText: 'Reps or Seconds',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat_one),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Please enter reps or seconds' : null,
            ),
            const SizedBox(height: 16),
            
            // Rest Time Field
            TextFormField(
              controller: _restController,
              decoration: const InputDecoration(
                labelText: 'Rest Time (seconds)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Please enter rest time' : null,
            ),
            const SizedBox(height: 24),
            
            // Update Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeepBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Update Workout',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Delete Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _deleteWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Delete Workout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}