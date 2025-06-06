import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/core/services/admin_service.dart';
import 'package:gym_management_flutter/features/admin/presentation/providers/admin_provider.dart'; // For adminServiceProvider

// State definition
class AdminEventState {
  final bool isLoading;
  final List<EventResponse> events;
  final String? error;
  final String? successMessage;

  AdminEventState({
    this.isLoading = false,
    this.events = const [],
    this.error,
    this.successMessage,
  });

  AdminEventState copyWith({
    bool? isLoading,
    List<EventResponse>? events,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return AdminEventState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      error: clearError ? null : error ?? this.error,
      successMessage: clearSuccessMessage ? null : successMessage ?? this.successMessage,
    );
  }
}

// Notifier definition
class AdminEventNotifier extends StateNotifier<AdminEventState> {
  final AdminService _adminService;

  AdminEventNotifier(this._adminService) : super(AdminEventState()) {
    loadEvents(); // Initial load
  }

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccessMessage: true);
    try {
      final events = await _adminService.getEvents();
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createEvent(EventRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccessMessage: true);
    try {
      await _adminService.createEvent(request);
      await loadEvents(); // Refresh list
      state = state.copyWith(isLoading: false, successMessage: 'Event created successfully.');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow; 
    }
  }

  Future<void> updateEvent(EventUpdateRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccessMessage: true);
    try {
      await _adminService.updateEvent(request);
      await loadEvents(); // Refresh list
      state = state.copyWith(isLoading: false, successMessage: 'Event updated successfully.');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteEvent(int eventId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccessMessage: true);
    try {
      await _adminService.deleteEvent(eventId);
      await loadEvents(); // Refresh list
      state = state.copyWith(isLoading: false, successMessage: 'Event deleted successfully.');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccessMessage: true);
  }
}

// Provider definition
final adminEventNotifierProvider = StateNotifierProvider<AdminEventNotifier, AdminEventState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminEventNotifier(adminService);
});
