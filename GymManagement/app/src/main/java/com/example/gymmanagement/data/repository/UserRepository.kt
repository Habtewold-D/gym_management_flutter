package com.example.gymmanagement.data.repository

import android.content.Context
import android.util.Log
import com.example.gymmanagement.data.api.ApiClient
import com.example.gymmanagement.data.model.UserProfile
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

interface UserRepository {
    suspend fun getUserProfile(userId: Int): Result<UserProfile>
    suspend fun updateUserProfile(userId: Int, profile: UserProfile): Result<UserProfile>
    suspend fun getAllUsers(): Result<List<UserProfile>>
    
    // Session management
    suspend fun getCurrentUser(): UserProfile?
    suspend fun saveCurrentUser(profile: UserProfile)
    suspend fun clearCurrentUser()
    
    // Flow wrappers for UI
    fun getAllUsersFlow(): Flow<List<UserProfile>>

    suspend fun getUserProfile(email: String): UserProfile?

    suspend fun getUserByEmail(email: String): UserProfile?
}

class UserRepositoryImpl(
    private val context: Context
) : UserRepository {
    private val TAG = "UserRepositoryImpl"
    private val sharedPreferences = context.applicationContext.getSharedPreferences("user_session", Context.MODE_PRIVATE)
    private val userApi = ApiClient.getUserApi()

    override suspend fun getUserProfile(userId: Int): Result<UserProfile> {
        return try {
            val response = userApi.getUserProfile(userId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun updateUserProfile(userId: Int, profile: UserProfile): Result<UserProfile> {
        Log.d(TAG, "Updating user profile for ID: $userId")
        Log.d(TAG, "Profile data: $profile")
        return try {
            Log.d(TAG, "Making API call to update user profile")
            val response = userApi.updateUserProfile(userId, profile)
            Log.d(TAG, "API Response: $response")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Error updating user profile", e)
            when (e) {
                is retrofit2.HttpException -> {
                    val errorBody = e.response()?.errorBody()?.string()
                    Log.e(TAG, "HTTP Error response: $errorBody")
                    Log.e(TAG, "HTTP Error code: ${e.code()}")
                    Result.failure(Exception("Server error: ${e.code()} - $errorBody"))
                }
                else -> {
                    Log.e(TAG, "Unexpected error: ${e.message}")
                    Result.failure(e)
                }
            }
        }
    }

    override suspend fun getAllUsers(): Result<List<UserProfile>> {
        return try {
            val response = userApi.getAllUsers()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // Session management
    override suspend fun getCurrentUser(): UserProfile? {
        val userId = sharedPreferences.getInt("current_user_id", -1)
        return if (userId != -1) {
            getUserProfile(userId).getOrNull()
        } else null
    }

    override suspend fun saveCurrentUser(profile: UserProfile) {
        sharedPreferences.edit()
            .putInt("current_user_id", profile.id)
            .apply()
    }

    override suspend fun clearCurrentUser() {
        sharedPreferences.edit()
            .remove("current_user_id")
            .apply()
    }

    // Flow wrapper for UI
    override fun getAllUsersFlow(): Flow<List<UserProfile>> = flow {
        getAllUsers().onSuccess { users ->
            emit(users)
        }
    }

    override suspend fun getUserProfile(email: String): UserProfile? {
        Log.d(TAG, "Getting user profile for email: $email")
        return try {
            Log.d(TAG, "Making API call to getUserByEmail with email: $email")
            val response = userApi.getUserByEmail(email)
            Log.d(TAG, "API Response: $response")
            response
        } catch (e: Exception) {
            Log.e(TAG, "Error getting user profile", e)
            when (e) {
                is retrofit2.HttpException -> {
                    val errorBody = e.response()?.errorBody()?.string()
                    Log.e(TAG, "HTTP Error response: $errorBody")
                    Log.e(TAG, "HTTP Error code: ${e.code()}")
                }
                else -> Log.e(TAG, "Unexpected error: ${e.message}")
            }
            null
        }
    }

    override suspend fun getUserByEmail(email: String): UserProfile? {
        return try {
            val response = userApi.getUserByEmail(email)
            response
        } catch (e: Exception) {
            null
        }
    }
}
