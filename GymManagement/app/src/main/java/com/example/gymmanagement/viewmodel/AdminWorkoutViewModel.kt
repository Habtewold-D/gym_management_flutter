//package com.example.gymmanagement.viewmodel
//
//import android.app.Application
//import android.net.Uri
//import androidx.lifecycle.AndroidViewModel
//import androidx.lifecycle.viewModelScope
//import com.example.gymmanagement.data.repository.WorkoutRepository
//import com.example.gymmanagement.utils.ImagePicker
//import kotlinx.coroutines.flow.SharingStarted
//import kotlinx.coroutines.flow.StateFlow
//import kotlinx.coroutines.flow.stateIn
//import kotlinx.coroutines.launch
//import androidx.lifecycle.ViewModel
//import androidx.lifecycle.ViewModelProvider
//import kotlinx.coroutines.flow.MutableStateFlow
//import kotlinx.coroutines.flow.asStateFlow
//import com.example.gymmanagement.data.model.Workout
//
//class AdminWorkoutViewModel(
//    private val repository: WorkoutRepository,
//    private val imagePicker: ImagePicker
//) : ViewModel() {
//    private val _selectedWorkout = MutableStateFlow<Workout?>(null)
//    val selectedWorkout: StateFlow<Workout?> = _selectedWorkout.asStateFlow()
//
//    private val _imagePath = MutableStateFlow<String?>(null)
//    val imagePath: StateFlow<String?> = _imagePath.asStateFlow()
//
//    val workouts: StateFlow<List<Workout>> = repository.getAllWorkouts()
//        .stateIn(
//            scope = viewModelScope,
//            started = SharingStarted.WhileSubscribed(5000),
//            initialValue = emptyList()
//        )
//
//    fun selectWorkout(workoutId: Int) {
//        viewModelScope.launch {
//            _selectedWorkout.value = repository.getWorkoutById(workoutId)
//        }
//    }
//
//    fun insertWorkout(workout: Workout) {
//        viewModelScope.launch {
//            repository.insertWorkout(workout)
//        }
//    }
//
//    fun updateWorkout(workout: Workout) {
//        viewModelScope.launch {
//            repository.updateWorkout(workout)
//        }
//    }
//
//    fun deleteWorkout(workout: Workout) {
//        viewModelScope.launch {
//            repository.deleteWorkout(workout)
//        }
//    }
//
//    fun handleImageSelection(uri: Uri): String? {
//        val savedPath = imagePicker.saveImageToInternalStorage(uri)
//        _imagePath.value = savedPath
//        return savedPath
//    }
//
//    fun setImagePath(path: String?) {
//        _imagePath.value = path
//    }
//
//    class Factory(
//        private val repository: WorkoutRepository,
//        private val imagePicker: ImagePicker
//    ) : ViewModelProvider.Factory {
//        @Suppress("UNCHECKED_CAST")
//        override fun <T : ViewModel> create(modelClass: Class<T>): T {
//            if (modelClass.isAssignableFrom(AdminWorkoutViewModel::class.java)) {
//                return AdminWorkoutViewModel(repository, imagePicker) as T
//            }
//            throw IllegalArgumentException("Unknown ViewModel class")
//        }
//    }
//}