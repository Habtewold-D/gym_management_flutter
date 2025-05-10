package com.example.gymmanagement.data.model

data class UserProfile(
    val id: Int,
    val email: String,
    val name: String,
    val age: Int? = null,
    val height: Float? = null,
    val weight: Float? = null,
    val bmi: Float? = null,
    val role: String,
    val joinDate: String,
    val membershipStatus: String = "active"
)