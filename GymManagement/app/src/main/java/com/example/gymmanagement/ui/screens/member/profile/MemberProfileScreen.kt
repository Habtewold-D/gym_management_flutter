package com.example.gymmanagement.ui.screens.member.profile

import android.util.Log
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.gymmanagement.data.model.UserProfile
import com.example.gymmanagement.viewmodel.MemberProfileViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MemberProfileScreen(
    userEmail: String,
    viewModel: MemberProfileViewModel,
    onLogout: () -> Unit = {}
) {
    var isEditing by remember { mutableStateOf(false) }
    val userProfile by viewModel.userProfile.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()

    LaunchedEffect(userEmail) {
        viewModel.getUserProfileByEmail(userEmail)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
    ) {
        // Top Bar
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color(0xFF1A18C6))
                .padding(vertical = 24.dp, horizontal = 16.dp)
        ) {
            Text(
                text = "Your profile",
                color = Color.White,
                fontSize = 28.sp,
                modifier = Modifier.align(Alignment.CenterStart)
            )
            IconButton(
                onClick = onLogout,
                modifier = Modifier.align(Alignment.CenterEnd)
            ) {
                Icon(
                    imageVector = Icons.Default.ExitToApp,
                    contentDescription = "Logout",
                    tint = Color.White
                )
            }
        }

        when {
            isLoading -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }
            error != null -> {
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
            else -> {
                Spacer(modifier = Modifier.height(24.dp))

                // Only show the icon when not editing
                if (!isEditing) {
                    Box(
                        modifier = Modifier.fillMaxWidth(),
                        contentAlignment = Alignment.Center
                    ) {
                        Box(
                            modifier = Modifier
                                .size(150.dp)
                                .clip(CircleShape)
                                .border(8.dp, Color(0xFF1A18C6), CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Person,
                                contentDescription = "Profile",
                                tint = Color(0xFF1A18C6),
                                modifier = Modifier.size(100.dp)
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(24.dp))
                }

                userProfile?.let { profile ->
                    if (!isEditing) {
                        DisplayProfile(
                            profile = profile,
                            onEditClick = { 
                                Log.d("MemberProfileScreen", "Edit button clicked")
                                isEditing = true 
                            }
                        )
                    } else {
                        EditProfile(
                            profile = profile,
                            onSave = { updatedProfile ->
                                Log.d("MemberProfileScreen", "Save button clicked with profile: $updatedProfile")
                                viewModel.updateUserProfileWithBMI(
                                    email = updatedProfile.email,
                                    name = updatedProfile.name,
                                    age = updatedProfile.age,
                                    height = updatedProfile.height,
                                    weight = updatedProfile.weight,
                                    role = updatedProfile.role
                                )
                                isEditing = false
                            },
                            onCancel = { 
                                Log.d("MemberProfileScreen", "Cancel button clicked")
                                isEditing = false 
                            }
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun DisplayProfile(
    profile: UserProfile,
    onEditClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(8.dp, RoundedCornerShape(16.dp)),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFFF8F9FB))
        ) {
            Column(
                modifier = Modifier.padding(20.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Personal information",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = Color.Black
                    )
                    IconButton(
                        onClick = {
                            Log.d("MemberProfileScreen", "Edit button clicked for profile: $profile")
                            onEditClick()
                        }
                    ) {
                        Icon(
                            imageVector = Icons.Default.Edit,
                            contentDescription = "Edit",
                            tint = Color.Black
                        )
                    }
                }
                Spacer(modifier = Modifier.height(8.dp))
                ProfileField("Name:", profile.name)
                ProfileField("Email:", profile.email)
                profile.age?.let { ProfileField("Age:", "$it years") }
                profile.height?.let { ProfileField("Height:", "${it.toInt()}cm") }
                profile.weight?.let { ProfileField("Weight:", "${it.toInt()} kg") }
                profile.bmi?.let { ProfileField("BMI :", String.format("%.2f", it)) }
                profile.joinDate?.let { ProfileField("Join Date:", it) }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfile(
    profile: UserProfile,
    onSave: (UserProfile) -> Unit,
    onCancel: () -> Unit
) {
    var name by remember { mutableStateOf(profile.name) }
    var age by remember { mutableStateOf(profile.age?.toString() ?: "") }
    var height by remember { mutableStateOf(profile.height?.toString() ?: "") }
    var weight by remember { mutableStateOf(profile.weight?.toString() ?: "") }
    var showError by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    Log.d("MemberProfileScreen", "EditProfile composable created with profile: $profile")

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(8.dp, RoundedCornerShape(16.dp)),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFFF8F9FB))
        ) {
            Column(
                modifier = Modifier.padding(24.dp)
            ) {
                Text(
                    text = "Personal information",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.Black,
                    modifier = Modifier.padding(bottom = 16.dp)
                )

                // Name (required)
                Text("Name", fontWeight = FontWeight.Medium, color = Color.Black)
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    shape = RoundedCornerShape(8.dp),
                    singleLine = true,
                    isError = showError && name.isBlank()
                )

                // Age
                Text("Age:", fontWeight = FontWeight.Medium, color = Color.Black)
                OutlinedTextField(
                    value = age,
                    onValueChange = { age = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    shape = RoundedCornerShape(8.dp),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    isError = showError && age.isBlank()
                )

                // Height
                Text("Height(cm):", fontWeight = FontWeight.Medium, color = Color.Black)
                OutlinedTextField(
                    value = height,
                    onValueChange = { height = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    shape = RoundedCornerShape(8.dp),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    isError = showError && height.isBlank()
                )

                // Weight
                Text("Weight(kg):", fontWeight = FontWeight.Medium, color = Color.Black)
                OutlinedTextField(
                    value = weight,
                    onValueChange = { weight = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    shape = RoundedCornerShape(8.dp),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    isError = showError && weight.isBlank()
                )

                if (showError && errorMessage != null) {
                    Text(
                        text = errorMessage!!,
                        color = Color.Red,
                        modifier = Modifier.padding(top = 8.dp)
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    OutlinedButton(
                        onClick = onCancel,
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp)
                            .padding(end = 8.dp),
                        shape = RoundedCornerShape(8.dp),
                        border = ButtonDefaults.outlinedButtonBorder
                    ) {
                        Text("Cancel", color = Color.Black)
                    }
                    Button(
                        onClick = {
                            if (name.isBlank()) {
                                showError = true
                                errorMessage = "Name is required"
                                return@Button
                            }

                            val ageInt = age.toIntOrNull()
                            val heightFloat = height.toFloatOrNull()
                            val weightFloat = weight.toFloatOrNull()

                            if (age.isBlank() || height.isBlank() || weight.isBlank()) {
                                showError = true
                                errorMessage = "Please fill in all fields"
                                return@Button
                            }

                            if (ageInt == null || heightFloat == null || weightFloat == null) {
                                showError = true
                                errorMessage = "Please enter valid numbers"
                                return@Button
                            }

                            // Defensive copy for membershipStatus
                            val updatedProfile = profile.copy(
                                name = name,
                                age = ageInt,
                                height = heightFloat,
                                weight = weightFloat,
                                id = profile.id,
                                email = profile.email,
                                role = profile.role,
                                joinDate = profile.joinDate,
                                membershipStatus = profile.membershipStatus ?: "active" // <-- Defensive copy here!
                            )
                            onSave(updatedProfile)
                        },
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp)
                            .padding(start = 8.dp),
                        shape = RoundedCornerShape(8.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFF1A18C6),
                            contentColor = Color.White
                        )
                    ) {
                        Text("Save")
                    }
                }
            }
        }
    }
}

@Composable
fun ProfileField(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 2.dp),
        horizontalArrangement = Arrangement.Start
    ) {
        Text(
            text = label,
            fontWeight = FontWeight.Bold,
            color = Color.Black,
            fontSize = 16.sp,
            modifier = Modifier.width(100.dp)
        )
        Text(
            text = value,
            color = Color.Gray,
            fontSize = 16.sp,
            modifier = Modifier.padding(start = 8.dp)
        )
    }
}

private fun calculateBMI(height: Float?, weight: Float?): Float? {
    if (height == null || weight == null || height <= 0) return null
    val heightInMeters = height / 100
    return weight / (heightInMeters * heightInMeters)
}