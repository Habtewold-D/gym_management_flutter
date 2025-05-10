package com.example.gymmanagement.data.repository

import android.content.Context
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
        return try {
            val response = userApi.updateUserProfile(userId, profile)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
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
        return try {
            val response = userApi.getUserByEmail(email)
            response
        } catch (e: Exception) {
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
