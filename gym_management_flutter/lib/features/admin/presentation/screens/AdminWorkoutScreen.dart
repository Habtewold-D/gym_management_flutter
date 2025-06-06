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
                Text("Trainee ID: ${workout.userId}", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text("Sets: ${workout.sets}, Reps/Secs: ${workout.repsOrSecs}, Rest: ${workout.restTime}s", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text("Completed: ${workout.isCompleted ? 'Yes' : 'No'}", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                if (workout.notes != null && workout.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text("Notes: ${workout.notes}", style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[600])),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: DeepBlue),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ),
              ],
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
    final adminState = ref.watch(adminWorkoutNotifierProvider);
    // Display all workouts, not filtered by a specific userId from the widget
    final workouts = adminState.workouts.toList(); 
    final isLoading = adminState.isLoading;
    final error = adminState.error;

    return Scaffold(
      appBar: AppBar(
        // Updated AppBar title for general workout management
        title: const Text("Admin Workouts Management"), 
        backgroundColor: DeepBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Create Workout Form Section
            Container(
              padding: const EdgeInsets.all(16),
              color: LightBlue.withOpacity(0.3),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Add New Workout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DeepBlue)),
                      const SizedBox(height: 12),
                      ImagePickerPreviewWidget(
                        imageData: _pickedImage,
                        onPickImage: _pickImage,
                        pickButtonText: 'Select Workout Image',
                        changeButtonText: 'Change Workout Image',
                      ),
                      if (_pickedImage != null)
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          label: const Text('Remove Image', style: TextStyle(color: Colors.redAccent)),
                          onPressed: _removeCreateFormImage,
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: "Workout Title", border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty ? 'Title cannot be empty' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _traineeIdController,
                        decoration: const InputDecoration(labelText: "Trainee ID", border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        // Trainee ID field is now enabled for manual input
                        enabled: true, 
                        validator: (value) => value == null || value.isEmpty || int.tryParse(value) == null ? 'Valid Trainee ID required' : null,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: TextFormField(controller: _setsController, decoration: const InputDecoration(labelText: "Sets", border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (value) => value == null || value.isEmpty || int.tryParse(value) == null ? 'Invalid' : null)),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _repsController, decoration: const InputDecoration(labelText: "Reps/Sec", border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (value) => value == null || value.isEmpty || int.tryParse(value) == null ? 'Invalid' : null)),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _restController,
                        decoration: const InputDecoration(labelText: "Rest Time (sec)", border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty || int.tryParse(value) == null ? 'Invalid' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: isLoading ? null : _createWorkout,
                        label: const Text("Create Workout"),
                        style: ElevatedButton.styleFrom(backgroundColor: DeepBlue, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Workouts List Section
            RefreshIndicator(
              onRefresh: _refreshWorkouts,
              child: isLoading && workouts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $error. Pull to refresh.', textAlign: TextAlign.center)))
                      : workouts.isEmpty
                          // Updated empty list message for general workout list
                          ? const Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('No workouts found.\nPull to refresh or add a new one above.', textAlign: TextAlign.center))) 
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: workouts.length,
                              itemBuilder: (context, index) {
                                final workout = workouts[index];
                                return WorkoutCard(
                                  workout: workout,
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditWorkoutScreen(workout: workout),
                                      ),
                                    ).then((_) => _refreshWorkouts());
                                  },
                                  onDelete: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: Text('Are you sure you want to delete "${workout.eventTitle}"? This action cannot be undone.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              onPressed: () async {
                                                Navigator.of(ctx).pop();
                                                try {
                                                  await ref.read(adminWorkoutNotifierProvider.notifier).deleteWorkout(workout.id);
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Workout deleted successfully!'), backgroundColor: Colors.green),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to delete workout: ${e.toString().replaceFirst("Exception: ", "")}') , backgroundColor: Colors.red),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              }, // End itemBuilder
                            ), // End ListView.builder
            ), // End RefreshIndicator
          ], // End children of main Column
        ),   // End main Column
      ),     // End SingleChildScrollView
    );     // End Scaffold
  }
}