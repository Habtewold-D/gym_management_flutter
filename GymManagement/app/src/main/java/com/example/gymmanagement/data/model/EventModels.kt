package com.example.gymmanagement.data.model

data class EventRequest(
    val title: String,
    val description: String,
    val date: String,
    val time: String,
    val location: String,
    val maxParticipants: Int,
    val createdBy: Int, // userId of the creator
    val imageUri: String? = null // Add image URI
)

data class EventUpdateRequest(
    val title: String? = null,
    val description: String? = null,
    val date: String? = null,
    val time: String? = null,
    val location: String? = null,
    val maxParticipants: Int? = null,
    val imageUri: String? = null // Add image URI
)

data class EventResponse(
    val id: Int,
    val title: String,
    val description: String,
    val date: String,
    val time: String,
    val location: String,
    val maxParticipants: Int,
    val currentParticipants: Int,
    val createdBy: Int,
    val createdAt: String,
    val updatedAt: String,
    val imageUri: String? = null // Add image URI
)

data class EventParticipant(
    val id: Int,
    val eventId: Int,
    val userId: Int,
    val joinedAt: String
) 