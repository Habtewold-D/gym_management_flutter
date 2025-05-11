package com.example.gymmanagement.data.model

data class EventRequest(
    val title: String,
    val date: String,
    val time: String,
    val location: String,
    val imageUri: String? = null,
    val createdBy: Int
)

data class EventUpdateRequest(
    val title: String? = null,
    val date: String? = null,
    val time: String? = null,
    val location: String? = null,
    val imageUri: String? = null
)

data class EventResponse(
    val id: Int,
    val title: String,
    val date: String,
    val time: String,
    val location: String,
    val imageUri: String? = null,
    val createdBy: Int,
    val createdAt: String,
    val updatedAt: String
)

data class EventParticipant(
    val id: Int,
    val eventId: Int,
    val userId: Int,
    val joinedAt: String
) 