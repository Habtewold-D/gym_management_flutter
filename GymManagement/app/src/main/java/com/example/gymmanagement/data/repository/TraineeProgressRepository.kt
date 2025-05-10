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
            // Get all workouts and transform them into progress data
            val workouts = workoutApi.getAllWorkouts()
            val progressList = workouts.groupBy { it.userId }
                .map { (userId, userWorkouts) ->
                    TraineeProgress(
                        id = userId,
                        traineeId = userId.toString(),
                        completedWorkouts = userWorkouts.count { it.isCompleted },
                        totalWorkouts = userWorkouts.size
                    )
                }
            Result.success(progressList)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getProgressById(id: Int): Result<TraineeProgress> {
        return try {
            val workouts = workoutApi.getUserWorkouts()
            val progress = TraineeProgress(
                id = id,
                traineeId = id.toString(),
                completedWorkouts = workouts.count { it.isCompleted },
                totalWorkouts = workouts.size
            )
            Result.success(progress)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getProgressByTraineeId(traineeId: Int): Result<TraineeProgress> {
        return try {
            val workouts = workoutApi.getUserWorkouts()
            val progress = TraineeProgress(
                id = traineeId,
                traineeId = traineeId.toString(),
                completedWorkouts = workouts.count { it.isCompleted },
                totalWorkouts = workouts.size
            )
            Result.success(progress)
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
            // Since progress is derived from workouts, we don't need to make a separate API call
            // Just return the current progress
            getProgressByTraineeId(traineeId)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
} 