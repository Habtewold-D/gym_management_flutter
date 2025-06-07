import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/core/services/member_service.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';

final memberWorkoutProvider = StateNotifierProvider<MemberWorkoutNotifier, MemberWorkoutState>((ref) {
  final memberService = ref.watch(memberServiceProvider);
  final authState = ref.watch(authProvider);
  return MemberWorkoutNotifier(memberService, authState);
});

class MemberWorkoutNotifier extends StateNotifier<MemberWorkoutState> {
  final MemberService _memberService;
  final AuthState _authState;
  
  MemberWorkoutNotifier(this._memberService, this._authState) : super(MemberWorkoutState()) {
    // Load workouts immediately if we're already authenticated
    if (_authState.user != null) {
      loadWorkouts();
    }
  }

  Future<void> loadWorkouts() async {
    if (state.isLoading) return;
    
    // Check if user is authenticated
    if (_authState.user == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Authentication required',
      );
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final workouts = await _memberService.getMemberWorkouts(userId: _authState.user!.id.toString());
      state = state.copyWith(
        isLoading: false,
        workouts: workouts,
        error: null,
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      log('Error loading workouts: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  Future<void> refreshWorkouts() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );
    await loadWorkouts();
  }
  
  Future<void> markWorkoutAsCompleted(String workoutId, bool isCompleted) async {
    if (_authState.user == null) {
      state = state.copyWith(error: 'Authentication required');
      return;
    }
    
    try {
      // Store the current state for potential rollback
      final currentWorkouts = List<WorkoutResponse>.from(state.workouts);
      
      // Update the local state optimistically
      final updatedWorkouts = state.workouts.map((workout) {
        if (workout.id.toString() == workoutId) {
          return WorkoutResponse(
            id: workout.id,
            eventTitle: workout.eventTitle,
            sets: workout.sets,
            repsOrSecs: workout.repsOrSecs,
            restTime: workout.restTime,
            imageUri: workout.imageUri,
            isCompleted: isCompleted,
            createdAt: workout.createdAt,
            updatedAt: workout.updatedAt,
            userId: workout.userId,
            notes: workout.notes,
          );
        }
        return workout;
      }).toList();
      
      state = state.copyWith(workouts: updatedWorkouts);
      
      try {
        // Call the API to update the workout status
        await _memberService.updateWorkoutStatus(
          workoutId: workoutId, 
          isCompleted: isCompleted,
          userId: _authState.user!.id.toString(),
        );
        
        // Refresh the workouts list to ensure we have the latest data
        await loadWorkouts();
        
      } catch (e) {
        // Revert to previous state if API call fails
        state = state.copyWith(workouts: currentWorkouts);
        rethrow;
      }
      
    } catch (e, stackTrace) {
      state = state.copyWith(error: 'Failed to update workout status: ${e.toString()}');
      log('Error marking workout as completed: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

class MemberWorkoutState {
  final bool isLoading;
  final String? error;
  final List<WorkoutResponse> workouts;

  const MemberWorkoutState({
    this.isLoading = false,
    this.error,
    this.workouts = const [],
  });

  MemberWorkoutState copyWith({
    bool? isLoading,
    String? error,
    List<WorkoutResponse>? workouts,
  }) {
    return MemberWorkoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      workouts: workouts ?? this.workouts,
    );
  }
  
  bool get hasError => error != null;
  bool get hasWorkouts => workouts.isNotEmpty;
}
