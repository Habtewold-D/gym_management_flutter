package com.example.gymmanagement.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gymmanagement.data.model.TraineeProgress
import com.example.gymmanagement.data.repository.TraineeProgressRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class AdminProgressViewModel(
    private val traineeProgressRepository: TraineeProgressRepository
) : ViewModel() {
    private val _progress = MutableStateFlow<List<TraineeProgress>>(emptyList())
    val progress: StateFlow<List<TraineeProgress>> = _progress

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error

    init {
        loadProgress()
    }

    fun loadProgress() {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _error.value = null
                traineeProgressRepository.getAllProgress().onSuccess { progressList ->
                    _progress.value = progressList
                }.onFailure { e ->
                    _error.value = e.message ?: "Failed to load progress"
                }
            } catch (e: Exception) {
                _error.value = e.message ?: "Failed to load progress"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun getProgressByTraineeId(traineeId: Int) {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _error.value = null
                traineeProgressRepository.getProgressByTraineeId(traineeId).onSuccess { progress ->
                    _progress.value = listOf(progress)
                }.onFailure { e ->
                    _error.value = e.message ?: "Failed to load progress"
                }
            } catch (e: Exception) {
                _error.value = e.message ?: "Failed to load progress"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun updateProgress(traineeId: Int, completedWorkouts: Int, totalWorkouts: Int) {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _error.value = null
                traineeProgressRepository.updateProgress(traineeId, completedWorkouts, totalWorkouts)
                    .onSuccess { progress ->
                        // Update the list with the new progress
                        val currentList = _progress.value.toMutableList()
                        val index = currentList.indexOfFirst { it.userId == traineeId }
                        if (index != -1) {
                            currentList[index] = progress
                            _progress.value = currentList
                        }
                    }
                    .onFailure { e ->
                        _error.value = e.message ?: "Failed to update progress"
                    }
            } catch (e: Exception) {
                _error.value = e.message ?: "Failed to update progress"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun insertProgress(progress: TraineeProgress) {
        viewModelScope.launch {
            // Implement insert progress logic
        }
    }

    fun deleteProgress(progress: TraineeProgress) {
        viewModelScope.launch {
            // Implement delete progress logic
        }
    }
}