import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/features/admin/presentation/providers/admin_event_provider.dart';
import 'package:gym_management_flutter/features/admin/presentation/screens/edit_event_screen.dart';
import 'package:gym_management_flutter/features/admin/presentation/widgets/image_picker_preview_widget.dart';
import 'package:gym_management_flutter/utils/image_picker_util.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Color constants
const DeepBlue = Color(0xFF0000CD);
const LightBlue = Color(0xFFE6E9FD);

class EventCard extends StatelessWidget {
  final EventResponse event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({Key? key, required this.event, required this.onEdit, required this.onDelete}) : super(key: key);

  Widget _buildPlaceholderImage() {
    return Container(
      height: 150,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.event, size: 50, color: Colors.grey)),
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (event.imageUri != null && event.imageUri!.isNotEmpty) {
      if (event.imageUri!.startsWith('http') || (kIsWeb && event.imageUri!.startsWith('blob'))) {
        imageWidget = Image.network(
          event.imageUri!,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
        );
      } else if (!kIsWeb) {
        final file = File(event.imageUri!);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            fit: BoxFit.cover,
            height: 150,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
          );
        } else {
          imageWidget = _buildPlaceholderImage();
        }
      } else {
        imageWidget = _buildPlaceholderImage();
      }
    } else {
      imageWidget = _buildPlaceholderImage();
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
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Pill
                Container(
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
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Column for Date, Time, Location Pills
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPill(Icons.calendar_today, event.date),
                    const SizedBox(height: 4),
                    _buildPill(Icons.access_time, event.time),
                    const SizedBox(height: 4),
                    _buildPill(Icons.location_on, event.location),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminEventScreen extends ConsumerStatefulWidget {
  final int userId;
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
  Map<String, dynamic>? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load events when the screen is first displayed
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
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
          _pickedImage = imageData;
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
      _pickedImage = null;
    });
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = EventRequest(
        title: _titleController.text,
        date: _dateController.text,
        time: _timeController.text,
        location: _locationController.text,
        imageUri: _pickedImage?['path'] as String?,
        createdBy: widget.userId,
      );
      
      await ref.read(adminEventNotifierProvider.notifier).createEvent(request);
      _titleController.clear();
      _dateController.clear();
      _timeController.clear();
      _locationController.clear();
      setState(() { _pickedImage = null; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: ${e.toString().replaceFirst("Exception: ", "")}') , backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditEvent(EventResponse event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventScreen(event: event, userId: widget.userId),
      ),
    ).then((_) => _refreshEvents());
  }

  void _deleteEvent(int eventId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
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
                  await ref.read(adminEventNotifierProvider.notifier).deleteEvent(eventId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event deleted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete event: ${e.toString().replaceFirst("Exception: ", "")}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshEvents() async {
    await ref.read(adminEventNotifierProvider.notifier).loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        backgroundColor: const Color(0xFF241A87),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminEventNotifierProvider.notifier).loadEvents(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Event Section
              const Text(
                "Add Event",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E9FD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFB3B9F8)),
                  ),
                  child: _pickedImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            kIsWeb
                                ? Image.network(_pickedImage!['path'], fit: BoxFit.cover)
                                : Image.file(File(_pickedImage!['path']), fit: BoxFit.cover),
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
                            Positioned(
                              top: 5,
                              left: 5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.menu, color: Colors.white, size: 20),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
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
                              "Tap to add event image",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date (YYYY-MM-DD)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        suffixIcon: Icon(Icons.calendar_today, size: 20),
                      ),
                      onTap: _selectDate,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time (HH:MM)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        suffixIcon: Icon(Icons.access_time, size: 20),
                      ),
                      onTap: _selectTime,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createEvent,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF241A87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Create Event',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Upcoming Events Section
              const Text(
                "Upcoming Events",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, watch, child) {
                  final eventState = ref.watch(adminEventNotifierProvider);
                  if (eventState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (eventState.error != null) {
                    return Center(child: Text('Error: ${eventState.error}'));
                  } else if (eventState.events.isEmpty) {
                    return const Center(child: Text('No upcoming events found.'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: eventState.events.length,
                      itemBuilder: (context, index) {
                        final event = eventState.events[index];
                        return EventCard(
                          event: event,
                          onEdit: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditEventScreen(event: event, userId: widget.userId)));
                          },
                          onDelete: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete "${event.title}"?'),
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
                                await ref.read(adminEventNotifierProvider.notifier).deleteEvent(event.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Event deleted successfully')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error deleting event: $e')),
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
