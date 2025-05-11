package com.example.gymmanagement.ui.screens.admin.event

import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import coil.compose.AsyncImage
import com.example.gymmanagement.data.model.EventRequest
import com.example.gymmanagement.data.model.EventResponse
import com.example.gymmanagement.data.model.EventUpdateRequest
import com.example.gymmanagement.utils.rememberImagePicker
import com.example.gymmanagement.viewmodel.AdminEventViewModel
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import java.io.File
import android.util.Log
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

private val DeepBlue = Color(0xFF0000CD)
private val LightBlue = Color(0xFFE6E9FD)
private val Green = Color(0xFF4CAF50)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminEventScreen(
    viewModel: AdminEventViewModel,
    userId: Int
) {
    var showEditDialog by remember { mutableStateOf(false) }
    var selectedEvent by remember { mutableStateOf<EventResponse?>(null) }
    val events by viewModel.events.collectAsState(initial = emptyList())
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()
    val snackbarHostState = remember { SnackbarHostState() }
    val successMessage = viewModel.successMessage
    val validationError = viewModel.validationError

    LaunchedEffect(Unit) {
        viewModel.loadEvents()
    }

    LaunchedEffect(successMessage) {
        if (successMessage != null) {
            snackbarHostState.showSnackbar(successMessage)
            viewModel.setSuccessMessage(null)
        }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        // ... other scaffold params ...
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.White)
        ) {
            // Top Navigation Bar
            Surface(
                color = DeepBlue,
                shadowElevation = 4.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Events",
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }

            // Add Event clickable text
            Text(
                text = "Add Event",
                color = Color.Blue,
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                modifier = Modifier
                    .padding(top = 12.dp, bottom = 4.dp, start = 4.dp)
                    .clickable { /* Optionally scroll to form or focus */ }
            )

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 12.dp, vertical = 8.dp)
            ) {
                EventForm(
                    onEventCreated = { eventRequest ->
                        if (isEventFormValid(eventRequest.title, eventRequest.date, eventRequest.time, eventRequest.location)) {
                            viewModel.createEvent(eventRequest) { createdEvent ->
                                viewModel.addEventLocally(createdEvent)
                            }
                        } else {
                            viewModel.setValidationError("Please fill in all fields.")
                        }
                    },
                    userId = userId
                )

                Spacer(modifier = Modifier.height(1.dp))

                Text(
                    text = "Event List",
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.padding(bottom = 1.dp)
                )

                if (isLoading) {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator()
                    }
                } else if (error != null) {
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
                } else if (events.isEmpty()) {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "No events available",
                            style = MaterialTheme.typography.bodyLarge,
                            color = Color.Gray
                        )
                    }
                } else {
                    LazyColumn(
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        items(events) { event ->
                            EventCard(
                                event = event,
                                onEditClick = {
                                    selectedEvent = event
                                    showEditDialog = true
                                }
                            )
                        }
                    }
                }
            }
        }

        if (showEditDialog) {
            EditEventDialog(
                event = selectedEvent,
                onDismissRequest = { showEditDialog = false },
                onConfirm = { updatedEvent ->
                    selectedEvent?.id?.let { id ->
                        if (updatedEvent.title == "DELETE_EVENT") {
                            viewModel.deleteEvent(id)
                            viewModel.setSuccessMessage("Event deleted successfully!")
                        } else {
                            viewModel.updateEvent(id, updatedEvent)
                            viewModel.setSuccessMessage("Event updated successfully!")
                        }
                    }
                    showEditDialog = false
                }
            )
        }

        if (validationError != null) {
            AlertDialog(
                onDismissRequest = { viewModel.setValidationError(null) },
                title = { Text("Validation Error") },
                text = { Text(validationError) },
                confirmButton = { Button(onClick = { viewModel.setValidationError(null) }) { Text("OK") } }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventForm(
    onEventCreated: (EventRequest) -> Unit,
    userId: Int
) {
    var title by remember { mutableStateOf("") }
    var date by remember { mutableStateOf("") }
    var time by remember { mutableStateOf("") }
    var location by remember { mutableStateOf("") }
    var imageUri by remember { mutableStateOf<String?>(null) }

    val context = LocalContext.current
    val imagePickerUtil = remember { com.example.gymmanagement.utils.ImagePicker(context) }
    val imagePicker = rememberImagePicker { uri ->
        val savedPath = imagePickerUtil.saveImageToInternalStorage(uri)
        Log.d("EventForm", "Saved image path: $savedPath")
        if (savedPath != null) imageUri = savedPath
    }

    Column(modifier = Modifier.fillMaxWidth()) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp)
                .background(Color(0xFF9DB7F5), shape = RoundedCornerShape(16.dp))
                .clickable { imagePicker.launch("image/*") },
            contentAlignment = Alignment.Center
        ) {
            if (imageUri != null) {
                val imageModel = if (imageUri?.startsWith("/") == true) File(imageUri) else imageUri
                AsyncImage(
                    model = imageModel,
                    contentDescription = null,
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(16.dp)),
                    contentScale = ContentScale.Crop
                )
            } else {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        imageVector = Icons.Filled.Image,
                        contentDescription = "Add Image",
                        tint = Color(0xFF1A18C6),
                        modifier = Modifier.size(48.dp)
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "Tap to add an image",
                        color = Color(0xFF444444),
                        fontSize = 18.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(2.dp))
        OutlinedTextField(
            value = title,
            onValueChange = { title = it },
            label = { Text("Event title", fontSize = 12.sp) },
            placeholder = { Text("Enter title", fontSize = 12.sp) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(4.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = LightBlue,
                focusedBorderColor = DeepBlue
            )
        )
        Spacer(modifier = Modifier.height(1.dp))
        OutlinedTextField(
            value = date,
            onValueChange = { date = it },
            label = { Text("Date", fontSize = 12.sp) },
            placeholder = { Text("Enter date", fontSize = 12.sp) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(4.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = LightBlue,
                focusedBorderColor = DeepBlue
            )
        )
        Spacer(modifier = Modifier.height(1.dp))
        OutlinedTextField(
            value = time,
            onValueChange = { time = it },
            label = { Text("Time", fontSize = 12.sp) },
            placeholder = { Text("Enter time", fontSize = 12.sp) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(4.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = LightBlue,
                focusedBorderColor = DeepBlue
            )
        )
        Spacer(modifier = Modifier.height(1.dp))
        OutlinedTextField(
            value = location,
            onValueChange = { location = it },
            label = { Text("Location", fontSize = 12.sp) },
            placeholder = { Text("Enter location", fontSize = 12.sp) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(4.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = LightBlue,
                focusedBorderColor = DeepBlue
            )
        )
        Spacer(modifier = Modifier.height(8.dp))
        Button(
            onClick = {
                Log.d("EventForm", "Creating event with imageUri: $imageUri")
                if (title.isNotBlank() && date.isNotBlank() && time.isNotBlank() && location.isNotBlank()) {
                    onEventCreated(
                        EventRequest(
                            title = title,
                            date = date,
                            time = time,
                            location = location,
                            imageUri = imageUri,
                            createdBy = userId
                        )
                    )
                    // Clear form
                    title = ""
                    date = ""
                    time = ""
                    location = ""
                    imageUri = null
                }
            },
            enabled = title.isNotBlank() && date.isNotBlank() && time.isNotBlank() && location.isNotBlank(),
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = DeepBlue
            ),
            shape = RoundedCornerShape(6.dp)
        ) {
            Text("Create", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditEventDialog(
    event: EventResponse?,
    onDismissRequest: () -> Unit,
    onConfirm: (EventUpdateRequest) -> Unit
) {
    Dialog(
        onDismissRequest = onDismissRequest,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Surface(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.White),
            shape = RoundedCornerShape(0.dp),
            color = Color.White
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Edit Event",
                        style = MaterialTheme.typography.titleLarge,
                        color = DeepBlue
                    )
                    IconButton(onClick = onDismissRequest) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Close",
                            tint = Color.Black
                        )
                    }
                }

                var title by remember { mutableStateOf(event?.title ?: "") }
                var date by remember { mutableStateOf(event?.date ?: "") }
                var time by remember { mutableStateOf(event?.time ?: "") }
                var location by remember { mutableStateOf(event?.location ?: "") }
                var imageUri by remember { mutableStateOf<String?>(event?.imageUri) }

                val context = LocalContext.current
                val imagePickerUtil = remember { com.example.gymmanagement.utils.ImagePicker(context) }
                val imagePicker = rememberImagePicker { uri ->
                    val savedPath = imagePickerUtil.saveImageToInternalStorage(uri)
                    if (savedPath != null) imageUri = savedPath
                }

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp)
                        .background(Color(0xFF9DB7F5), shape = RoundedCornerShape(16.dp))
                        .clickable { imagePicker.launch("image/*") },
                    contentAlignment = Alignment.Center
                ) {
                    if (imageUri != null) {
                        val imageModel = if (imageUri?.startsWith("/") == true) File(imageUri) else imageUri
                        AsyncImage(
                            model = imageModel,
                            contentDescription = null,
                            modifier = Modifier
                                .fillMaxSize()
                                .clip(RoundedCornerShape(16.dp)),
                            contentScale = ContentScale.Crop
                        )
                    } else {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(
                                imageVector = Icons.Filled.Image,
                                contentDescription = "Add Image",
                                tint = Color(0xFF1A18C6),
                                modifier = Modifier.size(48.dp)
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "Tap to add an image",
                                color = Color(0xFF444444),
                                fontSize = 18.sp
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text("Event title", fontSize = 12.sp) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(4.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        unfocusedBorderColor = LightBlue,
                        focusedBorderColor = DeepBlue
                    )
                )

                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = date,
                    onValueChange = { date = it },
                    label = { Text("Date", fontSize = 12.sp) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(4.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        unfocusedBorderColor = LightBlue,
                        focusedBorderColor = DeepBlue
                    )
                )

                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = time,
                    onValueChange = { time = it },
                    label = { Text("Time", fontSize = 12.sp) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(4.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        unfocusedBorderColor = LightBlue,
                        focusedBorderColor = DeepBlue
                    )
                )

                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = location,
                    onValueChange = { location = it },
                    label = { Text("Location", fontSize = 12.sp) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(4.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        unfocusedBorderColor = LightBlue,
                        focusedBorderColor = DeepBlue
                    )
                )

                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    OutlinedButton(
                        onClick = onDismissRequest,
                        modifier = Modifier
                            .weight(1f)
                            .height(40.dp),
                        shape = RoundedCornerShape(4.dp),
                        colors = ButtonDefaults.outlinedButtonColors(
                            contentColor = Color.Black
                        )
                    ) {
                        Text("Cancel", fontSize = 12.sp)
                    }

                    Spacer(modifier = Modifier.width(8.dp))

                    Button(
                        onClick = {
                            onConfirm(EventUpdateRequest(title = "DELETE_EVENT"))
                        },
                        modifier = Modifier
                            .weight(1f)
                            .height(40.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color.Red,
                            contentColor = Color.White
                        ),
                        shape = RoundedCornerShape(4.dp)
                    ) {
                        Text("Delete", fontSize = 12.sp)
                    }

                    Spacer(modifier = Modifier.width(8.dp))

                    Button(
                        onClick = {
                            val imageToUse = imageUri ?: event?.imageUri
                            val updateRequest = EventUpdateRequest(
                                title = if (title != event?.title) title else null,
                                date = if (date != event?.date) date else null,
                                time = if (time != event?.time) time else null,
                                location = if (location != event?.location) location else null,
                                imageUri = imageToUse
                            )
                            onConfirm(updateRequest)
                        },
                        modifier = Modifier
                            .weight(1f)
                            .height(40.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = DeepBlue,
                            contentColor = Color.White
                        ),
                        shape = RoundedCornerShape(4.dp)
                    ) {
                        Text("Update", fontSize = 12.sp)
                    }
                }
            }
        }
    }
}

