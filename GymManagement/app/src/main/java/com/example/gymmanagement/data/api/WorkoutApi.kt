package com.example.gymmanagement.data.api

import com.example.gymmanagement.data.model.*
import retrofit2.http.*

interface WorkoutApi {
    @GET("workouts")
    suspend fun getAllWorkouts(): List<WorkoutResponse>

    @GET("workouts/my-workout")
    suspend fun getUserWorkouts(): List<WorkoutResponse>

    @GET("workouts/{id}")
    suspend fun getWorkout(@Path("id") id: Int): WorkoutResponse

    @GET("workouts/stats/{userId}")
    suspend fun getWorkoutStats(@Path("userId") userId: Int): WorkoutStatsResponse

    @POST("workouts")
    suspend fun createWorkout(@Body workout: WorkoutRequest): WorkoutResponse

    @PATCH("workouts/{id}")
    suspend fun updateWorkout(
        @Path("id") id: Int,
        @Body workout: WorkoutUpdateRequest
    ): WorkoutResponse

    @PATCH("workouts/{id}/toggle-completion")
    suspend fun toggleWorkoutCompletion(@Path("id") id: Int): WorkoutResponse

    @DELETE("workouts/{id}")
    suspend fun deleteWorkout(@Path("id") id: Int)
} 