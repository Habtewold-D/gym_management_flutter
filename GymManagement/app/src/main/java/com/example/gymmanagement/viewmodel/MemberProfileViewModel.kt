package com.example.gymmanagement.viewmodel

import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gymmanagement.data.model.UserProfile
import com.example.gymmanagement.data.repository.UserRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class MemberProfileViewModel(
    private val context: Context,
    private val userRepository: UserRepository
) : ViewModel() {
    private val TAG = "MemberProfileViewModel"
    
    private val _userProfile = MutableStateFlow<UserProfile?>(null)
    val userProfile: StateFlow<UserProfile?> = _userProfile.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    fun getUserProfileByEmail(email: String) {
        Log.d(TAG, "Getting profile for email: $email")
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                Log.d(TAG, "Calling repository to get user profile")
                val profile = userRepository.getUserProfile(email)
                if (profile != null) {
                    Log.d(TAG, "Profile found: $profile")
                    _userProfile.value = profile
                } else {
                    Log.e(TAG, "Profile not found for email: $email")
                    _error.value = "Profile not found"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error getting profile", e)
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun updateUserProfileWithBMI(
        email: String,
        name: String,
        age: Int?,
        height: Float?,
        weight: Float?,
        role: String = "member"
    ) {
        Log.d(TAG, "updateUserProfileWithBMI called with - Email: $email, Name: $name, Age: $age, Height: $height, Weight: $weight")
        
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val currentProfile = _userProfile.value
                if (currentProfile == null) {
                    _error.value = "Current profile not loaded"
                    _isLoading.value = false
                    return@launch
                }

                val bmi = calculateBMI(height, weight)
                val updatedProfile = currentProfile.copy(
                    name = name,
                    age = age,
                    height = height,
                    weight = weight,
                    bmi = bmi,
                    role = role,
                    id = currentProfile.id,
                    email = currentProfile.email,
                    joinDate = currentProfile.joinDate,
                    membershipStatus = currentProfile.membershipStatus ?: "active"
                )

                userRepository.updateUserProfile(currentProfile.id, updatedProfile)
                    .onSuccess { profile ->
                        _userProfile.value = profile
                    }
                    .onFailure { e ->
                        _error.value = e.message ?: "Failed to update profile"
                    }
            } catch (e: Exception) {
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }

    private fun calculateBMI(heightCm: Float?, weightKg: Float?): Float? {
        if (heightCm == null || weightKg == null || heightCm <= 0) return null
        val heightM = heightCm / 100f
        return weightKg / (heightM * heightM)
    }
}