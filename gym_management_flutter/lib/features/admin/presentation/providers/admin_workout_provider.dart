import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/core/services/admin_service.dart';
import 'package:gym_management_flutter/features/admin/presentation/providers/admin_provider.dart'; // adminServiceProvider is defined here

// State definition
class AdminWorkoutState {
  final bool isLoading;
  final List<WorkoutResponse> workouts;
  final String? error;

  AdminWorkoutState({
    this.isLoading = false,
    this.workouts = const [],
    this.error,
  });

  AdminWorkoutState copyWith({
    bool? isLoading,
    List<WorkoutResponse>? workouts,
    String? error,
    bool clearError = false,
  }) {
    return AdminWorkoutState(
      isLoading: isLoading ?? this.isLoading,
      workouts: workouts ?? this.workouts,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// Notifier definition
class AdminWorkoutNotifier extends StateNotifier<AdminWorkoutState> {
  final AdminService _adminService;

  AdminWorkoutNotifier(this._adminService) : super(AdminWorkoutState()) {
    loadWorkouts(); // Initial load
  }

  Future<void> loadWorkouts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final workouts = await _adminService.getWorkouts();
      state = state.copyWith(isLoading: false, workouts: workouts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createWorkout(WorkoutRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _adminService.createWorkout(request);
      await loadWorkouts(); // Refresh list
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      // Re-throw to allow UI to catch and display specific messages if needed
      // Or handle more gracefully here by not re-throwing and just setting error state
      rethrow; 
    }
  }

  Future<void> updateWorkout(WorkoutUpdateRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _adminService.updateWorkout(request);
      await loadWorkouts(); // Refresh list
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteWorkout(int workoutId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _adminService.deleteWorkout(workoutId);
      await loadWorkouts(); // Refresh list
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

// Provider definition
final adminWorkoutNotifierProvider = StateNotifierProvider<AdminWorkoutNotifier, AdminWorkoutState>((ref) {
  final adminService = ref.watch(adminServiceProvider); // Assuming adminServiceProvider is correctly defined
  return AdminWorkoutNotifier(adminService);
});
