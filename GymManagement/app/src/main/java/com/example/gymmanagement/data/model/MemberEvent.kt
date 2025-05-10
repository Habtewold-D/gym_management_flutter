package com.example.gymmanagement.data.model


data class MemberEvent(
    val id: Long = 0,
    val eventId: Long,
    val memberId: String,
    val isRegistered: Boolean = false,
    val registrationDate: String? = null
)