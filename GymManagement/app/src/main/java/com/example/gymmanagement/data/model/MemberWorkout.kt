package com.example.gymmanagement.data.model

data class MemberWorkout(
    val id: Int = 0,
    val title: String,
    val sets: Int,
    val repsOrSecs: Int,
    val restTime: Int,
    val imageUri: String? = null,
    val isCompleted: Boolean = false,
    val traineeId: String // To associate workouts with specific members
) 