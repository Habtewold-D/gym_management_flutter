package com.example.gymmanagement.data.model

data class ApiError(
    val message: String,
    val code: Int? = null
)

data class ValidationError(
    val field: String,
    val message: String
) 