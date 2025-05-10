//package com.example.gymmanagement.viewmodel
//
//import androidx.lifecycle.ViewModel
//import androidx.lifecycle.viewModelScope
//import com.example.gymmanagement.data.model.UserProfile
//import com.example.gymmanagement.data.repository.UserRepository
//import kotlinx.coroutines.flow.MutableStateFlow
//import kotlinx.coroutines.flow.StateFlow
//import kotlinx.coroutines.launch
//
//class AdminMemberViewModel(
//    private val repository: UserRepository
//) : ViewModel() {
//    private val _members = MutableStateFlow<List<UserProfile>>(emptyList())
//    val members: StateFlow<List<UserProfile>> = _members
//
//    private val _isLoading = MutableStateFlow(false)
//    val isLoading: StateFlow<Boolean> = _isLoading
//
//    private val _error = MutableStateFlow<String?>(null)
//    val error: StateFlow<String?> = _error
//
//    init {
//        loadMembers()
//    }
//
//    private fun loadMembers() {
//        viewModelScope.launch {
//            try {
//                _isLoading.value = true
//                _error.value = null
//                repository.getAllUserProfiles().collect { profiles ->
//                    _members.value = profiles
//                }
//            } catch (e: Exception) {
//                _error.value = e.message ?: "Failed to load members"
//            } finally {
//                _isLoading.value = false
//            }
//        }
//    }
//
//    fun deleteMember(profile: UserProfile) {
//        viewModelScope.launch {
//            try {
//                _isLoading.value = true
//                _error.value = null
//                repository.deleteUserProfile(profile)
//                profile.email?.let { email ->
//                    repository.getUserByEmail(email)?.let { userEntity ->
//                        repository.deleteUser(userEntity)
//                    }
//                }
//            } catch (e: Exception) {
//                _error.value = e.message ?: "Failed to delete member"
//            } finally {
//                _isLoading.value = false
//            }
//        }
//    }
//}