package com.example.gymmanagement.navigation

import android.util.Log
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.gymmanagement.ui.screens.splash.SplashScreen
import com.example.gymmanagement.ui.screens.login.LoginScreen
import com.example.gymmanagement.ui.screens.register.RegisterScreen
import com.example.gymmanagement.ui.screens.admin.AdminScreen
import com.example.gymmanagement.ui.screens.member.MemberScreen
import com.example.gymmanagement.viewmodel.AuthViewModel
import com.example.gymmanagement.GymManagementApp
import com.example.gymmanagement.data.model.UserEntity
import androidx.compose.runtime.State
import androidx.compose.ui.platform.LocalContext

@Composable
fun AppNavigation(app: GymManagementApp) {
    val navController = rememberNavController()
    val authViewModel: AuthViewModel = viewModel(factory = AuthViewModel.provideFactory(app))
    
    val isLoggedIn: State<Boolean> = authViewModel.isLoggedIn.collectAsState()
    val currentUser: State<UserEntity?> = authViewModel.currentUser.collectAsState()

    // Handle initial navigation based on login state
    LaunchedEffect(isLoggedIn.value, currentUser.value) {
        if (isLoggedIn.value && currentUser.value != null) {
            if (currentUser.value?.role?.lowercase() == "admin") {
                navController.navigate(AppRoutes.ADMIN_WORKOUT) {
                    popUpTo(AppRoutes.SPLASH) { inclusive = true }
                    launchSingleTop = true
                }
            } else {
                navController.navigate(AppRoutes.MEMBER_WORKOUT) {
                    popUpTo(AppRoutes.SPLASH) { inclusive = true }
                    launchSingleTop = true
                }
            }
        }
    }

    NavHost(
        navController = navController,
        startDestination = AppRoutes.SPLASH
    ) {
        composable(AppRoutes.SPLASH) {
            SplashScreen(
                navController = navController,
                viewModel = authViewModel
            )
        }

        composable(AppRoutes.LOGIN) {
            LoginScreen(
                navController = navController,
                viewModel = authViewModel,
                onLoginSuccess = { isAdmin ->
                    val route = if (isAdmin) AppRoutes.ADMIN_WORKOUT else AppRoutes.MEMBER_WORKOUT
                    navController.navigate(route) {
                        popUpTo(AppRoutes.LOGIN) { inclusive = true }
                        launchSingleTop = true
                    }
                }
            )
        }

        composable(AppRoutes.REGISTER) {
            RegisterScreen(
                navController = navController,
                viewModel = authViewModel
            )
        }

        // Admin Routes
        composable(AppRoutes.ADMIN_WORKOUT) {
            AdminScreen(
                navController = navController,
                viewModel = authViewModel
            )
        }

        composable(AppRoutes.ADMIN_EVENT) {
            AdminScreen(
                navController = navController,
                viewModel = authViewModel
            )
        }

        composable(AppRoutes.ADMIN_PROGRESS) {
            AdminScreen(
                navController = navController,
                viewModel = authViewModel
            )
        }

        composable(AppRoutes.ADMIN_MEMBER) {
            AdminScreen(
                navController = navController,
                viewModel = authViewModel
            )
        }

        // Member Routes
        composable(AppRoutes.MEMBER_WORKOUT) {
            MemberScreen(
                navController = navController,
                viewModel = authViewModel
            )
        }

        composable(AppRoutes.MEMBER_EVENT) {
            MemberScreen(
                navController = navController,
                viewModel = authViewModel
            )
        }

        composable(AppRoutes.MEMBER_PROFILE) {
            MemberScreen(
                navController = navController,
                viewModel = authViewModel
            )
        }
    }
}


