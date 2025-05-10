package com.example.gymmanagement.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gymmanagement.data.model.EventResponse
import com.example.gymmanagement.data.repository.EventRepository
import com.example.gymmanagement.data.repository.EventRepositoryImpl
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class MemberEventViewModel(
    private val eventRepository: EventRepository = EventRepositoryImpl()
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
                eventRepository.getAllEvents().onSuccess { eventList ->
                    _events.value = eventList.filter { isEventUpcoming(it.date) }
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

    fun isEventUpcoming(eventDate: String): Boolean {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val eventCalendar = Calendar.getInstance().apply {
            time = dateFormat.parse(eventDate) ?: return false
        }
        val today = Calendar.getInstance()
        return !eventCalendar.before(today)
    }
} 