package com.example.gymmanagement.ui.screens.member

import android.util.Log
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.example.gymmanagement.data.repository.WorkoutRepositoryImpl
import com.example.gymmanagement.data.repository.EventRepository
import com.example.gymmanagement.data.repository.UserRepositoryImpl
import com.example.gymmanagement.data.repository.TraineeProgressRepositoryImpl
import com.example.gymmanagement.navigation.AppRoutes
import com.example.gymmanagement.R
import com.example.gymmanagement.ui.screens.member.workout.MemberWorkoutScreen
import com.example.gymmanagement.ui.screens.member.profile.MemberProfileScreen
import com.example.gymmanagement.ui.screens.member.event.MemberEventScreen
import com.example.gymmanagement.viewmodel.*
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.dp
import com.example.gymmanagement.data.model.UserProfile
import com.example.gymmanagement.data.repository.EventRepositoryImpl
import com.example.gymmanagement.viewmodel.MemberWorkoutViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MemberScreen(
    navController: NavController,
    viewModel: AuthViewModel
) {
    val TAG = "MemberScreen"
    val context = LocalContext.current
    val memberNavController = rememberNavController()
    val currentRoute = currentRoute(memberNavController)

    Log.d(TAG, "Initializing MemberScreen")

    // Set status bar color to white for visibility
    androidx.compose.runtime.SideEffect {
        val window = (context as? android.app.Activity)?.window
        window?.statusBarColor = Color.White.toArgb()
    }

    // Initialize repositories with proper error handling
    val workoutRepository = remember { 
        try {
            Log.d(TAG, "Initializing WorkoutRepository")
            WorkoutRepositoryImpl()
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing WorkoutRepository", e)
            null
        }
    }
    
    val eventRepository = remember {
        try {
            Log.d(TAG, "Initializing EventRepository")
            EventRepositoryImpl()
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing EventRepository", e)
            null
        }
    }
    
    // Initialize ViewModels with proper error handling
    val memberWorkoutViewModel = remember { 
        try {
            Log.d(TAG, "Initializing MemberWorkoutViewModel")
            if (workoutRepository != null) {
                MemberWorkoutViewModel(workoutRepository)
            } else {
                Log.e(TAG, "WorkoutRepository is null")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing MemberWorkoutViewModel", e)
            null
        }
    }
    
    val memberEventViewModel = remember {
        try {
            if (eventRepository != null) {
                MemberEventViewModel(eventRepository)
            } else {
                Log.e("MemberScreen", "EventRepository is null")
                null
            }
        } catch (e: Exception) {
            Log.e("MemberScreen", "Error initializing MemberEventViewModel", e)
            null
        }
    }
    
    // Get user data from AuthViewModel
    val isAuthenticated by viewModel.isAuthenticated.collectAsState()
    val userData by viewModel.userData.collectAsState()

    Log.d(TAG, "Authentication state - isAuthenticated: $isAuthenticated, userData: ${userData != null}")

    // Check authentication state
    LaunchedEffect(isAuthenticated, userData) {
        if (!isAuthenticated || userData == null) {
            Log.d(TAG, "Not authenticated or no user data, navigating to login")
            navController.navigate(AppRoutes.LOGIN) {
                popUpTo(0) { inclusive = true }
                launchSingleTop = true
            }
        } else {
            Log.d(TAG, "User authenticated, proceeding to member screen")
        }
    }

    // Set up initial route
    LaunchedEffect(Unit) {
        Log.d("MemberScreen", "Setting up initial route")
        memberNavController.navigate(AppRoutes.MEMBER_WORKOUT) {
            popUpTo(0) { inclusive = true }
            launchSingleTop = true
        }
    }

    // Bottom navigation items
    val bottomNavItems = listOf(
        BottomNavItem(
            label = "Workout",
            icon = painterResource(id = R.drawable.ic_workout_icon),
            route = AppRoutes.MEMBER_WORKOUT
        ),
        BottomNavItem(
            label = "Events",
            icon = painterResource(id = R.drawable.ic_event_icon),
            route = AppRoutes.MEMBER_EVENT
        ),
        BottomNavItem(
            label = "Profile",
            icon = painterResource(id = R.drawable.ic_profile_icon),
            route = AppRoutes.MEMBER_PROFILE
        )
    )

    val Green = Color(0xFF4CAF50)
    val PrimaryBlue = Color(0xFF0000CD)

    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = Color(0xFFF1F1F1)
            ) {
                bottomNavItems.forEach { item ->
                    val isSelected = currentRoute == item.route
                    NavigationBarItem(
                        icon = {
                            Box(
                                modifier = Modifier.size(32.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    painter = item.icon as androidx.compose.ui.graphics.painter.Painter,
                                    contentDescription = item.label,
                                    tint = if (isSelected) Green else Color.Black,
                                    modifier = Modifier.size(28.dp)
                                )
                            }
                        },
                        label = {
                            Text(
                                item.label,
                                color = if (isSelected) Green else Color.Black
                            )
                        },
                        selected = isSelected,
                        onClick = {
                            if (currentRoute != item.route) {
                                memberNavController.navigate(item.route) {
                                    popUpTo(memberNavController.graph.startDestinationId)
                                    launchSingleTop = true
                                }
                            }
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = Green,
                            selectedTextColor = Green,
                            unselectedIconColor = Color.Black,
                            unselectedTextColor = Color.Black
                        )
                    )
                }
            }
        }
    ) { paddingValues ->
        NavHost(
            navController = memberNavController,
            startDestination = AppRoutes.MEMBER_WORKOUT,
            modifier = Modifier.padding(paddingValues)
        ) {
            composable(AppRoutes.MEMBER_WORKOUT) {
                if (memberWorkoutViewModel != null) {
                    userData?.user?.let { user ->
                        MemberWorkoutScreen(
                            viewModel = memberWorkoutViewModel,
                            userId = user.id
                        )
                    } ?: run {
                        Box(
                            modifier = Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("User data not available")
                        }
                    }
                } else {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("Error initializing workout screen")
                    }
                }
            }
            composable(AppRoutes.MEMBER_EVENT) {
                if (memberEventViewModel != null) {
                    MemberEventScreen(viewModel = memberEventViewModel)
                } else {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("Error initializing event screen")
                    }
                }
            }
            composable(AppRoutes.MEMBER_PROFILE) {
                userData?.user?.let { user ->
                    MemberProfileScreen(
                        userEmail = user.email,
                        onLogout = {
                            viewModel.logout()
                            navController.navigate(AppRoutes.LOGIN) {
                                popUpTo(0) { inclusive = true }
                            }
                        }
                    )
                } ?: run {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("Please log in to view your profile")
                    }
                }
            }
        }
    }
}

@Composable
private fun currentRoute(navController: NavController): String? {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    return navBackStackEntry?.destination?.route
}

private data class BottomNavItem(
    val label: String,
    val icon: Any,  // Changed from ImageVector to Any to support both ImageVector and Painter
    val route: String
)