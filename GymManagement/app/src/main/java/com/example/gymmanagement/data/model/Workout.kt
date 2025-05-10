package com.example.gymmanagement.data.model

data class Workout(
    val id: Int = 0,
    val eventTitle: String,
    val traineeId: Int,
    val sets: Int,
    val repsOrSecs: Int,
    val restTime: Int,
    val imageUri: String? = null,
    val isCompleted: Boolean = false
) 