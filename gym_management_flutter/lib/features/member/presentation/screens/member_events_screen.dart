import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/features/member/presentation/providers/member_events_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

// Helper function to show error SnackBar
void _showErrorSnackBar(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Helper function to show success SnackBar
void _showSuccessSnackBar(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class MemberEventsScreen extends ConsumerStatefulWidget {
  const MemberEventsScreen({super.key});

  @override
  ConsumerState<MemberEventsScreen> createState() => _MemberEventsScreenState();
}

class _MemberEventsScreenState extends ConsumerState<MemberEventsScreen> {
  @override
  void initState() {
    super.initState();
    // Delay the event loading until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  bool _isLoading = true;

  Future<void> _loadEvents() async {
    if (!mounted) return;
    
    try {
      await ref.read(memberEventsProvider.notifier).loadEvents();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Failed to load events: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(memberEventsProvider);
    final error = eventsState.error;
    final events = eventsState.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gym Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0000CD),
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _loadEvents,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0000CD),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Text(
              'Join us for these exciting events',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: _isLoading && events.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load events',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _loadEvents,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : events.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No upcoming events',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await _loadEvents();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                
                                return EventCard(event: event);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends ConsumerWidget {
  final EventResponse event;

  const EventCard({
    Key? key,
    required this.event,
  }) : super(key: key);

  Widget _buildPlaceholderImage() {
    return Container(
      height: 150,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.event, size: 50, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventDate = DateTime.tryParse(event.date) ?? DateTime.now();
    final eventTime = event.time ?? '00:00';
    final dateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      int.tryParse(eventTime.split(':')[0]) ?? 0,
      int.tryParse(eventTime.split(':')[1]) ?? 0,
    );

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
                    _buildPill(Icons.calendar_today, DateFormat('M/d/yyyy').format(eventDate)),
                    const SizedBox(height: 4),
                    _buildPill(Icons.access_time, DateFormat('h:mm a').format(dateTime)),
                    const SizedBox(height: 4),
                    _buildPill(Icons.location_on, event.location ?? ''),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
}
