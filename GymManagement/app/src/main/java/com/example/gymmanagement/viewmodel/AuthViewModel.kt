package com.example.gymmanagement.viewmodel

import android.app.Application
import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.gymmanagement.GymManagementApp
import com.example.gymmanagement.data.model.AuthResponse
import com.example.gymmanagement.data.model.UserResponse
import com.example.gymmanagement.data.repository.AuthRepository
import com.example.gymmanagement.data.api.ApiClient
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.regex.Pattern

class AuthViewModel(
    private val app: GymManagementApp,
    private val authRepository: AuthRepository = AuthRepository()
) : ViewModel() {
    private val TAG = "AuthViewModel"

    // State for authentication
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    private val _isAuthenticated = MutableStateFlow(false)
    val isAuthenticated: StateFlow<Boolean> = _isAuthenticated.asStateFlow()

    private val _userData = MutableStateFlow<AuthResponse?>(null)
    val userData: StateFlow<AuthResponse?> = _userData.asStateFlow()

    private val sharedPreferences = app.getSharedPreferences("auth_prefs", Context.MODE_PRIVATE)

    // Add a new state flow for navigation
    private val _navigateToMemberWorkout = MutableStateFlow(false)
    val navigateToMemberWorkout: StateFlow<Boolean> = _navigateToMemberWorkout.asStateFlow()

    init {
        loadSession()
    }

    private fun loadSession() {
            viewModelScope.launch {
            try {
                val sharedPreferences = app.getSharedPreferences("auth_prefs", Context.MODE_PRIVATE)
                val userId = sharedPreferences.getInt("user_id", -1)
                val accessToken = sharedPreferences.getString("access_token", null)
                
                if (userId != -1 && accessToken != null) {
                    // Set the access token in ApiClient
                    ApiClient.setAccessToken(accessToken)
                    _isAuthenticated.value = true
                    Log.d(TAG, "Session loaded for user ID: $userId")
                } else {
                    Log.d(TAG, "No valid session found")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error loading session", e)
            }
        }
    }

    fun checkLoginState() {
        viewModelScope.launch {
            try {
                val email = sharedPreferences.getString("user_email", null)
                if (email != null) {
                    val loginResult = authRepository.login(email, "")
                    loginResult.onSuccess { response ->
                        _userData.value = response
                        _isAuthenticated.value = true
                        Log.d("AuthViewModel", "Login state checked: User is logged in")
                    }.onFailure {
                        clearSession()
                        Log.d("AuthViewModel", "Login state checked: User not found")
                    }
                } else {
                    clearSession()
                    Log.d("AuthViewModel", "Login state checked: No session found")
                }
            } catch (e: Exception) {
                Log.e("AuthViewModel", "Error checking login state", e)
                clearSession()
            }
        }
    }

    fun validateEmail(email: String): String? {
        if (email.isEmpty()) return "Email address is required"
        val emailPattern = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\$")
        if (!emailPattern.matcher(email).matches()) {
            return "Please enter a valid email address"
        }
        return null
    }

    fun validatePassword(password: String): String? {
        if (password.isEmpty()) return "Password is required"
        if (password.length < 6) return "Password must be at least 6 characters long"
        return null
    }

    fun validateName(name: String): String? {
        if (name.isEmpty()) return "Full name is required"
        if (name.length < 2) return "Name must be at least 2 characters long"
        if (!name.matches(Regex("^[a-zA-Z\\s]*$"))) return "Name can only contain letters and spaces"
        return null
    }

    fun validateAge(age: String): String? {
        if (age.isEmpty()) return "Age is required"
        val ageInt = age.toIntOrNull()
        if (ageInt == null) return "Please enter a valid number for age"
        if (ageInt < 10) return "You must be at least 10 years old to register"
        if (ageInt > 100) return "Please enter a valid age (maximum 100 years)"
        return null
    }

    fun validateHeight(height: String): String? {
        if (height.isEmpty()) return "Height is required"
        val heightFloat = height.toFloatOrNull()
        if (heightFloat == null) return "Please enter a valid number for height"
        if (heightFloat < 80) return "Height must be at least 80 cm"
        if (heightFloat > 250) return "Height cannot exceed 250 cm"
        return null
    }

    fun validateWeight(weight: String): String? {
        if (weight.isEmpty()) return "Weight is required"
        val weightFloat = weight.toFloatOrNull()
        if (weightFloat == null) return "Please enter a valid number for weight"
        if (weightFloat < 35) return "Weight must be at least 35 kg"
        if (weightFloat > 200) return "Weight cannot exceed 200 kg"
        return null
    }

    fun login(email: String, password: String) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                Log.d(TAG, "Attempting login for user: $email")
                authRepository.login(email, password).onSuccess { response ->
                    Log.d(TAG, "Login successful, setting user data and token")
                    _userData.value = response
                    _isAuthenticated.value = true
                    
                    // Set the access token in ApiClient
                    response.access_token?.let { token ->
                        ApiClient.setAccessToken(token)
                        Log.d(TAG, "Access token set in ApiClient: $token")
                    }
                    
                    // Save the session
                    response.user?.let { user ->
                        saveSession(user)
                    }
                }.onFailure { e ->
                    Log.e(TAG, "Login failed", e)
                    _error.value = e.message ?: "Login failed"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error during login", e)
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun register(
        name: String,
        email: String,
        password: String,
        confirmPassword: String,
        age: String,
        height: String,
        weight: String
    ) {
        Log.d(TAG, "Starting registration process for email: $email")
        
        // Input validation
        when {
            name.isBlank() -> {
                Log.e(TAG, "Name is blank")
                _error.value = "Name cannot be empty"
                return
            }
            email.isBlank() -> {
                Log.e(TAG, "Email is blank")
                _error.value = "Email cannot be empty"
                return
            }
            password.isBlank() -> {
                _error.value = "Password cannot be empty"
                return
            }
            password != confirmPassword -> {
                _error.value = "Passwords do not match"
                return
            }
            age.isBlank() -> {
                _error.value = "Age cannot be empty"
                return
            }
            height.isBlank() -> {
                _error.value = "Height cannot be empty"
                return
            }
            weight.isBlank() -> {
                _error.value = "Weight cannot be empty"
                return
            }
        }

        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                Log.d(TAG, "Making registration API call")
                authRepository.register(
                    name = name,
                    email = email,
                    password = password,
                    confirmPassword = confirmPassword,
                    age = age.toIntOrNull() ?: 0,
                    height = height.toFloatOrNull() ?: 0f,
                    weight = weight.toFloatOrNull() ?: 0f
                ).onSuccess { response ->
                    Log.d(TAG, "Received registration response: $response")
                    if (response.user != null) {
                        Log.d(TAG, "Registration successful: ${response.user.email}")
                        _userData.value = response
                        _isAuthenticated.value = true
                        saveSession(response.user)
                        _navigateToMemberWorkout.value = true
                    } else {
                        Log.e(TAG, "Registration response user is null. Full response: $response")
                        _error.value = "Registration failed: Server returned invalid user data"
                    }
                }.onFailure { e ->
                    Log.e(TAG, "Registration failed", e)
                    _error.value = e.message ?: "Registration failed"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error during registration", e)
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
                Log.d(TAG, "Registration process completed")
            }
        }
    }

    private fun clearSession() {
        viewModelScope.launch {
            try {
                val sharedPreferences = app.getSharedPreferences("auth_prefs", Context.MODE_PRIVATE)
                sharedPreferences.edit().clear().apply()
                ApiClient.setAccessToken(null)  // Clear the access token
                _isAuthenticated.value = false
                _userData.value = null
                Log.d(TAG, "Session cleared successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error clearing session", e)
            }
        }
    }

    fun logout() {
        clearSession()
    }

    private fun saveSession(user: UserResponse) {
        viewModelScope.launch {
            try {
                val sharedPreferences = app.getSharedPreferences("auth_prefs", Context.MODE_PRIVATE)
            sharedPreferences.edit().apply {
                    putInt("user_id", user.id)
                putString("user_email", user.email)
                    putString("user_name", user.name)
                    putString("user_role", user.role)
                    putString("access_token", _userData.value?.access_token)
                apply()
            }
                // Set the access token in ApiClient
                _userData.value?.access_token?.let { token ->
                    ApiClient.setAccessToken(token)
                }
                Log.d(TAG, "Session saved for user: ${user.email}")
            } catch (e: Exception) {
                Log.e(TAG, "Error saving session", e)
        }
    }
    }

    fun resetState() {
        _isLoading.value = false
        _error.value = null
        _isAuthenticated.value = false
        _userData.value = null
    }

    fun clearError() {
        _error.value = null
    }

    // Add function to reset navigation flag
    fun resetNavigation() {
        _navigateToMemberWorkout.value = false
    }

    companion object {
        fun provideFactory(app: GymManagementApp): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                return AuthViewModel(app) as T
            }
        }
    }
}

class AuthViewModelFactory(
    private val app: GymManagementApp
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(AuthViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return AuthViewModel(app) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
