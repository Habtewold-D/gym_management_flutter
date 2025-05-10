package com.example.gymmanagement.data.model

data class WorkoutRequest(
    val eventTitle: String,
    val userId: Int,
    val sets: Int,
    val repsOrSecs: Int,
    val restTime: Int,
    val imageUri: String?,
    val isCompleted: Boolean = false
)

data class WorkoutUpdateRequest(
    val eventTitle: String? = null,
    val sets: Int? = null,
    val repsOrSecs: Int? = null,
    val restTime: Int? = null
)

data class WorkoutResponse(
    val id: Int,
    val eventTitle: String,
    val userId: Int,
    val sets: Int,
    val repsOrSecs: Int,
    val restTime: Int,
    val imageUri: String?,
    val isCompleted: Boolean,
    val createdAt: String,
    val updatedAt: String
)

data class WorkoutStatsResponse(
    val totalWorkouts: Int,
    val completedWorkouts: Int,
    val averageSets: Double,
    val averageReps: Double
) 