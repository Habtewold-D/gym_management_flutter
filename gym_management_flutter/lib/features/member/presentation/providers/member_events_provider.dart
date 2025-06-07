import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/core/services/member_service.dart';

// State class for member events
class MemberEventsState {
  final List<EventResponse> events;
  final bool isLoading;
  final String? error;

  const MemberEventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
  });

  MemberEventsState copyWith({
    List<EventResponse>? events,
    bool? isLoading,
    String? error,
  }) {
    return MemberEventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Provider for member events state
final memberEventsProvider = StateNotifierProvider<MemberEventsNotifier, MemberEventsState>((ref) {
  final memberService = ref.watch(memberServiceProvider);
  return MemberEventsNotifier(memberService);
});

class MemberEventsNotifier extends StateNotifier<MemberEventsState> {
  final MemberService _memberService;
  
  MemberEventsNotifier(this._memberService) : super(const MemberEventsState());

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final events = await _memberService.getMemberEvents();
      state = state.copyWith(
        events: events,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}
