package com.example.gymmanagement.data.model

data class Event(
    val id: Long = 0,
    val title: String,
    val date: String,
    val time: String,
    val location: String,
    val imageUri: String? = null
) 