package com.example.gymmanagement.data.model

data class LoginRequest(
    val email: String,
    val password: String
)

data class RegisterRequest(
    val name: String,
    val email: String,
    val password: String,
    val confirmPassword: String,
    val age: Int,
    val height: Float,
    val weight: Float
)

data class AuthResponse(
    val access_token: String,
    val user: UserResponse
)

data class UserResponse(
    val id: Int,
    val name: String,
    val email: String,
    val role: String,
    val age: Int?,
    val height: Float?,
    val weight: Float?,
    val bmi: Float?
) 