package com.example.gymmanagement.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gymmanagement.data.model.EventEntity
import com.example.gymmanagement.data.model.EventResponse
import com.example.gymmanagement.data.repository.EventRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class MemberEventViewModel(
    private val eventRepository: EventRepository
) : ViewModel() {
    private val _events = MutableStateFlow<List<EventResponse>>(emptyList())
    val events: StateFlow<List<EventResponse>> = _events.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    init {
        loadEvents()
    }

    fun loadEvents() {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _error.value = null
                val result = eventRepository.getAllEvents()
                result.onSuccess { eventList ->
                    _events.value = eventList
                }.onFailure { e ->
                    _error.value = e.message ?: "Failed to load events"
                }
            } catch (e: Exception) {
                _error.value = e.message ?: "Failed to load events"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun refreshEvents() {
        loadEvents()
    }
} 