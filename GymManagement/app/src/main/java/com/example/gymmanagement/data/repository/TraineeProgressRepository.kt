package com.example.gymmanagement.data.repository

import com.example.gymmanagement.data.api.ApiClient
import com.example.gymmanagement.data.model.TraineeProgress
import com.example.gymmanagement.data.model.WorkoutStatsResponse
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

interface TraineeProgressRepository {
    suspend fun getAllProgress(): Result<List<TraineeProgress>>
    suspend fun getProgressById(id: Int): Result<TraineeProgress>
    suspend fun getProgressByTraineeId(traineeId: Int): Result<TraineeProgress>
    suspend fun getWorkoutStats(traineeId: Int): Result<WorkoutStatsResponse>
    suspend fun updateProgress(traineeId: Int, completedWorkouts: Int, totalWorkouts: Int): Result<TraineeProgress>
}

class TraineeProgressRepositoryImpl : TraineeProgressRepository {
    private val workoutApi = ApiClient.getWorkoutApi()

    override suspend fun getAllProgress(): Result<List<TraineeProgress>> {
        return try {
            val progressList = workoutApi.getAllUsersProgress()
            Result.success(progressList.map { stats ->
                TraineeProgress(
                    userId = stats.userId,
                    name = stats.name,
                    email = stats.email,
                    completedWorkouts = stats.completedWorkouts,
                    totalWorkouts = stats.totalWorkouts,
                    progressPercentage = stats.progressPercentage
                )
            })
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getProgressById(id: Int): Result<TraineeProgress> {
        return try {
            val stats = workoutApi.getWorkoutStats(id)
            Result.success(TraineeProgress(
                userId = id,
                name = "",
                email = "",
                completedWorkouts = stats.completedWorkouts,
                totalWorkouts = stats.totalWorkouts,
                progressPercentage = if (stats.totalWorkouts > 0) (stats.completedWorkouts * 100) / stats.totalWorkouts else 0
            ))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getProgressByTraineeId(traineeId: Int): Result<TraineeProgress> {
        return try {
            val stats = workoutApi.getWorkoutStats(traineeId)
            Result.success(TraineeProgress(
                userId = traineeId,
                name = "",
                email = "",
                completedWorkouts = stats.completedWorkouts,
                totalWorkouts = stats.totalWorkouts,
                progressPercentage = if (stats.totalWorkouts > 0) (stats.completedWorkouts * 100) / stats.totalWorkouts else 0
            ))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getWorkoutStats(traineeId: Int): Result<WorkoutStatsResponse> {
        return try {
            val stats = workoutApi.getWorkoutStats(traineeId)
            Result.success(stats)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun updateProgress(
        traineeId: Int,
        completedWorkouts: Int,
        totalWorkouts: Int
    ): Result<TraineeProgress> {
        return try {
            val stats = workoutApi.getWorkoutStats(traineeId)
            Result.success(TraineeProgress(
                userId = traineeId,
                name = "",
                email = "",
                completedWorkouts = stats.completedWorkouts,
                totalWorkouts = stats.totalWorkouts,
                progressPercentage = if (stats.totalWorkouts > 0) (stats.completedWorkouts * 100) / stats.totalWorkouts else 0
            ))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
} 