//package com.example.gymmanagement.ui.screens.admin.progress
//
//import androidx.compose.foundation.background
//import androidx.compose.foundation.layout.*
//import androidx.compose.foundation.lazy.LazyColumn
//import androidx.compose.foundation.lazy.items
//import androidx.compose.foundation.lazy.itemsIndexed
//import androidx.compose.foundation.shape.RoundedCornerShape
//import androidx.compose.material3.*
//import androidx.compose.runtime.*
//import androidx.compose.ui.Alignment
//import androidx.compose.ui.Modifier
//import androidx.compose.ui.draw.clip
//import androidx.compose.ui.graphics.Color
//import androidx.compose.ui.text.font.FontWeight
//import androidx.compose.ui.tooling.preview.Preview
//import androidx.compose.ui.unit.dp
//import androidx.compose.ui.unit.sp
//import com.example.gymmanagement.data.model.TraineeProgress
//import com.example.gymmanagement.data.repository.TraineeProgressRepository
//import com.example.gymmanagement.ui.theme.GymManagementAppTheme
//import com.example.gymmanagement.viewmodel.AdminProgressViewModel
//import kotlinx.coroutines.flow.Flow
//import kotlinx.coroutines.flow.flowOf
//import androidx.lifecycle.viewmodel.compose.viewModel
//import com.example.gymmanagement.data.repository.TraineeProgressRepositoryImpl
//import androidx.compose.runtime.LaunchedEffect
//import kotlinx.coroutines.Dispatchers
//import kotlinx.coroutines.withContext
//import com.example.gymmanagement.data.repository.UserRepositoryImpl
//import com.example.gymmanagement.data.model.UserProfile.UserProfile
//import kotlinx.coroutines.delay
//
//private val DeepBlue = Color(0xFF0000CD)
//private val LightBlue = Color(0xFFE6E9FD)
//private val Green = Color(0xFF4CAF50)
//
//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun AdminProgressScreen(
//    viewModel: AdminProgressViewModel,
//    userRepository: UserRepositoryImpl
//) {
//    val progressList by viewModel.allProgress.collectAsState()
//    var allMembers by remember { mutableStateOf<List<UserProfile>>(emptyList()) }
//    var progressByTraineeId by remember { mutableStateOf<Map<Int, Int>>(emptyMap()) }
//
//    // Collect all members/trainees
//    LaunchedEffect(Unit) {
//        userRepository.getAllUserProfiles().collect { profiles ->
//            allMembers = profiles
//        }
//    }
//
//    // Build a map of traineeId to progress percent from TraineeProgress
//    LaunchedEffect(progressList) {
//        val map = mutableMapOf<Int, Int>()
//        for (progress in progressList) {
//            val id = progress.traineeId.toIntOrNull() ?: continue
//            map[id] = progress.progressPercentage
//        }
//        progressByTraineeId = map
//    }
//
//    // Refresh progress data periodically
//    LaunchedEffect(Unit) {
//        while (true) {
//            delay(5000) // Refresh every 5 seconds
//            viewModel.loadProgress()
//        }
//    }
//
//    Column(
//        modifier = Modifier
//            .fillMaxSize()
//            .background(Color.White)
//    ) {
//        // Top Bar
//        Box(
//            modifier = Modifier
//                .fillMaxWidth()
//                .background(DeepBlue)
//                .padding(vertical = 18.dp, horizontal = 16.dp)
//        ) {
//            Text(
//                text = "Gym Progress",
//                color = Color.White,
//                fontSize = 22.sp,
//                fontWeight = FontWeight.Bold
//            )
//        }
//        Text(
//            text = "Daily Progress",
//            color = DeepBlue,
//            fontSize = 20.sp,
//            fontWeight = FontWeight.Bold,
//            modifier = Modifier.padding(start = 16.dp, top = 16.dp, bottom = 12.dp)
//        )
//        LazyColumn(
//            modifier = Modifier.padding(horizontal = 12.dp),
//            verticalArrangement = Arrangement.spacedBy(12.dp)
//        ) {
//            itemsIndexed(allMembers) { idx, member ->
//                val percent = progressByTraineeId[member.id] ?: 0
//                ProgressCard(idx + 1, member.name, percent, member.id)
//            }
//        }
//    }
//}
//
//@Composable
//fun ProgressCard(number: Int, name: String, percent: Int, id: Int) {
//    Row(
//        modifier = Modifier
//            .fillMaxWidth()
//            .height(48.dp)
//            .clip(RoundedCornerShape(8.dp))
//            .background(Color(0xFFE6E9FD)),
//        verticalAlignment = Alignment.CenterVertically
//    ) {
//        Text(
//            text = "$number.",
//            fontWeight = FontWeight.Bold,
//            color = Color(0xFF0000CD),
//            fontSize = 16.sp,
//            modifier = Modifier.padding(start = 12.dp)
//        )
//        Text(
//            text = name,
//            fontSize = 16.sp,
//            color = Color.Black,
//            modifier = Modifier.padding(start = 8.dp).weight(1f)
//        )
//        Text(
//            text = "$percent%",
//            fontWeight = FontWeight.Bold,
//            color = Color(0xFF0000CD),
//            fontSize = 16.sp,
//            modifier = Modifier.padding(end = 16.dp)
//        )
//    }
//}
//
//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun TraineeProgressItem(
//    progress: TraineeProgress,
//    onUpdate: (TraineeProgress) -> Unit
//) {
//    Card(
//        modifier = Modifier
//            .fillMaxWidth()
//            .height(160.dp),
//        shape = RoundedCornerShape(8.dp)
//    ) {
//        Column(
//            modifier = Modifier
//                .fillMaxSize()
//                .padding(16.dp)
//        ) {
//            Text(
//                text = "Trainee ID: ${progress.traineeId}",
//                style = MaterialTheme.typography.titleMedium
//            )
//            Spacer(modifier = Modifier.height(8.dp))
//            Text(
//                text = "Completed Workouts: ${progress.completedWorkouts}",
//                style = MaterialTheme.typography.bodyLarge
//            )
//            Text(
//                text = "Total Workouts: ${progress.totalWorkouts}",
//                style = MaterialTheme.typography.bodyLarge
//            )
//            Text(
//                text = "Progress: ${progress.progressPercentage}%",
//                style = MaterialTheme.typography.bodyLarge
//            )
//        }
//    }
//}
//
