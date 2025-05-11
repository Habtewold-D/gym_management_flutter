package com.example.gymmanagement.viewmodel

import android.net.Uri
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gymmanagement.data.model.EventRequest
import com.example.gymmanagement.data.model.EventResponse
import com.example.gymmanagement.data.model.EventUpdateRequest
import com.example.gymmanagement.data.repository.EventRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.File

class AdminEventViewModel(
    private val eventRepository: EventRepository
) : ViewModel() {

    private val _events = MutableStateFlow<List<EventResponse>>(emptyList())
    val events: StateFlow<List<EventResponse>> = _events.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    fun loadEvents() {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val result = eventRepository.getAllEvents()
                result.onSuccess { events ->
                    _events.value = events
                }.onFailure { e ->
                    _error.value = e.message ?: "Failed to load events"
                }
            } catch (e: Exception) {
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun createEvent(
        title: String,
        date: String,
        time: String,
        location: String,
        imageFile: File? = null
    ) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val request = EventRequest(
                    title = title,
                    date = date,
                    time = time,
                    location = location,
                    createdBy = 0 // This will be set by the backend based on the authenticated user
                )
                val result = eventRepository.createEvent(request, imageFile)
                result.onSuccess { event ->
                    _events.value = _events.value + event
                }.onFailure { e ->
                    _error.value = e.message ?: "Failed to create event"
                }
            } catch (e: Exception) {
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun updateEvent(
        id: Int,
        title: String?,
        date: String?,
        time: String?,
        location: String?,
        imageFile: File? = null
    ) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val request = EventUpdateRequest(
                    title = title,
                    date = date,
                    time = time,
                    location = location
                )
                val result = eventRepository.updateEvent(id, request, imageFile)
                result.onSuccess { updatedEvent ->
                    _events.value = _events.value.map { event ->
                        if (event.id == id) updatedEvent else event
                    }
                }.onFailure { e ->
                    _error.value = e.message ?: "Failed to update event"
                }
            } catch (e: Exception) {
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun deleteEvent(id: Int) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val result = eventRepository.deleteEvent(id)
                result.onSuccess {
                    _events.value = _events.value.filter { it.id != id }
                }.onFailure { e ->
                    _error.value = e.message ?: "Failed to delete event"
                }
            } catch (e: Exception) {
                _error.value = e.message ?: "An unexpected error occurred"
            } finally {
                _isLoading.value = false
            }
        }
    }
}