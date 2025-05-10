package com.example.gymmanagement.data.repository

import com.example.gymmanagement.data.api.ApiClient
import com.example.gymmanagement.data.model.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import android.util.Log

interface WorkoutRepository {
    suspend fun getAllWorkouts(): Result<List<WorkoutResponse>>
    suspend fun getWorkout(id: Int): Result<WorkoutResponse>
    suspend fun getUserWorkouts(userId: Int): Result<List<WorkoutResponse>>
    suspend fun createWorkout(workout: WorkoutRequest): Result<WorkoutResponse>
    suspend fun updateWorkout(id: Int, workout: WorkoutUpdateRequest): Result<WorkoutResponse>
    suspend fun deleteWorkout(id: Int): Result<Unit>
    suspend fun toggleWorkoutCompletion(id: Int): Result<WorkoutResponse>
    suspend fun getWorkoutStats(userId: Int): Result<WorkoutStatsResponse>
    
    // Flow wrappers for UI
    fun getAllWorkoutsFlow(): Flow<List<WorkoutResponse>>
    fun getUserWorkoutsFlow(userId: Int): Flow<List<WorkoutResponse>>
}

class WorkoutRepositoryImpl : WorkoutRepository {
    private val TAG = "WorkoutRepositoryImpl"
    private val workoutApi = ApiClient.getWorkoutApi()

    override suspend fun getAllWorkouts(): Result<List<WorkoutResponse>> {
        return try {
            val response = workoutApi.getAllWorkouts()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getWorkout(id: Int): Result<WorkoutResponse> {
        return try {
            val response = workoutApi.getWorkout(id)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getUserWorkouts(userId: Int): Result<List<WorkoutResponse>> {
        Log.d(TAG, "Getting workouts for current user")
        return try {
            Log.d(TAG, "Making API call to get user workouts")
            val response = workoutApi.getUserWorkouts()
            Log.d(TAG, "Successfully retrieved ${response.size} workouts")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting user workouts", e)
            Result.failure(e)
        }
    }

    override suspend fun createWorkout(workout: WorkoutRequest): Result<WorkoutResponse> {
        return try {
            val response = workoutApi.createWorkout(workout)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun updateWorkout(id: Int, workout: WorkoutUpdateRequest): Result<WorkoutResponse> {
        return try {
            val response = workoutApi.updateWorkout(id, workout)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun deleteWorkout(id: Int): Result<Unit> {
        return try {
            workoutApi.deleteWorkout(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun toggleWorkoutCompletion(id: Int): Result<WorkoutResponse> {
        Log.d(TAG, "Toggling completion for workout ID: $id")
        return try {
            Log.d(TAG, "Making API call to toggle workout completion")
            val response = workoutApi.toggleWorkoutCompletion(id)
            Log.d(TAG, "Successfully toggled workout completion")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Error toggling workout completion", e)
            Result.failure(e)
        }
    }

    override suspend fun getWorkoutStats(userId: Int): Result<WorkoutStatsResponse> {
        return try {
            val response = workoutApi.getWorkoutStats(userId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // Flow wrappers for UI
    override fun getAllWorkoutsFlow(): Flow<List<WorkoutResponse>> = flow {
        getAllWorkouts().onSuccess { workouts ->
            emit(workouts)
        }
    }

    override fun getUserWorkoutsFlow(userId: Int): Flow<List<WorkoutResponse>> = flow {
        getUserWorkouts(userId).onSuccess { workouts ->
            emit(workouts)
        }
    }
} 