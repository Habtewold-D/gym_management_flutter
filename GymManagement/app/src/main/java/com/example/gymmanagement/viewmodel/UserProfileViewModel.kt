//package com.example.gymmanagement.viewmodel
//
//import android.app.Application
//import androidx.lifecycle.AndroidViewModel
//import androidx.lifecycle.ViewModel
//import androidx.lifecycle.ViewModelProvider
//import androidx.lifecycle.viewModelScope
//import com.example.gymmanagement.data.model.UserProfile
//import com.example.gymmanagement.data.model.UserProfile.UserProfile
//import com.example.gymmanagement.data.repository.UserRepository
//import kotlinx.coroutines.flow.*
//import kotlinx.coroutines.launch
//import kotlin.math.pow
//import kotlin.math.round
//
//class UserProfileViewModel(
//    application: Application,
//    private val repository: UserRepository
//) : AndroidViewModel(application) {
//    private val _isEditing = MutableStateFlow(false)
//    val isEditing: StateFlow<Boolean> = _isEditing
//
//    private val _userProfile = MutableStateFlow<UserProfile?>(null)
//    val userProfile: StateFlow<UserProfile?> = _userProfile.asStateFlow()
//
//    fun loadUserProfile(email: String) {
//        viewModelScope.launch {
//            _userProfile.value = repository.getUserProfileByEmail(email)
//        }
//    }
//
//    fun toggleEditing() {
//        _isEditing.value = !_isEditing.value
//    }
//
//    fun updateUserProfile(
//        email: String,
//        name: String,
//        phone: String? = null,
//        address: String? = null,
//        role: String
//    ) {
//        viewModelScope.launch {
//            repository.getUserProfileByEmail(email)?.let { existingProfile ->
//                val updatedProfile = existingProfile.copy(
//                    name = name,
//                    role = role
//                )
//                repository.updateUserProfile(updatedProfile)
//                _userProfile.value = updatedProfile
//            }
//        }
//    }
//
//    private fun calculateBMI(heightCm: Int, weightKg: Int): Double {
//        val heightM = heightCm / 100.0
//        val bmi = weightKg / (heightM.pow(2))
//        return round(bmi * 10) / 10
//    }
//
//    class Factory(
//        private val application: Application,
//        private val repository: UserRepository
//    ) : ViewModelProvider.Factory {
//        @Suppress("UNCHECKED_CAST")
//        override fun <T : ViewModel> create(modelClass: Class<T>): T {
//            if (modelClass.isAssignableFrom(UserProfileViewModel::class.java)) {
//                return UserProfileViewModel(application, repository) as T
//            }
//            throw IllegalArgumentException("Unknown ViewModel class")
//        }
//    }
//}