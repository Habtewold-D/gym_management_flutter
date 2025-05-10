package com.example.gymmanagement.ui.screens.member.workout

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.gymmanagement.data.model.WorkoutResponse
import com.example.gymmanagement.viewmodel.MemberWorkoutViewModel
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.foundation.clickable

private val DeepBlue = Color(0xFF0000CD)
private val Green = Color(0xFF4CAF50)

@Composable
fun MemberWorkoutScreen(
    viewModel: MemberWorkoutViewModel,
    userId: Int
) {
    val TAG = "MemberWorkoutScreen"
    val workouts by viewModel.workouts.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()

    Log.d(TAG, "Initializing MemberWorkoutScreen for user ID: $userId")

    LaunchedEffect(userId) {
        Log.d(TAG, "Loading workouts for user ID: $userId")
        viewModel.loadWorkouts(userId)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
    ) {
        // Top App Bar
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(DeepBlue)
                .padding(vertical = 24.dp, horizontal = 16.dp)
        ) {
            Text(
                text = "Daily Workout",
                color = Color.White,
                fontSize = 28.sp,
                modifier = Modifier.align(Alignment.CenterStart)
            )
        }

        when {
            isLoading -> {
                Log.d(TAG, "Loading state: true")
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }
            error != null -> {
                Log.e(TAG, "Error state: ${error}")
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = error ?: "An error occurred",
                        color = Color.Red,
                        textAlign = TextAlign.Center
                    )
                }
            }
            workouts.isEmpty() -> {
                Log.d(TAG, "No workouts available")
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "No workouts assigned yet.\nCheck back later for your personalized workout plan!",
                        textAlign = TextAlign.Center,
                        fontSize = 16.sp,
                        color = Color.Gray
                    )
                }
            }
            else -> {
                Log.d(TAG, "Displaying ${workouts.size} workouts")
                LazyColumn(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    items(workouts) { workout ->
                        WorkoutCard(
                            workout = workout,
                            onToggleCompletion = { viewModel.toggleWorkoutCompletion(workout.id) }
                        )
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WorkoutCard(
    workout: WorkoutResponse,
    onToggleCompletion: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(170.dp)
            .padding(vertical = 4.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Box(
            modifier = Modifier.fillMaxSize()
        ) {
            // Background image
            AsyncImage(
                model = workout.imageUri,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.matchParentSize()
            )

            // Top left: Title in white rounded box
            Box(
                modifier = Modifier
                    .align(Alignment.TopStart)
                    .padding(12.dp)
            ) {
                Surface(
                    color = Color.White.copy(alpha = 0.95f),
                    shape = RoundedCornerShape(12.dp),
                    shadowElevation = 2.dp,
                ) {
                    Text(
                        text = workout.eventTitle,
                        color = Color.Black,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp)
                    )
                }
            }

            // Top right: Finish/Done overlay button
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(12.dp)
            ) {
                val buttonColor = if (workout.isCompleted) Green else DeepBlue
                val buttonText = if (workout.isCompleted) "Done" else "Finish"
                Surface(
                    color = buttonColor,
                    shape = RoundedCornerShape(8.dp),
                    shadowElevation = 4.dp,
                    modifier = Modifier
                        .height(36.dp)
                        .wrapContentWidth()
                        .then(
                            if (!workout.isCompleted) {
                                Modifier.clickable { onToggleCompletion() }
                            } else {
                                Modifier
                            }
                        )
                ) {
                    Box(
                        modifier = Modifier
                            .padding(horizontal = 18.dp)
                            .fillMaxHeight(),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            buttonText,
                            color = Color.White,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            // Bottom left: Info in a single white rounded box
            Box(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(12.dp)
            ) {
                Surface(
                    color = Color.White.copy(alpha = 0.95f),
                    shape = RoundedCornerShape(12.dp),
                    shadowElevation = 2.dp,
                    modifier = Modifier.fillMaxWidth(0.7f)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp),
                        horizontalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Text(
                            text = "Sets: ${workout.sets}",
                            color = Color.Black,
                            fontSize = 12.sp
                        )
                        Text(
                            text = "Reps/Secs: ${workout.repsOrSecs}",
                            color = Color.Black,
                            fontSize = 12.sp
                        )
                        Text(
                            text = "Rest: ${workout.restTime}s",
                            color = Color.Black,
                            fontSize = 12.sp
                        )
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun MemberWorkoutScreenPreview() {
    val viewModel = MemberWorkoutViewModel()
    MemberWorkoutScreen(viewModel = viewModel, userId = 1)
}
