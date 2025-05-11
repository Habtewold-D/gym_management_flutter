package com.example.gymmanagement.ui.screens.admin.member

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.gymmanagement.data.model.UserProfile
import com.example.gymmanagement.viewmodel.AdminMemberViewModel

private val DeepBlue = Color(0xFF1A18C6)
private val LightBlue = Color(0xFFD0D8EC)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminMemberScreen(
    viewModel: AdminMemberViewModel
) {
    val members by viewModel.members.collectAsState(initial = emptyList())
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()
    var searchId by remember { mutableStateOf("") }
    var searchedMember by remember { mutableStateOf<UserProfile?>(null) }

    // Filter out admin users
    val filteredMembers = members.filter { it.role?.lowercase() != "admin" }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
    ) {
        // Top Navigation Bar
        Surface(
            color = Color(0xFF0000CD),
            shadowElevation = 4.dp
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Members",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            // Find member section
            Text(
                text = "Find member",
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                color = Color.Black,
                modifier = Modifier.padding(top = 16.dp, bottom = 8.dp)
            )
            Text(
                text = "Trainee ID",
                fontSize = 14.sp,
                color = Color.Gray
            )
            Spacer(Modifier.height(4.dp))
            OutlinedTextField(
                value = searchId,
                onValueChange = { searchId = it },
                shape = RoundedCornerShape(8.dp),
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(Modifier.height(8.dp))
            Button(
                onClick = {
                    searchedMember = members.find { member ->
                        member.id?.toString() == searchId.trim()
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF0000CD)),
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("Search", color = Color.White, fontWeight = FontWeight.Bold)
            }

            Spacer(modifier = Modifier.height(16.dp))

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
                        color = Color.Red
                    )
                }
            } else if (searchedMember != null) {
                MemberDetailSection(searchedMember!!)
            } else {
                // Show the table
                Text(
                    text = "Members list",
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp,
                    color = Color.Black
                )
                Spacer(Modifier.height(8.dp))
                // Table header
                Row(
                    Modifier
                        .fillMaxWidth()
                        .background(Color(0xFFD0D8EC), RoundedCornerShape(4.dp))
                        .padding(vertical = 8.dp)
                ) {
                    Text("ID", Modifier.weight(1f), fontWeight = FontWeight.Bold)
                    Text("Name", Modifier.weight(2f), fontWeight = FontWeight.Bold)
                    Text("Age", Modifier.weight(1f), fontWeight = FontWeight.Bold)
                    Text("BMI", Modifier.weight(1f), fontWeight = FontWeight.Bold)
                    Spacer(Modifier.weight(0.5f))
                }
                // Table rows
                filteredMembers.forEach { member ->
                    Row(
                        Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(member.id?.toString() ?: "", Modifier.weight(1f))
                        Text(member.name ?: "", Modifier.weight(2f))
                        Text(member.age?.toString() ?: "", Modifier.weight(1f))
                        Text(member.bmi?.toString() ?: "", Modifier.weight(1f))
                        IconButton(
                            onClick = { viewModel.deleteMember(member) },
                            modifier = Modifier
                                .weight(0.5f)
                                .size(24.dp)
                        ) {
                            Icon(Icons.Default.Delete, contentDescription = "Delete", tint = Color.Red)
                        }
                    }
                    Divider()
                }
            }
        }
    }
}

@Composable
fun MemberDetailSection(member: UserProfile) {
    Column(
        modifier = Modifier
            .padding(start = 16.dp, top = 24.dp)
    ) {
        Text(
            text = "Members Detail",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = Color.Black,
            modifier = Modifier.padding(bottom = 12.dp)
        )
        DetailRow("Name", member.name)
        DetailRow("Email", member.email)
        DetailRow("Age", member.age?.toString() ?: "-")
        DetailRow("Height", member.height?.let { "${it.toInt()} cm" } ?: "-")
        DetailRow("Weight", member.weight?.let { "${it.toInt()} KG" } ?: "-")
        DetailRow("BMI", member.bmi?.let { String.format("%.2f", it) } ?: "-")
    }
}

@Composable
fun DetailRow(label: String, value: String) {
    Row(
        modifier = Modifier.padding(vertical = 6.dp)
    ) {
        Text(
            text = label,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = Color.Black,
            modifier = Modifier.width(90.dp)
        )
        Text(
            text = value,
            fontSize = 20.sp,
            color = Color.Gray,
            fontWeight = FontWeight.Normal,
            modifier = Modifier.padding(start = 12.dp)
        )
    }
}
