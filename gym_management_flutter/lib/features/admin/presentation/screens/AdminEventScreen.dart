import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart'; // For image loading
import 'package:gym_management_flutter/core/models/event_model.dart'; // fixed import
import 'package:gym_management_flutter/utils/image_picker_util.dart';  // fixed import (hypothetical)
import '../providers/admin_provider.dart';
import 'package:gym_management_flutter/core/services/admin_service.dart'; // Import AdminService

// Define color constants as in the Compose file
const DeepBlue = Color(0xFF0000CD);
const LightBlue = Color(0xFFE6E9FD);
const Green = Color(0xFF4CAF50);

class AdminEventScreen extends ConsumerStatefulWidget {
  final int userId; // changed type to int
  const AdminEventScreen({Key? key, required this.userId}) : super(key: key);
  
  @override
  _AdminEventScreenState createState() => _AdminEventScreenState();
}

class _AdminEventScreenState extends ConsumerState<AdminEventScreen> {
  bool showEditDialog = false;
  EventResponse? selectedEvent;
  
  // Controllers for event form
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  String? imageUri;
  
  late Future<List<dynamic>> _eventsFuture;
  
  // Modify fetchEvents() to use AdminService for token
  Future<List<dynamic>> fetchEvents() async {
    final adminService = AdminService();
    final headers = await adminService.getHeaders();
    final response = await http.get(
      Uri.parse('${adminService.baseUrl}/events'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load events: ${response.statusCode} ${response.body}');
    }
  }
  
  @override
  void initState() {
    super.initState();
    // Load events on startup
    _eventsFuture = fetchEvents();
    Future.microtask(() {
      ref.read(adminProvider.notifier).loadEvents();
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshEvents() async {
    setState(() {
      _eventsFuture = fetchEvents();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final events = ref.watch(adminProvider.select((p) => p.events));
    final isLoading = ref.watch(adminProvider.select((p) => p.isLoading));
    final error = ref.watch(adminProvider.select((p) => p.error));
    final successMessage = ref.watch(adminProvider.select((p) => p.successMessage));
    final validationError = ref.watch(adminProvider.select((p) => p.validationError));
    
    if (successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
        ref.read(adminProvider.notifier).setSuccessMessage(null);
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Events"),
        backgroundColor: const Color(0xFF241A87),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEvents,
        child: FutureBuilder<List<dynamic>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return const Center(child: Text('No events found'));
            
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(event['title'] ?? 'No Title'),
                    subtitle: Text(event['description'] ?? ''),
                    trailing: Text('By: ${event['createdBy'] ?? '-'}'),
                    onTap: () {
                      // Show event details
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(event['title'] ?? 'Event Details'),
                          content: Text(jsonEncode(event)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF241A87),
        child: const Icon(Icons.add),
        onPressed: () {
          // Show UI for event creation
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Create Event"),
              content: const Text("Event creation UI goes here."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

bool isEventFormValid(EventRequest request) {
  return request.title.isNotEmpty &&
         request.date.isNotEmpty &&
         request.time.isNotEmpty &&
         request.location.isNotEmpty;
}

@immutable
class EventForm extends StatelessWidget {
  final Function(EventRequest) onEventCreated;
  final TextEditingController titleController;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController locationController;
  final Function(String) onImagePicked;
  final int userId;
  
  const EventForm({
    Key? key,
    required this.onEventCreated,
    required this.titleController,
    required this.dateController,
    required this.timeController,
    required this.locationController,
    required this.onImagePicked,
    required this.userId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // For image picking, we assume a utility similar to ImagePicker (implementation not shown)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            // Launch image picker and get a saved path
            final imageResult = await ImagePickerUtil.pickImage(context);
            if (imageResult != null) {
              // Ensure kIsWeb is available, import 'package:flutter/foundation.dart'; if not.
              final String? imagePathString = kIsWeb 
                  ? (imageResult['blobUrl'] as String?) 
                  : (imageResult['path'] as String?);
              if (imagePathString != null) {
                onImagePicked(imagePathString);
              }
            }
          },
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF9DB7F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: imageUriWidget(),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedTextField(
          controller: titleController,
          label: "Event title",
          placeholder: "Enter title",
        ),
        const SizedBox(height: 8),
        OutlinedTextField(
          controller: dateController,
          label: "Date",
          placeholder: "Enter date",
        ),
        const SizedBox(height: 8),
        OutlinedTextField(
          controller: timeController,
          label: "Time",
          placeholder: "Enter time",
        ),
        const SizedBox(height: 8),
        OutlinedTextField(
          controller: locationController,
          label: "Location",
          placeholder: "Enter location",
        ),
        const SizedBox(height: 16),
        Button(
          onPressed: () {
            final request = EventRequest(
              title: titleController.text,
              date: dateController.text,
              time: timeController.text,
              location: locationController.text,
              imageUri: null, // You can pass on the image URI here if available.
              createdBy: userId,
            );
            onEventCreated(request);
          },
          child: const Text("Create", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
  
  Widget imageUriWidget() {
    // A placeholder widget for image preview
    // You could check if an image URI exists and then build an image widget.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.image, size: 48, color: DeepBlue),
          SizedBox(height: 8),
          Text("Tap to add an image", style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

@immutable
class OutlinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  
  const OutlinedTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.placeholder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: DeepBlue),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: LightBlue),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      keyboardType: TextInputType.text,
    );
  }
}

@immutable
class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  
  const Button({Key? key, required this.onPressed, required this.child, this.style}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}

// Dummy placeholder widgets for compilation:
Widget EventCard({required dynamic event}) =>
    Card(child: ListTile(title: Text(event.toString())));
Widget EditEventDialog({required dynamic event, required Function onConfirm}) =>
    AlertDialog(title: const Text("Edit Event"), content: const Text("Edit event details here"));
