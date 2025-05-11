package com.example.gymmanagement.data.model

data class TraineeProgress(
    val userId: Int,
    val name: String,
    val email: String,
    val completedWorkouts: Int,
    val totalWorkouts: Int,
    val progressPercentage: Int
)