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
        title: const Text('Upcoming Events'),
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
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadEvents,
          ),
        ],
      ),
      body: _isLoading && events.isEmpty
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
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with overlay
            if (event.imageUri != null && event.imageUri!.isNotEmpty)
              Image.network(
                event.imageUri!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(Icons.event, size: 50, color: Colors.grey),
                ),
              )
            else
              Container(
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.event, size: 50, color: Colors.grey),
              ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Date Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(dateTime).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Event Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Time and Location
                  if (event.time != null || event.location != null)
                    Row(
                      children: [
                        if (event.time != null) ...[
                          _buildPill(
                            icon: Icons.access_time,
                            text: event.time!,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (event.location != null)
                          Expanded(
                            child: _buildPill(
                              icon: Icons.location_on,
                              text: event.location!,
                              isLocation: true,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPill({
    required IconData icon,
    required String text,
    bool isLocation = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black87),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
