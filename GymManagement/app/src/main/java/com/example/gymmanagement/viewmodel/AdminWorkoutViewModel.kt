package com.example.gymmanagement.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gymmanagement.data.model.WorkoutRequest
import com.example.gymmanagement.data.model.WorkoutResponse
import com.example.gymmanagement.data.model.WorkoutUpdateRequest
import com.example.gymmanagement.data.repository.WorkoutRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class AdminWorkoutViewModel(
    private val workoutRepository: WorkoutRepository
) : ViewModel() {
    private val TAG = "AdminWorkoutViewModel"

    private val _workouts = MutableStateFlow<List<WorkoutResponse>>(emptyList())
    val workouts: StateFlow<List<WorkoutResponse>> = _workouts.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    fun loadAllWorkouts() {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                Log.d(TAG, "Loading all workouts")
                workoutRepository.getAllWorkouts().onSuccess { workoutList ->
                    Log.d(TAG, "Successfully loaded ${workoutList.size} workouts")
                    workoutList.forEach { Log.d(TAG, "Workout id: ${it.id}, userId: ${it.userId}") }
                    _workouts.value = workoutList
                }.onFailure { e ->
                    Log.e(TAG, "Failed to load workouts: ${e.message}", e)
                    _error.value = e.message ?: "Failed to load workouts"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error loading workouts: ${e.message}", e)
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun createWorkout(workout: WorkoutRequest) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                Log.d(TAG, "Creating new workout")
                workoutRepository.createWorkout(workout).onSuccess { newWorkout ->
                    _workouts.value = _workouts.value + newWorkout
                    Log.d(TAG, "Successfully created workout")
                }.onFailure { e ->
                    Log.e(TAG, "Failed to create workout", e)
                    _error.value = e.message ?: "Failed to create workout"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error creating workout", e)
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun updateWorkout(workout: WorkoutUpdateRequest) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                Log.d(TAG, "Updating workout")
                workoutRepository.updateWorkout(workout).onSuccess { updatedWorkout ->
                    _workouts.value = _workouts.value.map { 
                        if (it.id == updatedWorkout.id) updatedWorkout else it 
                    }
                    Log.d(TAG, "Successfully updated workout")
                }.onFailure { e ->
                    Log.e(TAG, "Failed to update workout", e)
                    _error.value = e.message ?: "Failed to update workout"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error updating workout", e)
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun deleteWorkout(workoutId: Int) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                Log.d(TAG, "Deleting workout: $workoutId")
                workoutRepository.deleteWorkout(workoutId).onSuccess {
                    _workouts.value = _workouts.value.filter { it.id != workoutId }
                    Log.d(TAG, "Successfully deleted workout")
                }.onFailure { e ->
                    Log.e(TAG, "Failed to delete workout", e)
                    _error.value = e.message ?: "Failed to delete workout"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error deleting workout", e)
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }
}