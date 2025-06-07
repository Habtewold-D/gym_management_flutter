import 'dart:developer';

import 'package:dio/dio.dart';
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
  bool _isDisposed = false;
  
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
      final workouts = await _memberService.getMemberWorkouts();
      _updateState(state.copyWith(
        isLoading: false,
        workouts: workouts,
        error: null,
      ));
    } on DioException catch (e) {
      final errorMessage = e.response?.statusCode == 401 
          ? 'Session expired. Please log in again.'
          : e.message ?? 'Failed to load workouts';
          
      _updateState(state.copyWith(
        isLoading: false,
        error: errorMessage,
      ));
      
      if (e.response?.statusCode == 401) {
        // Trigger logout or token refresh if needed
      }
      
      log('Error loading workouts: $errorMessage', error: e, stackTrace: e.stackTrace);
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      log('Unexpected error loading workouts', error: e, stackTrace: stackTrace);
    }
  }
  
  Future<void> refreshWorkouts() async {
    _updateState(state.copyWith(
      isLoading: true,
      error: null,
    ));
    await loadWorkouts();
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _updateState(MemberWorkoutState newState) {
    if (!_isDisposed) {
      state = newState;
    }
  }

  Future<void> markWorkoutAsCompleted(String workoutId, bool isCompleted) async {
    if (_authState.user == null) {
      _updateState(state.copyWith(error: 'Authentication required'));
      return;
    }
    
    // Add workoutId to the set of completing workouts
    final updatedCompletingWorkouts = Set<String>.from(state.completingWorkoutIds)..
        add(workoutId);
    _updateState(state.copyWith(completingWorkoutIds: updatedCompletingWorkouts));

    // Store the current state for potential rollback
    final currentWorkouts = List<WorkoutResponse>.from(state.workouts);
    
    try {
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
      
      _updateState(state.copyWith(workouts: updatedWorkouts));
      
      try {
        // Call the API to mark workout as completed
        await _memberService.markWorkoutAsCompleted(workoutId, isCompleted);
        
        // Refresh the workouts list to ensure consistency
        await loadWorkouts();
      } on DioException catch (e) {
        // Rollback on error
        _updateState(state.copyWith(workouts: currentWorkouts));
        
        String errorMessage;
        if (e.response?.statusCode == 401) {
          errorMessage = 'Session expired. Please log in again.';
          // Trigger logout or token refresh if needed
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'You do not have permission to update this workout';
        } else {
          errorMessage = 'Failed to update workout status: ${e.message}';
        }
        
        _updateState(state.copyWith(error: errorMessage));
        log('Error updating workout status: $errorMessage', error: e, stackTrace: e.stackTrace);
        rethrow;
      } finally {
        // Remove workoutId from the set of completing workouts regardless of success or failure
        final finalCompletingWorkouts = Set<String>.from(state.completingWorkoutIds)..
            remove(workoutId);
        _updateState(state.copyWith(completingWorkoutIds: finalCompletingWorkouts));
      }
    } catch (e, stackTrace) {
      log('Error in markWorkoutAsCompleted: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

class MemberWorkoutState {
  final bool isLoading;
  final String? error;
  final List<WorkoutResponse> workouts;
  final Set<String> completingWorkoutIds;

  const MemberWorkoutState({
    this.isLoading = false,
    this.error,
    this.workouts = const [],
    this.completingWorkoutIds = const {},
  });

  MemberWorkoutState copyWith({
    bool? isLoading,
    String? error,
    List<WorkoutResponse>? workouts,
    Set<String>? completingWorkoutIds,
  }) {
    return MemberWorkoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      workouts: workouts ?? this.workouts,
      completingWorkoutIds: completingWorkoutIds ?? this.completingWorkoutIds,
    );
  }
  
  bool get hasError => error != null;
  bool get hasWorkouts => workouts.isNotEmpty;

  bool isCompletingWorkout(String workoutId) {
    return completingWorkoutIds.contains(workoutId);
  }
}
