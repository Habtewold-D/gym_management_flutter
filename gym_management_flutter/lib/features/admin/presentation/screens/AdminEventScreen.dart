import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/features/admin/presentation/providers/admin_event_provider.dart';
import 'package:gym_management_flutter/utils/image_picker_util.dart';
import 'package:gym_management_flutter/features/admin/presentation/widgets/image_picker_preview_widget.dart'; // Assuming this exists and is adaptable
import 'package:cached_network_image/cached_network_image.dart';

// Define color constants
const DeepBlue = Color(0xFF0000CD);
const LightBlue = Color(0xFFE6E9FD);
const Green = Color(0xFF4CAF50);

class AdminEventScreen extends ConsumerStatefulWidget {
  final int userId; // ID of the admin creating the event
  const AdminEventScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AdminEventScreenState createState() => _AdminEventScreenState();
}

class _AdminEventScreenState extends ConsumerState<AdminEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  
  Map<String, dynamic>? _pickedImageData; // For storing image data from picker

  EventResponse? _editingEvent; // To hold event being edited

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminEventNotifierProvider.notifier).loadEvents());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _dateController.clear();
    _timeController.clear();
    _locationController.clear();
    setState(() {
      _pickedImageData = null;
      _editingEvent = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage() async {
    final imageData = await ImagePickerUtil.pickImageFromGallery();
    if (imageData != null) {
      setState(() {
        _pickedImageData = imageData;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_editingEvent == null) {
        // Create new event
        final request = EventRequest(
          title: _titleController.text,
          date: _dateController.text,
          time: _timeController.text,
          location: _locationController.text,
          imageUri: _pickedImageData?['path'] as String?, // Path from picker (blob or file path)
          createdBy: widget.userId,
        );
        ref.read(adminEventNotifierProvider.notifier).createEvent(request).then((_) {
          _resetForm();
        }).catchError((e) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create event: $e'), backgroundColor: Colors.red));
        });
      } else {
        // Update existing event
        final request = EventUpdateRequest(
          id: _editingEvent!.id,
          title: _titleController.text,
          date: _dateController.text,
          time: _timeController.text,
          location: _locationController.text,
          imageUri: _pickedImageData?['path'] as String?, // Path from picker
        );
        ref.read(adminEventNotifierProvider.notifier).updateEvent(request).then((_) {
          _resetForm();
        }).catchError((e) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update event: $e'), backgroundColor: Colors.red));
        });
      }
    }
  }

  void _editEvent(EventResponse event) {
    setState(() {
      _editingEvent = event;
      _titleController.text = event.title;
      _dateController.text = event.date;
      _timeController.text = event.time;
      _locationController.text = event.location;
      if (event.imageUri != null && event.imageUri!.isNotEmpty) {
        _pickedImageData = {'path': event.imageUri};
      } else {
        _pickedImageData = null;
      }

    });
  }

  void _deleteEvent(int eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(adminEventNotifierProvider.notifier).deleteEvent(eventId).catchError((e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete event: $e'), backgroundColor: Colors.red));
              });
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminEventState = ref.watch(adminEventNotifierProvider);
    final events = adminEventState.events;
    final isLoading = adminEventState.isLoading;
    final error = adminEventState.error;
    final successMessage = adminEventState.successMessage;

    if (successMessage != null && successMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage), backgroundColor: Green));
        ref.read(adminEventNotifierProvider.notifier).clearMessages(); // Clear message
      });
    }
    if (error != null && error.isNotEmpty  && !error.toLowerCase().contains('Please login again')) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
         // Optionally clear error: ref.read(adminProvider.notifier).clearError(); 
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingEvent == null ? 'Manage Events' : 'Edit Event', style: TextStyle(color: DeepBlue)),
        backgroundColor: LightBlue,
        elevation: 0,
        actions: [
          if (_editingEvent != null)
            IconButton(
              icon: Icon(Icons.cancel, color: DeepBlue),
              onPressed: _resetForm, // Cancel editing
            )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminEventNotifierProvider.notifier).loadEvents(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildEventForm(context),
                        SizedBox(height: 24),
                        Text('Existing Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DeepBlue)),
                        SizedBox(height: 10),
                        if (isLoading && events.isEmpty) Center(child: CircularProgressIndicator()),
                        if (error != null && !isLoading && events.isEmpty) 
                          Center(child: Text('Error: $error', style: TextStyle(color: Colors.red))),
                        if (!isLoading && events.isEmpty && error == null) 
                          Center(child: Text('No events found. Create one above!')),
                        if (events.isNotEmpty) ...[
                          ...events.map((event) => EventCard(
                            event: event,
                            onEdit: () => _editEvent(event),
                            onDelete: () => _deleteEvent(event.id),
                          )).toList(),
                        ],
                        // Add some bottom padding when there are many events
                        if (events.isNotEmpty) SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_editingEvent == null ? 'Create New Event' : 'Editing: ${_editingEvent!.title}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DeepBlue)),
            SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)', border: OutlineInputBorder()),
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Time (HH:MM)', border: OutlineInputBorder()),
              readOnly: true,
              onTap: () => _selectTime(context),
              validator: (value) => value == null || value.isEmpty ? 'Please select a time' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
            ),
            SizedBox(height: 16),
            // TODO: Review ImagePickerPreviewWidget parameters if they were changed from initialImagePath/Bytes
            ImagePickerPreviewWidget(
              imageData: _pickedImageData,
              onPickImage: _pickImage,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(_editingEvent == null ? 'Create Event' : 'Update Event'),
              style: ElevatedButton.styleFrom(backgroundColor: DeepBlue, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16)),
            ),
            if (_editingEvent != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
                  onPressed: _resetForm,
                  child: Text('Cancel Edit', style: TextStyle(color: DeepBlue)),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventResponse event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({Key? key, required this.event, required this.onEdit, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (event.imageUri != null && event.imageUri!.isNotEmpty) {
      if (kIsWeb && event.imageUri!.startsWith('blob:')) {
        imageWidget = Image.network(event.imageUri!, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, o, s) => Icon(Icons.broken_image, size: 40));
      } else if (!kIsWeb && File(event.imageUri!).existsSync()) {
        imageWidget = Image.file(File(event.imageUri!), width: 80, height: 80, fit: BoxFit.cover);
      } else if (event.imageUri!.startsWith('http')) {
         imageWidget = CachedNetworkImage(
            imageUrl: event.imageUri!,
            placeholder: (context, url) => Container(width: 80, height: 80, child: Center(child: CircularProgressIndicator())),
            errorWidget: (context, url, error) => Container(width: 80, height: 80, child: Icon(Icons.broken_image, size: 40)),
            width: 80, height: 80, fit: BoxFit.cover,
        );
      } else {
        imageWidget = Container(width: 80, height: 80, child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)); // Placeholder for unknown path type
      }
    } else {
      imageWidget = Container(width: 80, height: 80, child: Icon(Icons.event, size: 40, color: DeepBlue));
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            imageWidget,
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(event.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DeepBlue)),
                  SizedBox(height: 4),
                  Text('Date: ${event.date} at ${event.time}', style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 4),
                  Text('Location: ${event.location}', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                IconButton(icon: Icon(Icons.edit, color: Colors.orange), onPressed: onEdit),
                IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
              ],
            )
          ],
        ),
      ),
    );
  }
}
