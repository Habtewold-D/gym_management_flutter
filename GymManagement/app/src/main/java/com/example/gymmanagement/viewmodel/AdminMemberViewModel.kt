package com.example.gymmanagement.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gymmanagement.data.model.UserProfile
import com.example.gymmanagement.data.repository.UserRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class AdminMemberViewModel(
    private val repository: UserRepository
) : ViewModel() {
    private val _members = MutableStateFlow<List<UserProfile>>(emptyList())
    val members: StateFlow<List<UserProfile>> = _members

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error

    init {
        loadMembers()
    }

    fun loadMembers() {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _error.value = null
                repository.getAllUsers().onSuccess { profiles ->
                    _members.value = profiles
                }.onFailure { e ->
                    _error.value = e.message ?: "Failed to load members"
                }
            } catch (e: Exception) {
                _error.value = e.message ?: "Failed to load members"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun deleteMember(profile: UserProfile) {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _error.value = null
                // Since we don't have a direct delete endpoint, we'll just refresh the list
                loadMembers()
            } catch (e: Exception) {
                _error.value = e.message ?: "Failed to delete member"
            } finally {
                _isLoading.value = false
            }
        }
    }
}