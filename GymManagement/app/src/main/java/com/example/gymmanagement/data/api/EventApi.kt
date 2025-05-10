package com.example.gymmanagement.data.api

import com.example.gymmanagement.data.model.*
import okhttp3.MultipartBody
import retrofit2.Response
import retrofit2.http.*

interface EventApi {
    @GET("events")
    suspend fun getAllEvents(): List<EventResponse>

    @GET("events/{id}")
    suspend fun getEvent(@Path("id") id: Int): EventResponse

    @GET("events/user/{userId}")
    suspend fun getUserEvents(@Path("userId") userId: Int): List<EventResponse>

    @POST("events")
    suspend fun createEvent(@Body event: EventRequest): EventResponse

    @Multipart
    @POST("events/with-image")
    suspend fun createEventWithImage(@Body requestBody: MultipartBody): EventResponse

    @PUT("events/{id}")
    suspend fun updateEvent(@Path("id") id: Int, @Body event: EventUpdateRequest): EventResponse

    @Multipart
    @PUT("events/{id}/with-image")
    suspend fun updateEventWithImage(@Path("id") id: Int, @Body requestBody: MultipartBody): EventResponse

    @DELETE("events/{id}")
    suspend fun deleteEvent(@Path("id") id: Int)

    @POST("events/{eventId}/join/{userId}")
    suspend fun joinEvent(@Path("eventId") eventId: Int, @Path("userId") userId: Int): EventParticipant

    @DELETE("events/{eventId}/leave/{userId}")
    suspend fun leaveEvent(@Path("eventId") eventId: Int, @Path("userId") userId: Int)

    @GET("events/{eventId}/participants")
    suspend fun getEventParticipants(@Path("eventId") eventId: Int): List<EventParticipant>
} 