@Composable
fun EventCard(
    event: EventResponse,
    onEditClick: (EventResponse) -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(180.dp)
            .padding(vertical = 8.dp),
        shape = RoundedCornerShape(18.dp),
        elevation = CardDefaults.cardElevation(4.dp)
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            // Background image
            if (!event.imageUri.isNullOrEmpty()) {
                AsyncImage(
                    model = event.imageUri,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.matchParentSize()
                )
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.LightGray)
                )
            }

            // Title pill at top left
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
                        text = event.title,
                        color = Color.Black,
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp,
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp)
                    )
                }
            }

            // Edit icon at top right
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(12.dp)
            ) {
                Surface(
                    color = Color.White,
                    shape = RoundedCornerShape(50),
                    shadowElevation = 4.dp
                ) {
                    IconButton(onClick = { onEditClick(event) }, modifier = Modifier.size(32.dp)) {
                        Icon(
                            imageVector = Icons.Default.Edit,
                            contentDescription = "Edit",
                            tint = Color.Black,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }

            // Add a gap between the title and the detail pills
            Spacer(modifier = Modifier.height(20.dp))

            // Event details (date, time, location) at bottom left
            Column(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Surface(
                    color = Color.White.copy(alpha = 0.95f),
                    shape = RoundedCornerShape(12.dp),
                    shadowElevation = 2.dp,
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.DateRange,
                            contentDescription = null,
                            tint = Color.Black,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = event.date,
                            color = Color.Black,
                            fontSize = 14.sp,
                            modifier = Modifier.padding(end = 8.dp, top = 4.dp, bottom = 4.dp)
                        )
                    }
                }
                Surface(
                    color = Color.White.copy(alpha = 0.95f),
                    shape = RoundedCornerShape(12.dp),
                    shadowElevation = 2.dp,
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.AccessTime,
                            contentDescription = null,
                            tint = Color.Black,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = event.time,
                            color = Color.Black,
                            fontSize = 14.sp,
                            modifier = Modifier.padding(end = 8.dp, top = 4.dp, bottom = 4.dp)
                        )
                    }
                }
                Surface(
                    color = Color.White.copy(alpha = 0.95f),
                    shape = RoundedCornerShape(12.dp),
                    shadowElevation = 2.dp,
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.LocationOn,
                            contentDescription = null,
                            tint = Color.Black,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = event.location,
                            color = Color.Black,
                            fontSize = 14.sp,
                            modifier = Modifier.padding(end = 8.dp, top = 4.dp, bottom = 4.dp)
                        )
                    }
                }
            }
        }
    }
}

fun isEventFormValid(
    title: String?,
    date: String?,
    time: String?,
    location: String?
): Boolean {
    return !title.isNullOrBlank() && !date.isNullOrBlank() && !time.isNullOrBlank() && !location.isNullOrBlank()
}
