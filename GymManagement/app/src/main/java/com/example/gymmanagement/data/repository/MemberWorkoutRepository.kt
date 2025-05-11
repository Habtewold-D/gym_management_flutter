package com.example.gymmanagement.data.repository

import com.example.gymmanagement.data.api.ApiClient
import com.example.gymmanagement.data.model.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

interface MemberWorkoutRepository {
    suspend fun getWorkoutsForTrainee(traineeId: Int): Result<List<WorkoutResponse>>
    suspend fun getAllWorkouts(): Result<List<WorkoutResponse>>
    suspend fun createWorkout(workout: WorkoutRequest): Result<WorkoutResponse>
    suspend fun updateWorkout(workout: WorkoutUpdateRequest): Result<WorkoutResponse>
    suspend fun deleteWorkout(id: Int): Result<Unit>
    suspend fun updateWorkoutCompletion(id: Int): Result<WorkoutResponse>
    suspend fun getWorkoutStats(traineeId: Int): Result<WorkoutStatsResponse>
    
    // Flow wrappers for UI
    fun getWorkoutsForTraineeFlow(traineeId: Int): Flow<List<WorkoutResponse>>
    fun getAllWorkoutsFlow(): Flow<List<WorkoutResponse>>
}

class MemberWorkoutRepositoryImpl : MemberWorkoutRepository {
    private val workoutApi = ApiClient.getWorkoutApi()

    override suspend fun getWorkoutsForTrainee(traineeId: Int): Result<List<WorkoutResponse>> {
        return try {
            val response = workoutApi.getUserWorkouts()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getAllWorkouts(): Result<List<WorkoutResponse>> {
        return try {
            val response = workoutApi.getAllWorkouts()
            Result.success(response)
        } catch (e: Exception) {
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

    override suspend fun updateWorkout(workout: WorkoutUpdateRequest): Result<WorkoutResponse> {
        return try {
            // First, get the workout to update to get its ID
            val existingWorkout = workoutApi.getWorkout(workout.id)
            val response = workoutApi.updateWorkout(existingWorkout.id, workout)
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

    override suspend fun updateWorkoutCompletion(id: Int): Result<WorkoutResponse> {
        return try {
            val response = workoutApi.toggleWorkoutCompletion(id)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getWorkoutStats(traineeId: Int): Result<WorkoutStatsResponse> {
        return try {
            val response = workoutApi.getWorkoutStats(traineeId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // Flow wrappers for UI
    override fun getWorkoutsForTraineeFlow(traineeId: Int): Flow<List<WorkoutResponse>> = flow {
        getWorkoutsForTrainee(traineeId).onSuccess { workouts ->
            emit(workouts)
        }
    }

    override fun getAllWorkoutsFlow(): Flow<List<WorkoutResponse>> = flow {
        getAllWorkouts().onSuccess { workouts ->
            emit(workouts)
        }
    }
} 