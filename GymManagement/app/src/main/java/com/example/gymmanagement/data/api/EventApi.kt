package com.example.gymmanagement.data.api

import com.example.gymmanagement.data.model.EventRequest
import com.example.gymmanagement.data.model.EventResponse
import com.example.gymmanagement.data.model.EventUpdateRequest
import okhttp3.MultipartBody
import retrofit2.Response
import retrofit2.http.*

interface EventApi {
    @GET("events")
    suspend fun getAllEvents(): List<EventResponse>

    @GET("events/{id}")
    suspend fun getEventById(@Path("id") id: Int): EventResponse

    @POST("events")
    suspend fun createEvent(@Body event: EventRequest): EventResponse

    @Multipart
    @POST("events/with-image")
    suspend fun createEventWithImage(
        @Part("event") event: EventRequest,
        @Part image: MultipartBody.Part
    ): EventResponse

    @PATCH("events/{id}")
    suspend fun updateEvent(@Path("id") id: Int, @Body updateRequest: EventUpdateRequest): EventResponse

    @Multipart
    @PUT("events/{id}/with-image")
    suspend fun updateEventWithImage(
        @Path("id") id: Int,
        @Part("event") event: EventUpdateRequest,
        @Part image: MultipartBody.Part
    ): EventResponse

    @DELETE("events/{id}")
    suspend fun deleteEvent(@Path("id") id: Int): Response<Unit>

    @GET("events/user/{userId}")
    suspend fun getUserEvents(@Path("userId") userId: Int): List<EventResponse>
} 