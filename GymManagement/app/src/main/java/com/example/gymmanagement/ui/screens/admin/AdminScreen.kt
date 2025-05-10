//package com.example.gymmanagement.ui.screens.admin
//
//import android.util.Log
//import androidx.activity.compose.BackHandler
//import androidx.compose.foundation.layout.*
//import androidx.compose.material3.*
//import androidx.compose.runtime.*
//import androidx.compose.ui.Alignment
//import androidx.compose.ui.Modifier
//import androidx.compose.ui.graphics.Color
//import androidx.compose.ui.graphics.vector.ImageVector
//import androidx.compose.ui.platform.LocalContext
//import androidx.compose.ui.res.painterResource
//import androidx.compose.ui.graphics.painter.Painter
//import androidx.navigation.NavController
//import androidx.navigation.compose.NavHost
//import androidx.navigation.compose.composable
//import androidx.navigation.compose.currentBackStackEntryAsState
//import androidx.navigation.compose.rememberNavController
//import com.example.gymmanagement.navigation.AppRoutes
//import com.example.gymmanagement.viewmodel.*
//import androidx.compose.material.icons.Icons
//import androidx.compose.material.icons.filled.*
//import androidx.compose.ui.unit.dp
//import com.example.gymmanagement.ui.screens.admin.workout.AdminWorkoutScreen
//import com.example.gymmanagement.ui.screens.admin.event.AdminEventScreen
////import com.example.gymmanagement.ui.screens.admin.member.AdminMemberScreen
////import com.example.gymmanagement.ui.screens.admin.progress.AdminProgressScreen
//import com.example.gymmanagement.data.repository.WorkoutRepositoryImpl
//import com.example.gymmanagement.data.repository.EventRepository
//import com.example.gymmanagement.data.repository.UserRepositoryImpl
//import com.example.gymmanagement.data.repository.TraineeProgressRepositoryImpl
//import com.example.gymmanagement.utils.ImagePicker
//import com.example.gymmanagement.R
//
//private val PrimaryBlue = Color(0xFF0000FF)
//private val BackgroundGray = Color(0xFFF5F5F5)
//private val CardBlue = Color(0xFFE6E9FD)
//private val Green = Color(0xFF4CAF50)
//
//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun AdminScreen(
//    navController: NavController,
//    viewModel: AuthViewModel
//) {
//    val context = LocalContext.current
//    val adminNavController = rememberNavController()
//    val currentRoute = currentRoute(adminNavController)
//
//    // Initialize repositories
//    val workoutRepository = remember { WorkoutRepositoryImpl() }
//    val eventRepository = remember { EventRepository() }
//    val userRepository = remember { UserRepositoryImpl(context) }
//    val traineeProgressRepository = remember { TraineeProgressRepositoryImpl() }
//    val imagePicker = remember { ImagePicker(context) }
//
//    // Initialize ViewModels
//    val adminWorkoutViewModel = remember {
//        AdminWorkoutViewModel(workoutRepository, imagePicker)
//    }
//    val adminEventViewModel = remember {
//        AdminEventViewModel(eventRepository)
//    }
////    val adminMemberViewModel = remember {
////        AdminMemberViewModel(userRepository)
////    }
//    val adminProgressViewModel = remember {
//        AdminProgressViewModel(traineeProgressRepository)
//    }
//
//    // Check login state
//    val isLoggedIn by viewModel.isLoggedIn.collectAsState()
//    val currentUser by viewModel.currentUser.collectAsState()
//
//    LaunchedEffect(isLoggedIn, currentUser) {
//        if (!isLoggedIn || currentUser == null || currentUser?.role?.lowercase() != "admin") {
//            Log.d("AdminScreen", "Not logged in or not an admin, navigating to login")
//            navController.navigate(AppRoutes.LOGIN) {
//                popUpTo(0) { inclusive = true }
//                launchSingleTop = true
//            }
//        }
//    }
//
//    // Set up initial route
//    LaunchedEffect(Unit) {
//        Log.d("AdminScreen", "Setting up initial route")
//        adminNavController.navigate(AppRoutes.ADMIN_WORKOUT) {
//            popUpTo(0) { inclusive = true }
//            launchSingleTop = true
//        }
//    }
//
//    // Bottom navigation items
//    val bottomNavItems = listOf(
//        BottomNavItem(
//            label = "Workouts",
//            icon = painterResource(id = R.drawable.ic_workout_icon),
//            route = AppRoutes.ADMIN_WORKOUT
//        ),
//        BottomNavItem(
//            label = "Events",
//            icon = painterResource(id = R.drawable.ic_event_icon),
//            route = AppRoutes.ADMIN_EVENT
//        ),
//        BottomNavItem(
//            label = "Progress",
//            icon = painterResource(id = R.drawable.ic_progress_icon),
//            route = AppRoutes.ADMIN_PROGRESS
//        ),
//        BottomNavItem(
//            label = "Members",
//            icon = painterResource(id = R.drawable.ic_member_icon),
//            route = AppRoutes.ADMIN_MEMBER
//        ),
//    )
//
//    Scaffold(
//        bottomBar = {
//            NavigationBar(
//                containerColor = Color(0xFFF1F1F1)
//            ) {
//                bottomNavItems.forEach { item ->
//                    val isSelected = currentRoute == item.route
//                    NavigationBarItem(
//                        icon = {
//                            Box(
//                                modifier = Modifier.size(32.dp),
//                                contentAlignment = Alignment.Center
//                            ) {
//                                when (val icon = item.icon) {
//                                    is Painter -> Icon(
//                                        painter = icon,
//                                        contentDescription = item.label,
//                                        tint = if (isSelected) Green else Color.Black,
//                                        modifier = Modifier.size(28.dp)
//                                    )
//                                    is ImageVector -> Icon(
//                                        imageVector = icon,
//                                        contentDescription = item.label,
//                                        tint = if (isSelected) Green else Color.Black,
//                                        modifier = Modifier.size(28.dp)
//                                    )
//                                }
//                            }
//                        },
//                        label = {
//                            Text(
//                                text = item.label,
//                                color = if (isSelected) Green else Color.Black
//                            )
//                        },
//                        selected = isSelected,
//                        onClick = {
//                            if (currentRoute != item.route) {
//                                adminNavController.navigate(item.route) {
//                                    popUpTo(adminNavController.graph.startDestinationId)
//                                    launchSingleTop = true
//                                }
//                            }
//                        },
//                        colors = NavigationBarItemDefaults.colors(
//                            selectedIconColor = Green,
//                            selectedTextColor = Green,
//                            unselectedIconColor = Color.Black,
//                            unselectedTextColor = Color.Black,
//                            indicatorColor = Color.Transparent
//                        )
//                    )
//                }
//            }
//        }
//    ) { paddingValues ->
//        NavHost(
//            navController = adminNavController,
//            startDestination = AppRoutes.ADMIN_WORKOUT,
//            modifier = Modifier.padding(paddingValues)
//        ) {
//            composable(AppRoutes.ADMIN_WORKOUT) {
//                AdminWorkoutScreen(viewModel = adminWorkoutViewModel)
//            }
//            composable(AppRoutes.ADMIN_EVENT) {
//                AdminEventScreen(viewModel = adminEventViewModel)
//            }
////            composable(AppRoutes.ADMIN_MEMBER) {
////                AdminMemberScreen(viewModel = adminMemberViewModel)
////            }
////            composable(AppRoutes.ADMIN_PROGRESS) {
////                AdminProgressScreen(viewModel = adminProgressViewModel, userRepository = userRepository)
////            }
//        }
//    }
//
//    // Handle back press (navigate to login)
//    BackHandler {
//        viewModel.logout()
//        navController.navigate(AppRoutes.LOGIN) {
//            popUpTo(0) { inclusive = true }
//        }
//    }
//}
//
//@Composable
//private fun currentRoute(navController: NavController): String? {
//    val navBackStackEntry by navController.currentBackStackEntryAsState()
//    return navBackStackEntry?.destination?.route
//}
//
//private data class BottomNavItem(
//    val label: String,
//    val icon: Any,
//    val route: String
//)
