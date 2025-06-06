import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/utils/image_picker_util.dart';
import '../providers/admin_provider.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// WorkoutCard Widget
class WorkoutCard extends StatelessWidget {
  final WorkoutResponse workout;
  final VoidCallback onEdit;

  const WorkoutCard({Key? key, required this.workout, required this.onEdit}) : super(key: key);

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
      } else {
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
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: DeepBlue),
                    onPressed: onEdit,
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
  final _titleController = TextEditingController();
  final _traineeIdController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _restController = TextEditingController();
  Map<String, dynamic>? _pickedImage; // Changed to store map
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadWorkouts());
  }
  
  Future<void> _pickImage() async {
    final imageData = await ImagePickerUtil.pickImage(context);
    if (imageData != null) {
      setState(() {
        _pickedImage = imageData;
      });
    }
  }
  
  void _createWorkout() {
    final title = _titleController.text;
    final traineeId = int.tryParse(_traineeIdController.text) ?? 0;
    final sets = int.tryParse(_setsController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    final rest = int.tryParse(_restController.text) ?? 0;
    if (title.isNotEmpty && traineeId > 0) {
      final workoutRequest = WorkoutRequest(
        eventTitle: title,
        sets: sets,
        repsOrSecs: reps,
        restTime: rest,
        imageUri: kIsWeb ? (_pickedImage?['blobUrl'] as String?) : (_pickedImage?['path'] as String?),
        isCompleted: false,
        userId: traineeId,
      );
      ref.read(adminProvider.notifier).createWorkout(workoutRequest);
      _titleController.clear();
      _traineeIdController.clear();
      _setsController.clear();
      _repsController.clear();
      _restController.clear();
      setState(() { _pickedImage = null; });
    }
  }
  
  Future<void> _refreshWorkouts() async {
    await ref.read(adminProvider.notifier).loadWorkouts();
  }
  
  Future<dynamic> _showEditDialog(WorkoutResponse workout) {
    final editTitleController = TextEditingController(text: workout.eventTitle);
    final editTraineeController = TextEditingController(text: workout.userId.toString());
    final editSetsController = TextEditingController(text: workout.sets.toString());
    final editRepsController = TextEditingController(text: workout.repsOrSecs.toString());
    final editRestController = TextEditingController(text: workout.restTime.toString());
    Map<String, dynamic>? editImageData = workout.imageUri != null ? {'path': workout.imageUri, 'blobUrl': workout.imageUri} : null;
    
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Workout"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final imageData = await ImagePickerUtil.pickImage(context);
                        if (imageData != null) {
                          setStateDialog(() { 
                            editImageData = imageData; 
                          });
                        }
                      },
                      child: editImageData != null
                          ? (kIsWeb
                              ? (editImageData!['bytes'] != null
                                  ? Image.memory(
                                      editImageData!['bytes'] as Uint8List,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      editImageData!['blobUrl'] ?? editImageData!['path'],
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ))
                              : Image.file(
                                  File(editImageData!['path']),
                                  height: 100,
                                  fit: BoxFit.cover,
                                ))
                          : const Text("Tap to add image"),
                    ),
                    TextField(
                      controller: editTitleController,
                      decoration: const InputDecoration(labelText: "Workout Title"),
                    ),
                    TextField(
                      controller: editTraineeController,
                      decoration: const InputDecoration(labelText: "Trainee ID"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: editSetsController,
                      decoration: const InputDecoration(labelText: "Sets"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: editRepsController,
                      decoration: const InputDecoration(labelText: "Reps/Sec"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: editRestController,
                      decoration: const InputDecoration(labelText: "Rest Time (sec)"),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {"delete": true, "id": workout.id});
                  },
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedWorkout = WorkoutUpdateRequest(
                      id: workout.id,
                      eventTitle: editTitleController.text.isNotEmpty ? editTitleController.text : null,
                      sets: int.tryParse(editSetsController.text),
                      repsOrSecs: int.tryParse(editRepsController.text),
                      restTime: int.tryParse(editRestController.text),
                      imageUri: kIsWeb ? (editImageData?['blobUrl'] as String?) : (editImageData?['path'] as String?),
                      userId: int.tryParse(editTraineeController.text),
                    );
                    Navigator.pop(context, updatedWorkout);
                  },
                  child: const Text("Save"),
                )
              ],
            );
          },
        );
      }
    );
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: LightBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add Workout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _pickImage,
                    child: _pickedImage != null
                        ? (kIsWeb
                            ? (_pickedImage!['bytes'] != null
                                ? Image.memory(
                                    _pickedImage!['bytes'] as Uint8List,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _pickedImage!['blobUrl'] ?? _pickedImage!['path'],
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ))
                            : Image.file(
                                File(_pickedImage!['path']),
                                height: 100,
                                fit: BoxFit.cover,
                              ))
                        : const Text("Tap to add image"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Workout Title"),
                  ),
                  TextField(
                    controller: _traineeIdController,
                    decoration: const InputDecoration(labelText: "Trainee ID"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _setsController,
                    decoration: const InputDecoration(labelText: "Sets"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _repsController,
                    decoration: const InputDecoration(labelText: "Reps/Sec"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _restController,
                    decoration: const InputDecoration(labelText: "Rest Time (sec)"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _createWorkout,
                    child: const Text("Create Workout"),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: _refreshWorkouts,
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                  ? Center(child: Text('Error: $error'))
                  : workouts.isEmpty
                    ? const Center(child: Text('No workouts available'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          return WorkoutCard(
                            workout: workout,
                            onEdit: () async {
                              final result = await _showEditDialog(workout);
                              if (result != null) {
                                if (result is WorkoutUpdateRequest) {
                                  ref.read(adminProvider.notifier).updateWorkout(result);
                                } else if (result is Map && result["delete"] == true) {
                                  final workoutId = result["id"] as int?;
                                  if (workoutId != null) {
                                    ref.read(adminProvider.notifier).deleteWorkout(workoutId);
                                  }
                                }
                              }
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}