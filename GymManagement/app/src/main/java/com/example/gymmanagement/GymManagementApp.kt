package com.example.gymmanagement

import android.app.Application
import android.content.Context
import com.example.gymmanagement.data.repository.UserRepository
import com.example.gymmanagement.data.repository.UserRepositoryImpl

class GymManagementApp : Application() {
    // Repository instances
    val userRepository: UserRepository by lazy {
        UserRepositoryImpl(context = applicationContext)
    }

    companion object {
        private lateinit var instance: GymManagementApp
        
        fun getInstance(): GymManagementApp {
            return instance
        }
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
    }
} 