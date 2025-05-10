package com.example.gymmanagement.data.api

import android.util.Log
import com.example.gymmanagement.data.api.AuthApi
import com.example.gymmanagement.data.api.WorkoutApi
import com.example.gymmanagement.data.api.UserApi
import com.example.gymmanagement.data.api.EventApi
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.ResponseBody.Companion.toResponseBody
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit
import okhttp3.Interceptor

object ApiClient {
    private const val TAG = "ApiClient"
    private var accessToken: String? = null

    // For Android Emulator
    private const val EMULATOR_BASE_URL = "http://10.0.2.2:3000/"  // Make sure this matches your backend URL
    
    // For Physical Device (replace with your computer's IP address)
    private const val PHYSICAL_DEVICE_BASE_URL = "http://192.168.1.91:3000/"  // Replace with your IP
    
    // Choose which URL to use
    private const val BASE_URL = EMULATOR_BASE_URL  // Use this for emulator testing

    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    private val authInterceptor = { chain: Interceptor.Chain ->
        val originalRequest = chain.request()
        val requestBuilder = originalRequest.newBuilder()
        
        // Add the access token to the request header if it exists
        accessToken?.let { token ->
            requestBuilder.header("Authorization", "Bearer $token")
            Log.d(TAG, "Adding Authorization header with token: Bearer $token")
        } ?: run {
            Log.d(TAG, "No access token available for request to: ${originalRequest.url}")
        }
        
        val request = requestBuilder.build()
        Log.d(TAG, "Request headers: ${request.headers}")
        chain.proceed(request)
    }

    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(loggingInterceptor)
        .addInterceptor(authInterceptor)  // Add the auth interceptor
        .addInterceptor { chain ->
            val request = chain.request()
            Log.d(TAG, "Making request to: ${request.url}")
            Log.d(TAG, "Request method: ${request.method}")
            Log.d(TAG, "Request headers: ${request.headers}")
            
            try {
                val response = chain.proceed(request)
                Log.d(TAG, "Response code: ${response.code}")
                
                // Create a new response with a new response body
                val responseBody = response.body
                val responseBodyString = responseBody?.string()
                
                Log.d(TAG, "Raw response body: $responseBodyString")
                
                // Create a new response with the same body
                response.newBuilder()
                    .body(responseBodyString?.toResponseBody(responseBody?.contentType()))
                    .build()
            } catch (e: Exception) {
                Log.e(TAG, "Network error", e)
                throw e
            }
        }
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .retryOnConnectionFailure(true)
        .build()

    private val retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    init {
        Log.d(TAG, "ApiClient initialized with base URL: $BASE_URL")
    }

    fun getAuthApi(): AuthApi = retrofit.create(AuthApi::class.java)
    fun getWorkoutApi(): WorkoutApi = retrofit.create(WorkoutApi::class.java)
    fun getUserApi(): UserApi = retrofit.create(UserApi::class.java)
    fun getEventApi(): EventApi = retrofit.create(EventApi::class.java)

    fun setAccessToken(token: String?) {
        accessToken = token
        Log.d(TAG, "Access token ${if (token != null) "set" else "cleared"}")
    }

    fun getAccessToken(): String? = accessToken
}