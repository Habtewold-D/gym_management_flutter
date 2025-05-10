package com.example.gymmanagement.data.repository

import android.util.Log
import com.example.gymmanagement.data.api.ApiClient
import com.example.gymmanagement.data.model.AuthResponse
import com.example.gymmanagement.data.model.LoginRequest
import com.example.gymmanagement.data.model.RegisterRequest
import com.google.gson.Gson
import com.google.gson.JsonObject
import java.io.IOException

class AuthRepository {
    private val TAG = "AuthRepository"
    private val authApi = ApiClient.getAuthApi()
    private val gson = Gson()

    suspend fun register(
        name: String,
        email: String,
        password: String,
        confirmPassword: String,
        age: Int,
        height: Float,
        weight: Float
    ): Result<AuthResponse> {
        Log.d(TAG, "Starting registration for user: $email")
        return try {
            val request = RegisterRequest(
                name = name,
                email = email,
                password = password,
                confirmPassword = confirmPassword,
                age = age,
                height = height,
                weight = weight
            )
            Log.d(TAG, "Sending registration request: $request")
            
            val response = authApi.register(request)
            Log.d(TAG, "Raw registration response: ${gson.toJson(response)}")
            
            // Check if the response is valid
            if (response == null) {
                Log.e(TAG, "Response is null")
                return Result.failure(Exception("Server returned null response"))
            }

            // Log the response structure
            val responseJson = gson.toJsonTree(response)
            Log.d(TAG, "Response structure: $responseJson")

            // Check if the response has the required fields
            if (response.access_token.isNullOrEmpty()) {
                Log.e(TAG, "Access token is missing or empty. Full response: $response")
                return Result.failure(Exception("Server response missing access token"))
            }

            if (response.user == null) {
                Log.e(TAG, "User object is null in response")
                return Result.failure(Exception("Server response missing user data"))
            }

            // Validate user object
            if (response.user.email.isNullOrEmpty()) {
                Log.e(TAG, "User email is missing or empty")
                return Result.failure(Exception("Server response missing user email"))
            }

            Log.d(TAG, "Registration successful for user: ${response.user.email}")
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Registration failed for user: $email", e)
            when (e) {
                is IOException -> Result.failure(Exception("Network error. Please check your connection."))
                else -> Result.failure(Exception("Registration failed: ${e.message}"))
            }
        }
    }

    suspend fun login(email: String, password: String): Result<AuthResponse> {
        return try {
            Log.d(TAG, "Making login request for email: $email")
            val request = LoginRequest(email, password)
            Log.d(TAG, "Login request body: ${gson.toJson(request)}")
            
            val response = authApi.login(request)
            Log.d(TAG, "Login response: ${gson.toJson(response)}")
            
            // Validate response
            if (response.access_token.isNullOrEmpty()) {
                Log.e(TAG, "Access token is missing in response")
                return Result.failure(Exception("Server response missing access token"))
            }
            
            if (response.user == null) {
                Log.e(TAG, "User data is missing in response")
                return Result.failure(Exception("Server response missing user data"))
            }
            
            Result.success(response)
        } catch (e: Exception) {
            Log.e(TAG, "Login failed with error: ${e.message}", e)
            when (e) {
                is retrofit2.HttpException -> {
                    val errorBody = e.response()?.errorBody()?.string()
                    Log.e(TAG, "HTTP Error response: $errorBody")
                    Result.failure(Exception("Login failed: ${errorBody ?: e.message()}"))
                }
                else -> Result.failure(Exception("Login failed: ${e.message}"))
            }
        }
    }
}