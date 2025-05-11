package com.example.gymmanagement.data.api

import com.example.gymmanagement.data.model.UserProfile
import retrofit2.http.*

interface UserApi {
    @GET("users/{id}")
    suspend fun getUserProfile(@Path("id") id: Int): UserProfile

    @GET("users")
    suspend fun getAllUsers(): List<UserProfile>

    @PATCH("users/{id}")
    suspend fun updateUserProfile(
        @Path("id") id: Int,
        @Body profile: UserProfile
    ): UserProfile

    @GET("users/email/{email}")
    suspend fun getUserByEmail(@Path("email") email: String): UserProfile

    @DELETE("users/{id}")
    suspend fun deleteUser(@Path("id") id: Int)
} 