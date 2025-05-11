package com.example.gymmanagement.data.model

data class UserResponse(
    val id: Int,
    val name: String,
    val email: String,
    val role: String,
    val age: Int? = null,
    val height: Float? = null,
    val weight: Float? = null,
    val bmi: Float? = null
) 