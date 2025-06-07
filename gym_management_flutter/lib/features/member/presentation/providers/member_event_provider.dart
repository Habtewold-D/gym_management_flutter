import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/core/services/member_service.dart';

final memberEventProvider = StateNotifierProvider<MemberEventNotifier, MemberEventState>((ref) {
  final memberService = ref.watch(memberServiceProvider);
  return MemberEventNotifier(memberService);
});

class MemberEventNotifier extends StateNotifier<MemberEventState> {
  final MemberService _memberService;

  MemberEventNotifier(this._memberService) : super(MemberEventState());

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _memberService.getMemberEvents();
      state = state.copyWith(
        isLoading: false,
        events: events,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> registerForEvent(String eventId) async {
    try {
      await _memberService.registerForEvent(eventId);
      // Refresh events after registration
      await loadEvents();
    } catch (e) {
      rethrow;
    }
  }
}

class MemberEventState {
  final bool isLoading;
  final String? error;
  final List<EventResponse> events;

  MemberEventState({
    this.isLoading = false,
    this.error,
    List<EventResponse>? events,
  }) : events = events ?? [];

  MemberEventState copyWith({
    bool? isLoading,
    String? error,
    List<EventResponse>? events,
  }) {
    return MemberEventState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      events: events ?? this.events,
    );
  }
}
