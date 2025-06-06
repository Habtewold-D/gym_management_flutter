import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/features/admin/presentation/providers/admin_event_provider.dart';
import 'package:gym_management_flutter/features/admin/presentation/widgets/image_picker_preview_widget.dart';
import 'package:gym_management_flutter/utils/image_picker_util.dart';
import 'package:intl/intl.dart';

// Color constants
const DeepBlue = Color(0xFF0000CD);
const LightBlue = Color(0xFFE6E9FD);
const Green = Color(0xFF4CAF50);

class EditEventScreen extends ConsumerStatefulWidget {
  final EventResponse? event;
  final int userId;

  const EditEventScreen({
    Key? key,
    this.event,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add New Event' : 'Edit Event'),
        backgroundColor: DeepBlue,
        foregroundColor: Colors.white,
      ),
      body: _EditEventForm(event: widget.event, userId: widget.userId),
    );
  }
}

class _EditEventForm extends ConsumerStatefulWidget {
  final EventResponse? event;
  final int userId;

  const _EditEventForm({
    Key? key,
    required this.event,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<_EditEventForm> createState() => _EditEventFormState();
}

class _EditEventFormState extends ConsumerState<_EditEventForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  Map<String, dynamic>? _pickedImageData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _dateController = TextEditingController(text: widget.event?.date ?? '');
    _timeController = TextEditingController(text: widget.event?.time ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    
    // Initialize with existing image if editing
    if (widget.event?.imageUri != null && widget.event!.imageUri!.isNotEmpty) {
      _pickedImageData = {'path': widget.event!.imageUri};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final imageData = await ImagePickerUtil.pickImageFromGallery();
      if (imageData != null) {
        setState(() {
          _pickedImageData = imageData;
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.event == null) {
        // Create new event
        final request = EventRequest(
          title: _titleController.text,
          date: _dateController.text,
          time: _timeController.text,
          location: _locationController.text,
          imageUri: _pickedImageData?['path'] as String?,
          createdBy: widget.userId,
        );
        
        await ref.read(adminEventNotifierProvider.notifier).createEvent(request);
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // Update existing event
        final request = EventUpdateRequest(
          id: widget.event!.id,
          title: _titleController.text,
          date: _dateController.text,
          time: _timeController.text,
          location: _locationController.text,
          imageUri: _pickedImageData?['path'] as String?,
        );
        
        await ref.read(adminEventNotifierProvider.notifier).updateEvent(request);
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Title Field
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 20),
          
          // Image Picker
          Text('Event Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImagePickerPreviewWidget(
                imageData: _pickedImageData,
                onPickImage: _pickImage,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 20),
          
          // Date Picker
          TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: _selectDate,
            decoration: InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
          ),
          const SizedBox(height: 16),
          
          // Time Picker
          TextFormField(
            controller: _timeController,
            readOnly: true,
            onTap: _selectTime,
            decoration: InputDecoration(
              labelText: 'Time',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please select a time' : null,
          ),
          const SizedBox(height: 16),
          
          // Location Field
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
          ),
          const SizedBox(height: 24),
          
          // Submit Button
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
                  : Text(
                      widget.event == null ? 'Create Event' : 'Update Event',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
