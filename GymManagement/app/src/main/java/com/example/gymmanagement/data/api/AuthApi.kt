package com.example.gymmanagement.data.api

import com.example.gymmanagement.data.model.AuthResponse
import com.example.gymmanagement.data.model.LoginRequest
import com.example.gymmanagement.data.model.RegisterRequest
import retrofit2.http.Body
import retrofit2.http.POST

interface AuthApi {
    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): AuthResponse

    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequest): AuthResponse
}