package com.example.gymmanagement.data.repository

import android.net.Uri
import com.example.gymmanagement.data.api.EventApi
import com.example.gymmanagement.data.model.EventRequest
import com.example.gymmanagement.data.model.EventResponse
import com.example.gymmanagement.data.model.EventUpdateRequest
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File

class EventRepositoryImpl(
    private val eventApi: EventApi
) : EventRepository {

    override suspend fun getAllEvents(): Result<List<EventResponse>> = try {
        val response = eventApi.getAllEvents()
        Result.success(response)
    } catch (e: Exception) {
        Result.failure(e)
    }

    override suspend fun getEventById(id: Int): Result<EventResponse> = try {
        val response = eventApi.getEventById(id)
        Result.success(response)
    } catch (e: Exception) {
        Result.failure(e)
    }

    override suspend fun createEvent(event: EventRequest, imageFile: File?): Result<EventResponse> = try {
        val response = if (imageFile != null) {
            val requestFile = imageFile.asRequestBody("image/*".toMediaTypeOrNull())
            val imagePart = MultipartBody.Part.createFormData("image", imageFile.name, requestFile)
            eventApi.createEventWithImage(event, imagePart)
        } else {
            eventApi.createEvent(event)
        }
        Result.success(response)
    } catch (e: Exception) {
        Result.failure(e)
    }

    suspend fun updateEvent(id: Int, event: EventUpdateRequest, imageFile: File?): Result<EventResponse> = try {
        val response = if (imageFile != null) {
            val requestFile = imageFile.asRequestBody("image/*".toMediaTypeOrNull())
            val imagePart = MultipartBody.Part.createFormData("image", imageFile.name, requestFile)
            eventApi.updateEventWithImage(id, event, imagePart)
        } else {
            eventApi.updateEvent(id, event)
        }
        Result.success(response)
    } catch (e: Exception) {
        Result.failure(e)
    }

    override suspend fun deleteEvent(id: Int): Result<Unit> = try {
        val response = eventApi.deleteEvent(id)
        if (response.isSuccessful) {
            Result.success(Unit)
        } else {
            Result.failure(Exception("Failed to delete event"))
        }
    } catch (e: Exception) {
        Result.failure(e)
    }

    override suspend fun getUserEvents(userId: Int): Result<List<EventResponse>> = try {
        val response = eventApi.getUserEvents(userId)
        Result.success(response)
    } catch (e: Exception) {
        Result.failure(e)
    }

    override suspend fun updateEvent(eventId: Int, updateRequest: EventUpdateRequest): Result<EventResponse> {
        return updateEvent(eventId, updateRequest, null)
    }
} 