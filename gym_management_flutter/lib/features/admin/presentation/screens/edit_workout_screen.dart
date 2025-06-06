import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/features/admin/presentation/providers/admin_workout_provider.dart';
import 'package:gym_management_flutter/features/admin/presentation/widgets/image_picker_preview_widget.dart';
import 'package:gym_management_flutter/utils/image_picker_util.dart';

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
    if (widget.workout.imageUri != null && widget.workout.imageUri!.isNotEmpty) {
      // Initialize with existing image URI. ImagePickerPreviewWidget handles display.
      _selectedImageData = {'path': widget.workout.imageUri};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
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
      if (mounted) { // Check if the widget is still in the tree
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
        // If _selectedImageData is null, it means user wants to remove the image
        imagePath = null; 
      }

      final workoutUpdateRequest = WorkoutUpdateRequest(
        id: widget.workout.id,
        eventTitle: title,
        sets: sets,
        repsOrSecs: reps,
        restTime: rest,
        imageUri: imagePath, // This can be a local path, an http URL, or null
        userId: _userId, // Assuming userId doesn't change during edit
      );

      try {
        await ref.read(adminWorkoutNotifierProvider.notifier).updateWorkout(workoutUpdateRequest);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout updated successfully!')),
        );
        Navigator.of(context).pop(); // Go back to the previous screen
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
        title: const Text('Edit Workout'),
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Workout Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _setsController,
                decoration: const InputDecoration(labelText: 'Sets'),
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
                decoration: const InputDecoration(labelText: 'Reps/Secs'),
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
                decoration: const InputDecoration(labelText: 'Rest Time (seconds)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number for rest time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ImagePickerPreviewWidget(
                imageData: _selectedImageData,
                onPickImage: _pickImage,
                pickButtonText: 'Change Workout Image',
                changeButtonText: 'Change Workout Image',
              ),
              if (_selectedImageData != null && _selectedImageData!['path'] != null)
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  label: const Text('Remove Image', style: TextStyle(color: Colors.redAccent)),
                  onPressed: _removeImage,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: workoutState.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: DeepBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: workoutState.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
