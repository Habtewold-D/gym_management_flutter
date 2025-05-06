package com.example.gymmanagement.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date

@Entity(tableName = "trainee_progress")
data class TraineeProgress(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val traineeId: String,
    val completedWorkouts: Int,
    val totalWorkouts: Int,
    val lastUpdated: Long = System.currentTimeMillis()
) {
    val progressPercentage: Int
        get() = if (totalWorkouts > 0) (completedWorkouts * 100) / totalWorkouts else 0
} 