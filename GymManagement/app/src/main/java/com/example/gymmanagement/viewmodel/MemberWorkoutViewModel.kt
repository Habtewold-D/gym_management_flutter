package com.example.gymmanagement.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gymmanagement.data.model.WorkoutResponse
import com.example.gymmanagement.data.repository.WorkoutRepository
import com.example.gymmanagement.data.repository.WorkoutRepositoryImpl
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn

class MemberWorkoutViewModel(
    private val workoutRepository: WorkoutRepository = WorkoutRepositoryImpl()
) : ViewModel() {
    private val TAG = "MemberWorkoutViewModel"
    
    private val _workouts = MutableStateFlow<List<WorkoutResponse>>(emptyList())
    val workouts: StateFlow<List<WorkoutResponse>> = _workouts.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    val progress: StateFlow<Float> = _workouts
        .map { list ->
            if (list.isEmpty()) 0f
            else list.count { it.isCompleted }.toFloat() / list.size
        }
        .stateIn(viewModelScope, SharingStarted.Eagerly, 0f)

    fun loadWorkouts(userId: Int) {
        Log.d(TAG, "Loading workouts for current user")
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                Log.d(TAG, "Making API call to get user workouts")
                workoutRepository.getUserWorkouts(userId).onSuccess { workoutList ->
                    Log.d(TAG, "Successfully loaded ${workoutList.size} workouts")
                    _workouts.value = workoutList
                }.onFailure { e ->
                    Log.e(TAG, "Failed to load workouts", e)
                    _error.value = e.message ?: "Failed to load workouts"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error while loading workouts", e)
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
                Log.d(TAG, "Finished loading workouts")
            }
        }
    }

    fun toggleWorkoutCompletion(workoutId: Int) {
        Log.d(TAG, "Toggling completion for workout ID: $workoutId")
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                Log.d(TAG, "Making API call to toggle workout completion")
                workoutRepository.toggleWorkoutCompletion(workoutId).onSuccess { updatedWorkout ->
                    Log.d(TAG, "Successfully updated workout completion status")
                    _workouts.value = _workouts.value.map { 
                        if (it.id == workoutId) updatedWorkout else it 
                    }
                }.onFailure { e ->
                    Log.e(TAG, "Failed to update workout completion", e)
                    _error.value = e.message ?: "Failed to update workout"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error while toggling workout completion", e)
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
                Log.d(TAG, "Finished toggling workout completion")
            }
        }
    }
}