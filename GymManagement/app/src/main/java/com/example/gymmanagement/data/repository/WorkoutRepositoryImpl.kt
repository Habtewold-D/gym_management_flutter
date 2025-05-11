import android.util.Log
import com.example.gymmanagement.data.api.ApiClient
import com.example.gymmanagement.data.model.WorkoutRequest
import com.example.gymmanagement.data.model.WorkoutResponse
import com.example.gymmanagement.data.model.WorkoutStatsResponse
import com.example.gymmanagement.data.model.WorkoutUpdateRequest
import com.example.gymmanagement.data.repository.WorkoutRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class WorkoutRepositoryImpl : WorkoutRepository {
    private val TAG = "WorkoutRepositoryImpl"
    private val workoutApi = ApiClient.getWorkoutApi()

    override suspend fun getAllWorkouts(): Result<List<WorkoutResponse>> {
        return try {
            Log.d(TAG, "Fetching all workouts")
            val response = workoutApi.getAllWorkouts()
            Log.d(TAG, "Successfully fetched ${response.size} workouts")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Error fetching workouts", e)
            Result.failure(e)
        }
    }

    override suspend fun getWorkout(id: Int): Result<WorkoutResponse> {
        return try {
            Log.d(TAG, "Fetching workout with id: $id")
            val response = workoutApi.getWorkout(id)
            Log.d(TAG, "Successfully fetched workout")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Error fetching workout", e)
            Result.failure(e)
        }
    }

    override suspend fun getUserWorkouts(userId: Int): Result<List<WorkoutResponse>> {
        return try {
            Log.d(TAG, "Fetching workouts for user: $userId")
            val response = workoutApi.getUserWorkoutsById(userId)
            Log.d(TAG, "Successfully fetched ${response.size} workouts for user")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Error fetching user workouts", e)
            Result.failure(e)
        }
    }

    override suspend fun createWorkout(workout: WorkoutRequest): Result<WorkoutResponse> {
        return try {
            Log.d(TAG, "Creating new workout")
            val response = workoutApi.createWorkout(workout)
            Log.d(TAG, "Successfully created workout")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Error creating workout", e)
            Result.failure(e)
        }
    }

    override suspend fun updateWorkout(workout: WorkoutUpdateRequest): Result<WorkoutResponse> {
        return try {
            // First, get the workout to update to get its ID
            val existingWorkout = workoutApi.getWorkout(workout.id)
            Log.d(TAG, "Updating workout: ${existingWorkout.id}")
            val response = workoutApi.updateWorkout(existingWorkout.id, workout)
            Log.d(TAG, "Successfully updated workout")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Error updating workout", e)
            Result.failure(e)
        }
    }

    override suspend fun deleteWorkout(workoutId: Int): Result<Unit> {
        return try {
            Log.d(TAG, "Deleting workout: $workoutId")
            workoutApi.deleteWorkout(workoutId)
            Log.d(TAG, "Successfully deleted workout")
            Result.success(Unit)
        } catch (e: Exception) {
            Log.e(TAG, "Error deleting workout", e)
            Result.failure(e)
        }
    }

    override suspend fun toggleWorkoutCompletion(id: Int): Result<WorkoutResponse> {
        return try {
            Log.d(TAG, "Toggling workout completion: $id")
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
            Log.d(TAG, "Fetching workout stats for user: $userId")
            val response = workoutApi.getWorkoutStats(userId)
            Log.d(TAG, "Successfully fetched workout stats")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Error fetching workout stats", e)
            Result.failure(e)
        }
    }

    override fun getAllWorkoutsFlow(): Flow<List<WorkoutResponse>> {
        return flow {
            try {
                val workouts = workoutApi.getAllWorkouts()
                emit(workouts)
            } catch (e: Exception) {
                Log.e(TAG, "Error in getAllWorkoutsFlow", e)
                throw e
            }
        }
    }

    override fun getUserWorkoutsFlow(userId: Int): Flow<List<WorkoutResponse>> {
        return flow {
            try {
                val workouts = workoutApi.getUserWorkoutsById(userId)
                emit(workouts)
            } catch (e: Exception) {
                Log.e(TAG, "Error in getUserWorkoutsFlow", e)
                throw e
            }
        }
    }

    // ... rest of the implementation ...
} 