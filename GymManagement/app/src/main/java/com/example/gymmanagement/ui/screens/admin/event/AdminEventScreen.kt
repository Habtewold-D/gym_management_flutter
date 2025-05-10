//package com.example.gymmanagement.ui.screens.admin.event
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
//import androidx.compose.ui.graphics.Color
//import androidx.compose.ui.layout.ContentScale
//import androidx.compose.ui.text.font.FontWeight
//import androidx.compose.ui.text.style.TextOverflow
//import androidx.compose.ui.unit.dp
//import androidx.compose.ui.unit.sp
//import androidx.compose.ui.window.Dialog
//import androidx.compose.ui.window.DialogProperties
//import coil.compose.AsyncImage
//import com.example.gymmanagement.data.model.EventEntity
//import com.example.gymmanagement.utils.rememberImagePicker
//import com.example.gymmanagement.viewmodel.AdminEventViewModel
//import androidx.compose.ui.tooling.preview.Preview
//import com.example.gymmanagement.ui.theme.GymManagementAppTheme
//import kotlinx.coroutines.flow.Flow
//import kotlinx.coroutines.flow.flowOf
//import androidx.compose.ui.platform.LocalContext
//import androidx.compose.ui.draw.clip
//
//private val DeepBlue = Color(0xFF0000CD)
//private val LightBlue = Color(0xFFE6E9FD)
//private val Green = Color(0xFF4CAF50)
//
//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun AdminEventScreen(
//    viewModel: AdminEventViewModel
//) {
//    var showEditDialog by remember { mutableStateOf(false) }
//    var selectedEvent by remember { mutableStateOf<EventEntity?>(null) }
//    val events by viewModel.events.collectAsState(initial = emptyList())
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
//                    text = "Events",
//                    fontSize = 24.sp,
//                    fontWeight = FontWeight.Bold,
//                    color = Color.White // White text
//                )
//            }
//        }
//
//        Column(
//            modifier = Modifier
//                .fillMaxSize()
//                .padding(16.dp)
//        ) {
//            Text(
//                text = "Add Event",
//                style = MaterialTheme.typography.titleMedium.copy(color = Color.Blue),
//                modifier = Modifier.padding(bottom = 4.dp)
//            )
//
//            EventForm(
//                onEventCreated = { event ->
//                    viewModel.addEvent(event)
//                }
//            )
//
//            Spacer(modifier = Modifier.height(16.dp))
//
//            Text(
//                text = "Upcoming Events",
//                style = MaterialTheme.typography.titleMedium,
//                modifier = Modifier.padding(bottom = 4.dp)
//            )
//
//            LazyColumn(
//                verticalArrangement = Arrangement.spacedBy(8.dp)
//            ) {
//                items(events) { event ->
//                    EventCard(
//                        event = event,
//                        onEditClick = {
//                            selectedEvent = event
//                            showEditDialog = true
//                        }
//                    )
//                }
//            }
//        }
//    }
//
//    if (showEditDialog) {
//        EditEventDialog(
//            event = selectedEvent,
//            onDismissRequest = { showEditDialog = false },
//            onConfirm = { updatedEvent ->
//                if (updatedEvent.title == "DELETE_EVENT") {
//                    selectedEvent?.let { viewModel.deleteEvent(it) }
//                } else {
//                    viewModel.updateEvent(updatedEvent)
//                }
//                showEditDialog = false
//            }
//        )
//    }
//}
//
//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun EventForm(
//    onEventCreated: (EventEntity) -> Unit
//) {
//    var eventTitle by remember { mutableStateOf("") }
//    var date by remember { mutableStateOf("") }
//    var time by remember { mutableStateOf("") }
//    var location by remember { mutableStateOf("") }
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
//        Spacer(modifier = Modifier.height(6.dp))
//        OutlinedTextField(
//            value = eventTitle,
//            onValueChange = { eventTitle = it },
//            label = { Text("Event title", fontSize = 12.sp) },
//            placeholder = { Text("Enter title", fontSize = 12.sp) },
//            modifier = Modifier.fillMaxWidth(),
//            shape = RoundedCornerShape(4.dp),
//            colors = OutlinedTextFieldDefaults.colors(
//                unfocusedBorderColor = LightBlue,
//                focusedBorderColor = DeepBlue
//            )
//        )
//        Spacer(modifier = Modifier.height(3.dp))
//        OutlinedTextField(
//            value = date,
//            onValueChange = { date = it },
//            label = { Text("Date", fontSize = 12.sp) },
//            placeholder = { Text("Enter date", fontSize = 12.sp) },
//            modifier = Modifier.fillMaxWidth(),
//            shape = RoundedCornerShape(4.dp),
//            colors = OutlinedTextFieldDefaults.colors(
//                unfocusedBorderColor = LightBlue,
//                focusedBorderColor = DeepBlue
//            )
//        )
//        Spacer(modifier = Modifier.height(3.dp))
//        OutlinedTextField(
//            value = time,
//            onValueChange = { time = it },
//            label = { Text("Time", fontSize = 12.sp) },
//            placeholder = { Text("Enter time", fontSize = 12.sp) },
//            modifier = Modifier.fillMaxWidth(),
//            shape = RoundedCornerShape(4.dp),
//            colors = OutlinedTextFieldDefaults.colors(
//                unfocusedBorderColor = LightBlue,
//                focusedBorderColor = DeepBlue
//            )
//        )
//        Spacer(modifier = Modifier.height(3.dp))
//        OutlinedTextField(
//            value = location,
//            onValueChange = { location = it },
//            label = { Text("Event location", fontSize = 12.sp) },
//            placeholder = { Text("Enter Location", fontSize = 12.sp) },
//            modifier = Modifier.fillMaxWidth(),
//            shape = RoundedCornerShape(4.dp),
//            colors = OutlinedTextFieldDefaults.colors(
//                unfocusedBorderColor = LightBlue,
//                focusedBorderColor = DeepBlue
//            )
//        )
//        Spacer(modifier = Modifier.height(8.dp))
//        Button(
//            onClick = {
//                val event = EventEntity(
//                    title = eventTitle,
//                    date = date,
//                    time = time,
//                    location = location,
//                    imageUri = imageUri?.toString()
//                )
//                onEventCreated(event)
//                // Reset form
//                eventTitle = ""
//                date = ""
//                time = ""
//                location = ""
//                imageUri = null
//            },
//            enabled = eventTitle.isNotBlank() && date.isNotBlank() &&
//                    time.isNotBlank() && location.isNotBlank(),
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
//fun EditEventDialog(
//    event: EventEntity?,
//    onDismissRequest: () -> Unit,
//    onConfirm: (EventEntity) -> Unit
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
//                        text = "Edit Event",
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
//                var eventTitle by remember { mutableStateOf(event?.title ?: "") }
//                var date by remember { mutableStateOf(event?.date ?: "") }
//                var time by remember { mutableStateOf(event?.time ?: "") }
//                var location by remember { mutableStateOf(event?.location ?: "") }
//                var imageUri by remember { mutableStateOf<Uri?>(event?.imageUri?.let { Uri.parse(it) }) }
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
//                    label = { Text("Event title", fontSize = 12.sp) },
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
//                    value = date,
//                    onValueChange = { date = it },
//                    label = { Text("Date", fontSize = 12.sp) },
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
//                    value = time,
//                    onValueChange = { time = it },
//                    label = { Text("Time", fontSize = 12.sp) },
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
//                    value = location,
//                    onValueChange = { location = it },
//                    label = { Text("Event location", fontSize = 12.sp) },
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
//                            event?.id?.let { id ->
//                                onConfirm(
//                                    EventEntity(
//                                        id = id,
//                                        title = "DELETE_EVENT",
//                                        date = "",
//                                        time = "",
//                                        location = "",
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
//                            event?.id?.let { id ->
//                                onConfirm(
//                                    EventEntity(
//                                        id = id,
//                                        title = eventTitle,
//                                        date = date,
//                                        time = time,
//                                        location = location,
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
//fun EventCard(
//    event: EventEntity,
//    onEditClick: (EventEntity) -> Unit
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
//            if (!event.imageUri.isNullOrEmpty()) {
//                AsyncImage(
//                    model = event.imageUri,
//                    contentDescription = null,
//                    modifier = Modifier.matchParentSize(),
//                    contentScale = ContentScale.Crop
//                )
//            } else {
//                Box(
//                    modifier = Modifier
//                        .fillMaxSize()
//                        .background(Color.White) // fallback color if no image
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
//                    IconButton(onClick = { onEditClick(event) }, modifier = Modifier.size(24.dp)) {
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
//                            text = event.title,
//                            color = Color.Black,
//                            fontSize = 18.sp,
//                            fontWeight = FontWeight.Bold,
//                            maxLines = 1,
//                            overflow = TextOverflow.Ellipsis,
//                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp)
//                        )
//                    }
//                    Spacer(modifier = Modifier.height(2.dp))
//                    // Date row
//                    Surface(
//                        color = Color.White.copy(alpha = 0.95f),
//                        shape = RoundedCornerShape(12.dp),
//                        shadowElevation = 2.dp,
//                        modifier = Modifier.wrapContentWidth()
//                    ) {
//                        Row(
//                            verticalAlignment = Alignment.CenterVertically,
//                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
//                        ) {
//                            Icon(
//                                imageVector = Icons.Default.DateRange,
//                                contentDescription = null,
//                                tint = Color.Black,
//                                modifier = Modifier.size(14.dp)
//                            )
//                            Spacer(modifier = Modifier.width(4.dp))
//                            Text(
//                                text = event.date,
//                                color = Color.Black,
//                                fontSize = 12.sp,
//                                maxLines = 1,
//                                overflow = TextOverflow.Ellipsis
//                            )
//                        }
//                    }
//                    Spacer(modifier = Modifier.height(2.dp))
//                    // Time row
//                    Surface(
//                        color = Color.White.copy(alpha = 0.95f),
//                        shape = RoundedCornerShape(12.dp),
//                        shadowElevation = 2.dp,
//                        modifier = Modifier.wrapContentWidth()
//                    ) {
//                        Row(
//                            verticalAlignment = Alignment.CenterVertically,
//                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
//                        ) {
//                            Icon(
//                                imageVector = Icons.Default.AccessTime,
//                                contentDescription = null,
//                                tint = Color.Black,
//                                modifier = Modifier.size(14.dp)
//                            )
//                            Spacer(modifier = Modifier.width(4.dp))
//                            Text(
//                                text = event.time,
//                                color = Color.Black,
//                                fontSize = 12.sp,
//                                maxLines = 1,
//                                overflow = TextOverflow.Ellipsis
//                            )
//                        }
//                    }
//                    Spacer(modifier = Modifier.height(2.dp))
//                    // Location row (taller)
//                    Surface(
//                        color = Color.White.copy(alpha = 0.95f),
//                        shape = RoundedCornerShape(12.dp),
//                        shadowElevation = 2.dp,
//                        modifier = Modifier.wrapContentWidth()
//                    ) {
//                        Row(
//                            verticalAlignment = Alignment.CenterVertically,
//                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 10.dp) // extra vertical padding
//                        ) {
//                            Icon(
//                                imageVector = Icons.Default.LocationOn,
//                                contentDescription = null,
//                                tint = Color.Black,
//                                modifier = Modifier.size(14.dp)
//                            )
//                            Spacer(modifier = Modifier.width(4.dp))
//                            Text(
//                                text = event.location,
//                                color = Color.Black,
//                                fontSize = 12.sp,
//                                maxLines = 1,
//                                overflow = TextOverflow.Ellipsis,
//                                modifier = Modifier.offset(y = (-5).dp)
//                            )
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
