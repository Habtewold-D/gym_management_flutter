//package com.example.gymmanagement.viewmodel
//
//import androidx.lifecycle.ViewModel
//import androidx.lifecycle.viewModelScope
//import com.example.gymmanagement.data.model.EventEntity
//import com.example.gymmanagement.data.repository.EventRepository
//import kotlinx.coroutines.flow.Flow
//import kotlinx.coroutines.launch
//
//class AdminEventViewModel(
//    private val repository: EventRepository
//) : ViewModel() {
//    val events: Flow<List<EventEntity>> = repository.allEvents
//
//    fun addEvent(event: EventEntity) {
//        viewModelScope.launch {
//            repository.insertEvent(event)
//        }
//    }
//
//    fun updateEvent(event: EventEntity) {
//        viewModelScope.launch {
//            repository.updateEvent(event)
//        }
//    }
//
//    fun deleteEvent(event: EventEntity) {
//        viewModelScope.launch {
//            repository.deleteEvent(event)
//        }
//    }
//}