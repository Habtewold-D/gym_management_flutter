//package com.example.gymmanagement.viewmodel
//
//import androidx.lifecycle.ViewModel
//import androidx.lifecycle.viewModelScope
//import com.example.gymmanagement.data.model.TraineeProgress
//import com.example.gymmanagement.data.repository.TraineeProgressRepository
//import kotlinx.coroutines.flow.*
//import kotlinx.coroutines.launch
//
//class AdminProgressViewModel(
//    private val repository: TraineeProgressRepository
//) : ViewModel() {
//    private val _allProgress = MutableStateFlow<List<TraineeProgress>>(emptyList())
//    val allProgress: StateFlow<List<TraineeProgress>> = _allProgress.asStateFlow()
//
//    init {
//        // Load initial progress data
//        loadProgress()
//    }
//
//    fun loadProgress() {
//        viewModelScope.launch {
//            repository.getAllProgress()
//                .collect { progressList ->
//                    _allProgress.value = progressList
//                }
//        }
//    }
//
//    fun updateProgress(progress: TraineeProgress) {
//        viewModelScope.launch {
//            repository.updateProgress(progress)
//            // Reload progress after update
//            loadProgress()
//        }
//    }
//
//    fun insertProgress(progress: TraineeProgress) {
//        viewModelScope.launch {
//            repository.insertProgress(progress)
//            // Reload progress after insert
//            loadProgress()
//        }
//    }
//
//    fun deleteProgress(progress: TraineeProgress) {
//        viewModelScope.launch {
//            repository.deleteProgress(progress)
//            // Reload progress after delete
//            loadProgress()
//        }
//    }
//}