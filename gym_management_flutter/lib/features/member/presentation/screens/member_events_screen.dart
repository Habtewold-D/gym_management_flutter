import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/core/services/member_service.dart';
import 'package:gym_management_flutter/core/services/api_service.dart';
import 'package:gym_management_flutter/core/models/user_profile.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:gym_management_flutter/core/utils/snackbar_utils.dart';

class MemberEventsScreen extends ConsumerStatefulWidget {
  const MemberEventsScreen({Key? key}) : super(key: key);

  @override
  _MemberEventsScreenState createState() => _MemberEventsScreenState();
}

class _MemberEventsScreenState extends ConsumerState<MemberEventsScreen> {
  List<EventResponse> _events = [];
  bool _isLoading = true;
  String? _error;
  final MemberService _memberService = MemberService(ApiService());

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _memberService.getMemberEvents();
      setState(() {
        _events = events;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        showErrorSnackBar(context, 'Failed to load events: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEventRegistration(String eventId) async {
    try {
      await _memberService.registerForEvent(eventId);
      if (mounted) {
        showSuccessSnackBar(context, 'Successfully registered for the event!');
        await _loadEvents(); // Refresh the events list
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to register for event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        backgroundColor: const Color(0xFF0000CD),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEvents,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _events.isEmpty
                  ? const Center(child: Text('No upcoming events'))
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      child: ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return EventCard(
                            event: event,
                            onRegister: _handleEventRegistration,
                          );
                        },
                      ),
                    ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventResponse event;
  final Future<void> Function(String) onRegister;

  const EventCard({
    Key? key,
    required this.event,
    required this.onRegister,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (event.imageUrl != null)
            Image.network(
              event.imageUrl!,
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
                  event.title ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (event.date != null)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(event.date!),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                if (event.time != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          event.time!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                if (event.location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          event.location!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: event.isRegistered ?? false
                      ? null
                      : () => onRegister(event.id.toString()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: event.isRegistered ?? false
                        ? Colors.grey
                        : const Color(0xFF0000CD),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    event.isRegistered ?? false
                        ? 'Registered'
                        : 'Register for Event',
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
