import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/features/member/presentation/providers/member_events_provider.dart';

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
    _loadEvents();
  }
  Future<void> _loadEvents() async {
    try {
      final eventsProvider = ref.read(memberEventsProvider.notifier);
      await eventsProvider.loadEvents();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Failed to load events: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(memberEventsProvider);
    final isLoading = eventsState.isLoading;
    final error = eventsState.error;
    final events = eventsState.events;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Upcoming Events'),
            backgroundColor: const Color(0xFF0000CD),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: isLoading ? null : _loadEvents,
              ),
            ],
          ),
          body: isLoading && events.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadEvents,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : events.isEmpty
                      ? const Center(child: Text('No upcoming events'))
                      : RefreshIndicator(
                      onRefresh: _loadEvents,
                      child: ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final eventDate = DateTime.tryParse(event.date) ?? DateTime.now();
                          final eventTime = event.time ?? '12:00';
                          final dateTime = DateTime(
                            eventDate.year,
                            eventDate.month,
                            eventDate.day,
                            int.tryParse(eventTime.split(':')[0]) ?? 0,
                            int.tryParse(eventTime.split(':')[1]) ?? 0,
                          );
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: event.imageUri != null
                                  ? Image.network(
                                      event.imageUri!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                          const Icon(Icons.event, size: 50),
                                    )
                                  : const Icon(Icons.event, size: 50),
                              title: Text(
                                event.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('MMM d, y • h:mm a').format(dateTime)),
                                  if (event.location != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Location: ${event.location}'),
                                  ],
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                          );
                        },
                      ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventDate = DateTime.tryParse(event.date) ?? DateTime.now();
    final eventTime = event.time ?? '12:00';
    final dateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      int.tryParse(eventTime.split(':')[0]) ?? 0,
      int.tryParse(eventTime.split(':')[1]) ?? 0,
    );
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (event.imageUri != null)
            Image.network(
              event.imageUri!,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 50),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(dateTime),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (event.time != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        event.time!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                if (event.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
