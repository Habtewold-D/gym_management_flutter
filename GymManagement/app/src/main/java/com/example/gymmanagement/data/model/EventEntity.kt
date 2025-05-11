package com.example.gymmanagement.data.model

data class EventEntity(
    val id: Int = 0,
    val title: String,
    val date: String,
    val time: String,
    val location: String,
    val imageUri: String? = null
)
