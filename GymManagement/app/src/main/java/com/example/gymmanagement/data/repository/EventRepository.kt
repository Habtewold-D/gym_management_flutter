package com.example.gymmanagement.data.repository

import com.example.gymmanagement.data.api.ApiClient
import com.example.gymmanagement.data.model.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File

interface EventRepository {
    suspend fun getAllEvents(): Result<List<EventResponse>>
    suspend fun getEvent(id: Int): Result<EventResponse>
    suspend fun getUserEvents(userId: Int): Result<List<EventResponse>>
    suspend fun createEvent(event: EventRequest, imageFile: File? = null): Result<EventResponse>
    suspend fun updateEvent(id: Int, event: EventUpdateRequest, imageFile: File? = null): Result<EventResponse>
    suspend fun deleteEvent(id: Int): Result<Unit>
    suspend fun joinEvent(eventId: Int, userId: Int): Result<EventParticipant>
    suspend fun leaveEvent(eventId: Int, userId: Int): Result<Unit>
    suspend fun getEventParticipants(eventId: Int): Result<List<EventParticipant>>
}

class EventRepositoryImpl : EventRepository {
    private val eventApi = ApiClient.getEventApi()

    override suspend fun getAllEvents(): Result<List<EventResponse>> {
        return try {
            val response = eventApi.getAllEvents()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getEvent(id: Int): Result<EventResponse> {
        return try {
            val response = eventApi.getEvent(id)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getUserEvents(userId: Int): Result<List<EventResponse>> {
        return try {
            val response = eventApi.getUserEvents(userId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun createEvent(event: EventRequest, imageFile: File?): Result<EventResponse> {
        return try {
            val response = if (imageFile != null) {
                // Create multipart request for image upload
                val requestBody = MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .addFormDataPart("title", event.title)
                    .addFormDataPart("description", event.description)
                    .addFormDataPart("date", event.date)
                    .addFormDataPart("time", event.time)
                    .addFormDataPart("location", event.location)
                    .addFormDataPart("maxParticipants", event.maxParticipants.toString())
                    .addFormDataPart("createdBy", event.createdBy.toString())
                    .addFormDataPart(
                        "image",
                        imageFile.name,
                        imageFile.asRequestBody("image/*".toMediaTypeOrNull())
                    )
                    .build()
                
                eventApi.createEventWithImage(requestBody)
            } else {
                eventApi.createEvent(event)
            }
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun updateEvent(id: Int, event: EventUpdateRequest, imageFile: File?): Result<EventResponse> {
        return try {
            val response = if (imageFile != null) {
                // Create multipart request for image upload
                val requestBody = MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .apply {
                        event.title?.let { addFormDataPart("title", it) }
                        event.description?.let { addFormDataPart("description", it) }
                        event.date?.let { addFormDataPart("date", it) }
                        event.time?.let { addFormDataPart("time", it) }
                        event.location?.let { addFormDataPart("location", it) }
                        event.maxParticipants?.let { addFormDataPart("maxParticipants", it.toString()) }
                        addFormDataPart(
                            "image",
                            imageFile.name,
                            imageFile.asRequestBody("image/*".toMediaTypeOrNull())
                        )
                    }
                    .build()
                
                eventApi.updateEventWithImage(id, requestBody)
            } else {
                eventApi.updateEvent(id, event)
            }
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun deleteEvent(id: Int): Result<Unit> {
        return try {
            eventApi.deleteEvent(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun joinEvent(eventId: Int, userId: Int): Result<EventParticipant> {
        return try {
            val response = eventApi.joinEvent(eventId, userId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun leaveEvent(eventId: Int, userId: Int): Result<Unit> {
        return try {
            eventApi.leaveEvent(eventId, userId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getEventParticipants(eventId: Int): Result<List<EventParticipant>> {
        return try {
            val response = eventApi.getEventParticipants(eventId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
} 