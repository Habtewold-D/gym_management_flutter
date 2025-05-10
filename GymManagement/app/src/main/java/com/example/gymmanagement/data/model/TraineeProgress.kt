package com.example.gymmanagement.data.model

data class TraineeProgress(
    val id: Int = 0,
    val traineeId: String,
    val completedWorkouts: Int,
    val totalWorkouts: Int,
    val lastUpdated: Long = System.currentTimeMillis()
) {
    val progressPercentage: Int
        get() = if (totalWorkouts > 0) (completedWorkouts * 100) / totalWorkouts else 0
}