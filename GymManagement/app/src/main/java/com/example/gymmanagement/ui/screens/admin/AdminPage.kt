package com.example.gymmanagement.ui.screens.admin

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.BottomNavigation
import androidx.compose.material3.BottomNavigationItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.icons.Icons
import androidx.compose.material3.icons.filled.Event
import androidx.compose.material3.icons.filled.FitnessCenter
import androidx.compose.material3.icons.filled.Person
import androidx.compose.material3.icons.filled.ShowChart
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.compose.currentBackStackEntryAsState
import com.example.gymmanagement.ui.screens.admin.event.AdminEventScreen
import com.example.gymmanagement.ui.screens.admin.member.AdminMemberScreen
import com.example.gymmanagement.ui.screens.admin.progress.AdminProgressScreen
import com.example.gymmanagement.ui.screens.admin.workout.AdminWorkoutScreen

@Composable
fun AdminPage() {
    val navController = rememberNavController()
    Scaffold(
        bottomBar = {
            BottomNavigation {
                val currentRoute = currentRoute(navController)
                BottomNavigationItem(
                    icon = { Icon(Icons.Filled.FitnessCenter, contentDescription = "Workout") },
                    selected = currentRoute == "workout",
                    onClick = {
                        navController.navigate("workout") {
                            popUpTo("workout") { inclusive = false }
                            launchSingleTop = true
                        }
                    }
                )
                BottomNavigationItem(
                    icon = { Icon(Icons.Filled.Event, contentDescription = "Event") },
                    selected = currentRoute == "event",
                    onClick = {
                        navController.navigate("event") {
                            popUpTo("event") { inclusive = false }
                            launchSingleTop = true
                        }
                    }
                )
                BottomNavigationItem(
                    icon = { Icon(Icons.Filled.Person, contentDescription = "Member") },
                    selected = currentRoute == "member",
                    onClick = {
                        navController.navigate("member") {
                            popUpTo("member") { inclusive = false }
                            launchSingleTop = true
                        }
                    }
                )
                BottomNavigationItem(
                    icon = { Icon(Icons.Filled.ShowChart, contentDescription = "Progress") },
                    selected = currentRoute == "progress",
                    onClick = {
                        navController.navigate("progress") {
                            popUpTo("progress") { inclusive = false }
                            launchSingleTop = true
                        }
                    }
                )
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = "workout",
            modifier = Modifier.padding(innerPadding)
        ) {
            composable("workout") { AdminWorkoutScreen() }
            composable("event") { AdminEventScreen() }
            composable("member") { AdminMemberScreen() }
            composable("progress") { AdminProgressScreen() }
        }
    }
}

@Composable
fun currentRoute(navController: androidx.navigation.NavHostController): String? {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    return navBackStackEntry?.destination?.route
}
