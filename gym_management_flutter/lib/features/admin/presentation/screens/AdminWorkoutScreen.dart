// lib/features/admin/presentation/screens/AdminWorkoutScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/utils/image_picker_util.dart';
import 'package:gym_management_flutter/features/admin/presentation/providers/admin_workout_provider.dart';
import 'package:gym_management_flutter/features/admin/presentation/widgets/image_picker_preview_widget.dart';
import 'package:gym_management_flutter/features/admin/presentation/screens/edit_workout_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Color constants reused
const DeepBlue = Color(0xFF0000CD);
const LightBlue = Color(0xFFE6E9FD);

// WorkoutCard Widget
class WorkoutCard extends StatelessWidget {
  final WorkoutResponse workout;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WorkoutCard({Key? key, required this.workout, required this.onEdit, required this.onDelete}) : super(key: key);

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
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: DeepBlue, size: 20),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero, // Remove extra padding
                    constraints: const BoxConstraints(), // Remove default constraints
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
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

class AdminWorkoutScreen extends ConsumerStatefulWidget {
  final int userId; 
  const AdminWorkoutScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AdminWorkoutScreenState createState() => _AdminWorkoutScreenState();
}

class _AdminWorkoutScreenState extends ConsumerState<AdminWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late TextEditingController _traineeIdController; 
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _restController = TextEditingController();
  Map<String, dynamic>? _pickedImage;

  @override
  void initState() {
    super.initState();
    _traineeIdController = TextEditingController(text: widget.userId.toString());
    // Load workouts for all users initially, then filter in build, 
    // or modify provider to load by user ID if that's a common use case.
    // For now, loading all and filtering in UI.
    Future.microtask(() => ref.read(adminWorkoutNotifierProvider.notifier).loadWorkouts());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _traineeIdController.dispose();
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
          _pickedImage = imageData;
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

  void _removeCreateFormImage() {
    setState(() {
      _pickedImage = null;
    });
  }

  void _createWorkout() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final traineeId = int.tryParse(_traineeIdController.text); // Should always be widget.userId
      final sets = int.tryParse(_setsController.text);
      final reps = int.tryParse(_repsController.text);
      final rest = int.tryParse(_restController.text);

      if (traineeId == null || sets == null || reps == null || rest == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please ensure all numeric fields are valid numbers.'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      final workoutRequest = WorkoutRequest(
        eventTitle: title,
        sets: sets,
        repsOrSecs: reps,
        restTime: rest,
        imageUri: _pickedImage?['path'] as String?,
        isCompleted: false,
        userId: traineeId, // Use the parsed (and fixed) traineeId
      );
      try {
        await ref.read(adminWorkoutNotifierProvider.notifier).createWorkout(workoutRequest);
        _titleController.clear();
        // _traineeIdController should not be cleared as it's fixed for this screen
        _setsController.clear();
        _repsController.clear();
        _restController.clear();
        setState(() { _pickedImage = null; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout created successfully!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create workout: ${e.toString().replaceFirst("Exception: ", "")}') , backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _refreshWorkouts() async {
    // This will refresh all workouts; filtering happens in the build method.
    await ref.read(adminWorkoutNotifierProvider.notifier).loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workouts"),
        backgroundColor: const Color(0xFF241A87),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminWorkoutNotifierProvider.notifier).loadWorkouts(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Workout Section
              const Text(
                "Add Workout",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _pickedImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            kIsWeb
                                ? Image.network(_pickedImage!['path'], fit: BoxFit.cover)
                                : Image.file(File(_pickedImage!['path']), fit: BoxFit.cover),
                            Positioned( // Add close button to remove image
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: _removeCreateFormImage,
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
                              "Tap to add workout image",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Workout title",
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _traineeIdController,
                      decoration: const InputDecoration(
                        labelText: "Trainee ID",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Trainee ID';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _setsController,
                      decoration: const InputDecoration(
                        labelText: "Sets",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of sets';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _repsController,
                      decoration: const InputDecoration(
                        labelText: "Reps/Sec",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter reps or seconds';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _restController,
                      decoration: const InputDecoration(
                        labelText: "Rest Time",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter rest time';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _createWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DeepBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text("Create", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Workout List Section
              const Text(
                "Workout List",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, watch, child) {
                  final workoutState = ref.watch(adminWorkoutNotifierProvider);
                  if (workoutState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (workoutState.error != null) {
                    return Center(child: Text('Error: ${workoutState.error}'));
                  } else if (workoutState.workouts.isEmpty) {
                    return const Center(child: Text('No workouts found.'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workoutState.workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workoutState.workouts[index];
                        return WorkoutCard(
                          workout: workout,
                          onEdit: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditWorkoutScreen(workout: workout)));
                          },
                          onDelete: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Workout'),
                                content: Text('Are you sure you want to delete ${workout.eventTitle}?'),
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
                                await ref.read(adminWorkoutNotifierProvider.notifier).deleteWorkout(workout.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Workout deleted successfully')),
                                  );
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
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}