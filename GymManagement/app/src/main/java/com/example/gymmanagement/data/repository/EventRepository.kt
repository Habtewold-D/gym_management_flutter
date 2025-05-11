package com.example.gymmanagement.data.repository

import com.example.gymmanagement.data.model.EventRequest
import com.example.gymmanagement.data.model.EventResponse
import com.example.gymmanagement.data.model.EventUpdateRequest
import java.io.File

interface EventRepository {
    suspend fun getAllEvents(): Result<List<EventResponse>>
    suspend fun getEventById(id: Int): Result<EventResponse>
    suspend fun createEvent(event: EventRequest, imageFile: File? = null): Result<EventResponse>
    suspend fun updateEvent(eventId: Int, updateRequest: EventUpdateRequest): Result<EventResponse>
    suspend fun deleteEvent(id: Int): Result<Unit>
    suspend fun getUserEvents(userId: Int): Result<List<EventResponse>>
} 