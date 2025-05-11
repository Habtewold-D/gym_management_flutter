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
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue

class AdminEventViewModel(
    private val eventRepository: EventRepository
) : ViewModel() {

    private val _events = MutableStateFlow<List<EventResponse>>(emptyList())
    val events: StateFlow<List<EventResponse>> = _events.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    private var _successMessage by mutableStateOf<String?>(null)
    val successMessage: String? get() = _successMessage

    private var _validationError by mutableStateOf<String?>(null)
    val validationError: String? get() = _validationError

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

    fun createEvent(request: EventRequest, onSuccess: (EventResponse) -> Unit = {}) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val result = eventRepository.createEvent(request)
                result.onSuccess { eventResponse ->
                    _events.value = _events.value + eventResponse
                    setSuccessMessage("Event created successfully!")
                    onSuccess(eventResponse)
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

    fun updateEvent(eventId: Int, updateRequest: EventUpdateRequest) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                eventRepository.updateEvent(eventId, updateRequest)
                    .onSuccess { updatedEvent ->
                        _events.value = _events.value.map { if (it.id == updatedEvent.id) updatedEvent else it }
                        _successMessage = "Event updated successfully!"
                    }
                    .onFailure { e ->
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
                    setSuccessMessage("Event deleted successfully!")
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

    fun addEventLocally(newEvent: EventResponse) {
        _events.value = _events.value
    }

    private fun isEventFormValid(
        title: String,
        date: String,
        time: String,
        location: String
    ): Boolean {
        return title.isNotBlank() && date.isNotBlank() && time.isNotBlank() && location.isNotBlank()
    }

    fun setSuccessMessage(message: String?) {
        _successMessage = message
    }

    fun setValidationError(message: String?) {
        _validationError = message
    }
}