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
  bool _mounted = true;
  
  MemberEventsNotifier(this._memberService) : super(const MemberEventsState());

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadEvents() async {
    if (!_mounted) return;
    
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final events = await _memberService.getMemberEvents();
      
      if (!_mounted) return;
      
      state = state.copyWith(
        events: events,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      if (!_mounted) return;
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
