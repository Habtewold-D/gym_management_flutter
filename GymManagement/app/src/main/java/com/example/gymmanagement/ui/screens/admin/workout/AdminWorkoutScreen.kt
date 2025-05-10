//package com.example.gymmanagement.ui.screens.admin.workout
//
//import android.net.Uri
//import androidx.compose.foundation.background
//import androidx.compose.foundation.clickable
//import androidx.compose.foundation.layout.*
//import androidx.compose.foundation.lazy.LazyColumn
//import androidx.compose.foundation.lazy.items
//import androidx.compose.foundation.shape.RoundedCornerShape
//import androidx.compose.material.icons.Icons
//import androidx.compose.material.icons.filled.*
//import androidx.compose.material3.*
//import androidx.compose.runtime.*
//import androidx.compose.ui.Alignment
//import androidx.compose.ui.Modifier
//import androidx.compose.ui.draw.clip
//import androidx.compose.ui.graphics.Color
//import androidx.compose.ui.layout.ContentScale
//import androidx.compose.ui.platform.LocalContext
//import androidx.compose.ui.text.font.FontWeight
//import androidx.compose.ui.text.style.TextOverflow
//import androidx.compose.ui.unit.dp
//import androidx.compose.ui.unit.sp
//import androidx.compose.ui.window.Dialog
//import androidx.compose.ui.window.DialogProperties
//import coil.compose.AsyncImage
//import com.example.gymmanagement.data.model.Workout
//import com.example.gymmanagement.viewmodel.AdminWorkoutViewModel
//import com.example.gymmanagement.utils.rememberImagePicker
//import androidx.compose.foundation.text.KeyboardOptions
//import androidx.compose.ui.text.input.KeyboardType
//
//private val DeepBlue = Color(0xFF0000CD)
//private val LightBlue = Color(0xFFE6E9FD)
//private val Green = Color(0xFF4CAF50)
//
//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun AdminWorkoutScreen(
//    viewModel: AdminWorkoutViewModel
//) {
//    var showEditDialog by remember { mutableStateOf(false) }
//    var selectedWorkout by remember { mutableStateOf<Workout?>(null) }
//    val workouts by viewModel.workouts.collectAsState(initial = emptyList())
//
//    Column(
//        modifier = Modifier
//            .fillMaxSize()
//            .background(Color.White)
//    ) {
//        // Top Navigation Bar
//        Surface(
//            color = DeepBlue,
//            shadowElevation = 4.dp
//        ) {
//            Row(
//                modifier = Modifier
//                    .fillMaxWidth()
//                    .padding(16.dp),
//                horizontalArrangement = Arrangement.SpaceBetween,
//                verticalAlignment = Alignment.CenterVertically
//            ) {
//                Text(
//                    text = "Workouts",
//                    fontSize = 24.sp,
//                    fontWeight = FontWeight.Bold,
//                    color = Color.White
//                )
//            }
//        }
//
//        Column(
//            modifier = Modifier
//                .fillMaxSize()
//                .padding(horizontal = 12.dp, vertical = 8.dp)
//        ) {
//            Text(
//                text = "Add Workout",
//                style = MaterialTheme.typography.titleMedium.copy(color = Color.Blue),
//                modifier = Modifier.padding(bottom = 2.dp)
//            )
//
//            WorkoutForm(
//                onWorkoutCreated = { workout ->
//                    viewModel.insertWorkout(workout)
//                }
//            )
//
//            Spacer(modifier = Modifier.height(1.dp))
//
//            Text(
//                text = "Workout List",
//                style = MaterialTheme.typography.titleMedium,
//                modifier = Modifier.padding(bottom = 1.dp)
//            )
//
//            LazyColumn(
//                verticalArrangement = Arrangement.spacedBy(8.dp)
//            ) {
//                items(workouts) { workout ->
//                    WorkoutCard(
//                        workout = workout,
//                        onEditClick = {
//                            selectedWorkout = workout
//                            showEditDialog = true
//                        }
//                    )
//                }
//            }
//        }
//    }
//
//    if (showEditDialog) {
//        EditWorkoutDialog(
//            workout = selectedWorkout,
//            onDismissRequest = { showEditDialog = false },
//            onConfirm = { updatedWorkout ->
//                if (updatedWorkout.eventTitle == "DELETE_WORKOUT") {
//                    selectedWorkout?.let { viewModel.deleteWorkout(it) }
//                } else {
//                    viewModel.updateWorkout(updatedWorkout)
//                }
//                showEditDialog = false
//            }
//        )
//    }
//}
//
//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun WorkoutForm(
//    onWorkoutCreated: (Workout) -> Unit
//) {
//    var eventTitle by remember { mutableStateOf("") }
//    var traineeId by remember { mutableStateOf("") }
//    var sets by remember { mutableStateOf("") }
//    var repsOrSecs by remember { mutableStateOf("") }
//    var restTime by remember { mutableStateOf("") }
//    var imageUri by remember { mutableStateOf<Uri?>(null) }
//
//    val context = LocalContext.current
//    val imagePickerUtil = remember { com.example.gymmanagement.utils.ImagePicker(context) }
//    val imagePicker = rememberImagePicker { uri ->
//        val savedPath = imagePickerUtil.saveImageToInternalStorage(uri)
//        if (savedPath != null) imageUri = Uri.parse(savedPath)
//    }
//
//    Column(modifier = Modifier.fillMaxWidth()) {
//        Box(
//            modifier = Modifier
//                .fillMaxWidth()
//                .height(180.dp)
//                .background(Color(0xFF9DB7F5), shape = RoundedCornerShape(16.dp))
//                .clickable { imagePicker.launch("image/*") },
//            contentAlignment = Alignment.Center
//        ) {
//            if (imageUri != null) {
//                AsyncImage(
//                    model = imageUri,
//                    contentDescription = null,
//                    modifier = Modifier
//                        .fillMaxSize()
//                        .clip(RoundedCornerShape(16.dp)),
//                    contentScale = ContentScale.Crop
//                )
//            } else {
//                Column(horizontalAlignment = Alignment.CenterHorizontally) {
//                    Icon(
//                        imageVector = Icons.Filled.Image,
//                        contentDescription = "Add Image",
//                        tint = Color(0xFF1A18C6),
//                        modifier = Modifier.size(48.dp)
//                    )
//                    Spacer(modifier = Modifier.height(8.dp))
//                    Text(
//                        text = "Tap to add an image",
//                        color = Color(0xFF444444),
//                        fontSize = 18.sp
//                    )
//                }
//            }
//        }
//
//        Spacer(modifier = Modifier.height(2.dp))
//        OutlinedTextField(
//            value = eventTitle,
//            onValueChange = { eventTitle = it },
//            label = { Text("Workout title", fontSize = 12.sp) },
//            placeholder = { Text("Enter title", fontSize = 12.sp) },
//            modifier = Modifier.fillMaxWidth(),
//            shape = RoundedCornerShape(4.dp),
//            colors = OutlinedTextFieldDefaults.colors(
//                unfocusedBorderColor = LightBlue,
//                focusedBorderColor = DeepBlue
//            )
//        )
//        Spacer(modifier = Modifier.height(1.dp))
//        OutlinedTextField(
//            value = traineeId,
//            onValueChange = { traineeId = it },
//            label = { Text("Trainee ID", fontSize = 12.sp) },
//            placeholder = { Text("Enter trainee ID", fontSize = 12.sp) },
//            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
//            modifier = Modifier.fillMaxWidth(),
//            shape = RoundedCornerShape(4.dp),
//            colors = OutlinedTextFieldDefaults.colors(
//                unfocusedBorderColor = LightBlue,
//                focusedBorderColor = DeepBlue
//            )
//        )
//        Spacer(modifier = Modifier.height(1.dp))
//        OutlinedTextField(
//            value = sets,
//            onValueChange = { sets = it },
//            label = { Text("Sets", fontSize = 12.sp) },
//            placeholder = { Text("Enter number of sets", fontSize = 12.sp) },
//            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
//            modifier = Modifier.fillMaxWidth(),
//            shape = RoundedCornerShape(4.dp),
//            colors = OutlinedTextFieldDefaults.colors(
//                unfocusedBorderColor = LightBlue,
//                focusedBorderColor = DeepBlue
//            )
//        )
//        Spacer(modifier = Modifier.height(1.dp))
//        OutlinedTextField(
//            value = repsOrSecs,
//            onValueChange = { repsOrSecs = it },
//            label = { Text("Reps/Sec", fontSize = 12.sp) },
//            placeholder = { Text("Enter reps or seconds", fontSize = 12.sp) },
//            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
//            modifier = Modifier.fillMaxWidth(),
//            shape = RoundedCornerShape(4.dp),
//            colors = OutlinedTextFieldDefaults.colors(
//                unfocusedBorderColor = LightBlue,
//                focusedBorderColor = DeepBlue
//            )
//        )
//        Spacer(modifier = Modifier.height(1.dp))
//        OutlinedTextField(
//            value = restTime,
//            onValueChange = { restTime = it },
//            label = { Text("Rest Time", fontSize = 12.sp) },
//            placeholder = { Text("Enter rest time in seconds", fontSize = 12.sp) },
//            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
//            modifier = Modifier.fillMaxWidth(),
//            shape = RoundedCornerShape(4.dp),
//            colors = OutlinedTextFieldDefaults.colors(
//                unfocusedBorderColor = LightBlue,
//                focusedBorderColor = DeepBlue
//            )
//        )
//        Spacer(modifier = Modifier.height(2.dp))
//        Button(
//            onClick = {
//                val workout = Workout(
//                    id = 0,
//                    eventTitle = eventTitle,
//                    traineeId = traineeId.toIntOrNull() ?: 0,
//                    sets = sets.toIntOrNull() ?: 0,
//                    repsOrSecs = repsOrSecs.toIntOrNull() ?: 0,
//                    restTime = restTime.toIntOrNull() ?: 0,
//                    imageUri = imageUri?.toString()
//                )
//                onWorkoutCreated(workout)
//                // Reset form
//                eventTitle = ""
//                traineeId = ""
//                sets = ""
//                repsOrSecs = ""
//                restTime = ""
//                imageUri = null
//            },
//            enabled = eventTitle.isNotBlank() && traineeId.isNotBlank() &&
//                    sets.isNotBlank() && repsOrSecs.isNotBlank() && restTime.isNotBlank(),
//            modifier = Modifier
//                .fillMaxWidth()
//                .height(40.dp),
//            colors = ButtonDefaults.buttonColors(
//                containerColor = DeepBlue,
//                contentColor = Color.White
//            ),
//            shape = RoundedCornerShape(4.dp)
//        ) {
//            Text(
//                text = "Create",
//                fontSize = 14.sp,
//                maxLines = 1
//            )
//        }
//    }
//}
//
//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun EditWorkoutDialog(
//    workout: Workout?,
//    onDismissRequest: () -> Unit,
//    onConfirm: (Workout) -> Unit
//) {
//    Dialog(
//        onDismissRequest = onDismissRequest,
//        properties = DialogProperties(usePlatformDefaultWidth = false)
//    ) {
//        Surface(
//            modifier = Modifier
//                .fillMaxSize()
//                .background(Color.White),
//            shape = RoundedCornerShape(0.dp),
//            color = Color.White
//        ) {
//            Column(
//                modifier = Modifier
//                    .fillMaxSize()
//                    .padding(16.dp)
//            ) {
//                Row(
//                    modifier = Modifier
//                        .fillMaxWidth()
//                        .padding(bottom = 16.dp),
//                    horizontalArrangement = Arrangement.SpaceBetween,
//                    verticalAlignment = Alignment.CenterVertically
//                ) {
//                    Text(
//                        text = "Edit Workout",
//                        style = MaterialTheme.typography.titleLarge,
//                        color = DeepBlue
//                    )
//                    IconButton(onClick = onDismissRequest) {
//                        Icon(
//                            imageVector = Icons.Default.Close,
//                            contentDescription = "Close",
//                            tint = Color.Black
//                        )
//                    }
//                }
//
//                var eventTitle by remember { mutableStateOf(workout?.eventTitle ?: "") }
//                var traineeId by remember { mutableStateOf(workout?.traineeId?.toString() ?: "") }
//                var sets by remember { mutableStateOf(workout?.sets?.toString() ?: "") }
//                var repsOrSecs by remember { mutableStateOf(workout?.repsOrSecs?.toString() ?: "") }
//                var restTime by remember { mutableStateOf(workout?.restTime?.toString() ?: "") }
//                var imageUri by remember { mutableStateOf<Uri?>(workout?.imageUri?.let { Uri.parse(it) }) }
//
//                val context = LocalContext.current
//                val imagePickerUtil = remember { com.example.gymmanagement.utils.ImagePicker(context) }
//                val imagePicker = rememberImagePicker { uri ->
//                    val savedPath = imagePickerUtil.saveImageToInternalStorage(uri)
//                    if (savedPath != null) imageUri = Uri.parse(savedPath)
//                }
//
//                Box(
//                    modifier = Modifier
//                        .fillMaxWidth()
//                        .height(180.dp)
//                        .background(Color(0xFF9DB7F5), shape = RoundedCornerShape(16.dp))
//                        .clickable { imagePicker.launch("image/*") },
//                    contentAlignment = Alignment.Center
//                ) {
//                    if (imageUri != null) {
//                        AsyncImage(
//                            model = imageUri,
//                            contentDescription = null,
//                            modifier = Modifier
//                                .fillMaxSize()
//                                .clip(RoundedCornerShape(16.dp)),
//                            contentScale = ContentScale.Crop
//                        )
//                    } else {
//                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
//                            Icon(
//                                imageVector = Icons.Filled.Image,
//                                contentDescription = "Add Image",
//                                tint = Color(0xFF1A18C6),
//                                modifier = Modifier.size(48.dp)
//                            )
//                            Spacer(modifier = Modifier.height(8.dp))
//                            Text(
//                                text = "Tap to add an image",
//                                color = Color(0xFF444444),
//                                fontSize = 18.sp
//                            )
//                        }
//                    }
//                }
//
//                Spacer(modifier = Modifier.height(16.dp))
//
//                OutlinedTextField(
//                    value = eventTitle,
//                    onValueChange = { eventTitle = it },
//                    label = { Text("Workout title", fontSize = 12.sp) },
//                    modifier = Modifier.fillMaxWidth(),
//                    shape = RoundedCornerShape(4.dp),
//                    colors = OutlinedTextFieldDefaults.colors(
//                        unfocusedBorderColor = LightBlue,
//                        focusedBorderColor = DeepBlue
//                    )
//                )
//
//                Spacer(modifier = Modifier.height(8.dp))
//
//                OutlinedTextField(
//                    value = traineeId,
//                    onValueChange = { traineeId = it },
//                    label = { Text("Trainee ID", fontSize = 12.sp) },
//                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
//                    modifier = Modifier.fillMaxWidth(),
//                    shape = RoundedCornerShape(4.dp),
//                    colors = OutlinedTextFieldDefaults.colors(
//                        unfocusedBorderColor = LightBlue,
//                        focusedBorderColor = DeepBlue
//                    )
//                )
//
//                Spacer(modifier = Modifier.height(8.dp))
//
//                OutlinedTextField(
//                    value = sets,
//                    onValueChange = { sets = it },
//                    label = { Text("Sets", fontSize = 12.sp) },
//                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
//                    modifier = Modifier.fillMaxWidth(),
//                    shape = RoundedCornerShape(4.dp),
//                    colors = OutlinedTextFieldDefaults.colors(
//                        unfocusedBorderColor = LightBlue,
//                        focusedBorderColor = DeepBlue
//                    )
//                )
//
//                Spacer(modifier = Modifier.height(8.dp))
//
//                OutlinedTextField(
//                    value = repsOrSecs,
//                    onValueChange = { repsOrSecs = it },
//                    label = { Text("Reps/Sec", fontSize = 12.sp) },
//                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
//                    modifier = Modifier.fillMaxWidth(),
//                    shape = RoundedCornerShape(4.dp),
//                    colors = OutlinedTextFieldDefaults.colors(
//                        unfocusedBorderColor = LightBlue,
//                        focusedBorderColor = DeepBlue
//                    )
//                )
//
//                Spacer(modifier = Modifier.height(8.dp))
//
//                OutlinedTextField(
//                    value = restTime,
//                    onValueChange = { restTime = it },
//                    label = { Text("Rest Time", fontSize = 12.sp) },
//                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
//                    modifier = Modifier.fillMaxWidth(),
//                    shape = RoundedCornerShape(4.dp),
//                    colors = OutlinedTextFieldDefaults.colors(
//                        unfocusedBorderColor = LightBlue,
//                        focusedBorderColor = DeepBlue
//                    )
//                )
//
//                Spacer(modifier = Modifier.height(16.dp))
//
//                Row(
//                    modifier = Modifier.fillMaxWidth(),
//                    horizontalArrangement = Arrangement.SpaceBetween
//                ) {
//                    OutlinedButton(
//                        onClick = onDismissRequest,
//                        modifier = Modifier
//                            .weight(1f)
//                            .height(40.dp),
//                        shape = RoundedCornerShape(4.dp),
//                        colors = ButtonDefaults.outlinedButtonColors(
//                            contentColor = Color.Black
//                        )
//                    ) {
//                        Text("Cancel", fontSize = 12.sp)
//                    }
//
//                    Spacer(modifier = Modifier.width(8.dp))
//
//                    Button(
//                        onClick = {
//                            workout?.id?.let { id ->
//                                onConfirm(
//                                    Workout(
//                                        id = id,
//                                        eventTitle = "DELETE_WORKOUT",
//                                        traineeId = 0,
//                                        sets = 0,
//                                        repsOrSecs = 0,
//                                        restTime = 0,
//                                        imageUri = ""
//                                    )
//                                )
//                            }
//                        },
//                        modifier = Modifier
//                            .weight(1f)
//                            .height(40.dp),
//                        colors = ButtonDefaults.buttonColors(
//                            containerColor = Color.Red,
//                            contentColor = Color.White
//                        ),
//                        shape = RoundedCornerShape(4.dp)
//                    ) {
//                        Text("Delete", fontSize = 12.sp)
//                    }
//
//                    Spacer(modifier = Modifier.width(8.dp))
//
//                    Button(
//                        onClick = {
//                            workout?.id?.let { id ->
//                                onConfirm(
//                                    Workout(
//                                        id = id,
//                                        eventTitle = eventTitle,
//                                        traineeId = traineeId.toIntOrNull() ?: 0,
//                                        sets = sets.toIntOrNull() ?: 0,
//                                        repsOrSecs = repsOrSecs.toIntOrNull() ?: 0,
//                                        restTime = restTime.toIntOrNull() ?: 0,
//                                        imageUri = imageUri?.toString()
//                                    )
//                                )
//                            }
//                        },
//                        modifier = Modifier
//                            .weight(1f)
//                            .height(40.dp),
//                        colors = ButtonDefaults.buttonColors(
//                            containerColor = DeepBlue,
//                            contentColor = Color.White
//                        ),
//                        shape = RoundedCornerShape(4.dp)
//                    ) {
//                        Text("Update", fontSize = 12.sp)
//                    }
//                }
//            }
//        }
//    }
//}
//
//@Composable
//fun WorkoutCard(
//    workout: Workout,
//    onEditClick: (Workout) -> Unit
//) {
//    Card(
//        modifier = Modifier
//            .fillMaxWidth()
//            .height(170.dp)
//            .padding(vertical = 4.dp),
//        shape = RoundedCornerShape(12.dp)
//    ) {
//        Box(modifier = Modifier.fillMaxSize()) {
//            // Background Image or fallback color
//            if (!workout.imageUri.isNullOrEmpty()) {
//                AsyncImage(
//                    model = workout.imageUri,
//                    contentDescription = null,
//                    modifier = Modifier.matchParentSize(),
//                    contentScale = ContentScale.Crop
//                )
//            } else {
//                Box(
//                    modifier = Modifier
//                        .fillMaxSize()
//                        .background(Color.White)
//                )
//            }
//
//            // Top right: Edit icon in white rounded box
//            Surface(
//                modifier = Modifier
//                    .align(Alignment.TopEnd)
//                    .padding(8.dp),
//                color = Color.White.copy(alpha = 0.95f),
//                shape = RoundedCornerShape(10.dp),
//                shadowElevation = 2.dp
//            ) {
//                Row(
//                    verticalAlignment = Alignment.CenterVertically,
//                    modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp)
//                ) {
//                    IconButton(onClick = { onEditClick(workout) }, modifier = Modifier.size(24.dp)) {
//                        Icon(
//                            imageVector = Icons.Default.Edit,
//                            contentDescription = "Edit",
//                            tint = Color.Black,
//                            modifier = Modifier.size(18.dp)
//                        )
//                    }
//                }
//            }
//
//            // Top left: Number badge (show traineeId)
//            Surface(
//                modifier = Modifier
//                    .align(Alignment.TopStart)
//                    .padding(8.dp),
//                color = Color.White.copy(alpha = 0.95f),
//                shadowElevation = 2.dp
//            ) {
//                Text(
//                    text = workout.traineeId.takeIf { it > 0 }?.toString() ?: "-",
//                    color = Color.Black,
//                    fontWeight = FontWeight.Bold,
//                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
//                )
//            }
//
//            // Bottom: Info in a single white rounded box
//            Box(
//                modifier = Modifier
//                    .align(Alignment.BottomStart)
//                    .padding(12.dp)
//            ) {
//                Column(
//                    modifier = Modifier
//                        .widthIn(max = 320.dp)
//                ) {
//                    // Title row
//                    Surface(
//                        color = Color.White.copy(alpha = 0.95f),
//                        shape = RoundedCornerShape(12.dp),
//                        shadowElevation = 2.dp,
//                        modifier = Modifier.wrapContentWidth()
//                    ) {
//                        Text(
//                            text = workout.eventTitle,
//                            color = Color.Black,
//                            fontSize = 18.sp,
//                            fontWeight = FontWeight.Bold,
//                            maxLines = 1,
//                            overflow = TextOverflow.Ellipsis,
//                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp)
//                        )
//                    }
//                    Spacer(modifier = Modifier.height(2.dp))
//                    // Details row
//                    Surface(
//                        color = Color.White.copy(alpha = 0.95f),
//                        shape = RoundedCornerShape(12.dp),
//                        shadowElevation = 2.dp,
//                        modifier = Modifier.wrapContentWidth()
//                    ) {
//                        Text(
//                            text = "${workout.sets} sets ${workout.repsOrSecs} reps ${workout.restTime} sec",
//                            color = Color.Black,
//                            fontSize = 14.sp,
//                            maxLines = 1,
//                            overflow = TextOverflow.Ellipsis,
//                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp)
//                        )
//                    }
//                }
//            }
//        }
//    }
//}