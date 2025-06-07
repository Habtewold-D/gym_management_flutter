import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/features/admin/presentation/providers/admin_workout_provider.dart';
import 'package:gym_management_flutter/utils/image_picker_util.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

const DeepBlue = Color(0xFF0000CD); // Consider moving to a shared constants file
const LightBlue = Color(0xFFE6E9FD);

class EditWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutResponse workout;

  const EditWorkoutScreen({Key? key, required this.workout}) : super(key: key);

  @override
  _EditWorkoutScreenState createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;
  late TextEditingController _userIdController;
  Map<String, dynamic>? _selectedImageData;
  late int _userId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.workout.eventTitle);
    _setsController = TextEditingController(text: widget.workout.sets.toString());
    _repsController = TextEditingController(text: widget.workout.repsOrSecs.toString());
    _restController = TextEditingController(text: widget.workout.restTime.toString());
    _userId = widget.workout.userId;
    _userIdController = TextEditingController(text: widget.workout.userId.toString());
    if (widget.workout.imageUri != null && widget.workout.imageUri!.isNotEmpty) {
      _selectedImageData = {'path': widget.workout.imageUri};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final imageData = await ImagePickerUtil.pickImageFromGallery();
      if (imageData != null) {
        setState(() {
          _selectedImageData = imageData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString().replaceFirst("Exception: ", "")}')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageData = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final sets = int.tryParse(_setsController.text);
      final reps = int.tryParse(_repsController.text);
      final rest = int.tryParse(_restController.text);

      if (sets == null || reps == null || rest == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid numbers for sets, reps, and rest time.')),
        );
        return;
      }

      String? imagePath;
      if (_selectedImageData != null) {
        imagePath = _selectedImageData!['path'] as String?;
      } else {
        imagePath = null; 
      }

      final workoutUpdateRequest = WorkoutUpdateRequest(
        id: widget.workout.id,
        eventTitle: title,
        sets: sets,
        repsOrSecs: reps,
        restTime: rest,
        imageUri: imagePath,
        userId: _userId,
      );

      try {
        await ref.read(adminWorkoutNotifierProvider.notifier).updateWorkout(workoutUpdateRequest);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout updated successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update workout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(adminWorkoutNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Workouts'),
        backgroundColor: DeepBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Image Picker Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: LightBlue,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImageData != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            (kIsWeb && _selectedImageData!['path'].startsWith('blob'))
                                ? Image.network(_selectedImageData!['path'], fit: BoxFit.cover)
                                : Image.file(File(_selectedImageData!['path']), fit: BoxFit.cover),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]),
                            const SizedBox(height: 10),
                            Text(
                              "Tap to add an image",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'Trainee Id',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number for Trainee ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _setsController,
                decoration: const InputDecoration(
                  labelText: 'Sets',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number for sets';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(
                  labelText: 'Reps/ sec',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number for reps/secs';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _restController,
                decoration: const InputDecoration(
                  labelText: 'Rest time',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number for rest time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: DeepBlue,
                        side: const BorderSide(color: DeepBlue),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
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
                                const SnackBar(content: Text('Workout deleted successfully')),
                              );
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting workout: $e')),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: workoutState.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DeepBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: workoutState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
