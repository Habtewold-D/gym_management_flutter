//package com.example.gymmanagement.ui.screens.admin.member
//
//import androidx.compose.foundation.background
//import androidx.compose.foundation.layout.*
//import androidx.compose.foundation.lazy.LazyColumn
//import androidx.compose.foundation.lazy.items
//import androidx.compose.foundation.shape.RoundedCornerShape
//import androidx.compose.material.icons.Icons
//import androidx.compose.material.icons.filled.Delete
//import androidx.compose.material3.*
//import androidx.compose.runtime.*
//import androidx.compose.ui.Alignment
//import androidx.compose.ui.Modifier
//import androidx.compose.ui.graphics.Color
//import androidx.compose.ui.text.font.FontWeight
//import androidx.compose.ui.tooling.preview.Preview
//import androidx.compose.ui.unit.dp
//import androidx.compose.ui.unit.sp
//import androidx.lifecycle.viewmodel.compose.viewModel
//import com.example.gymmanagement.data.model.UserEntity
//import com.example.gymmanagement.data.model.UserProfile.UserProfile
//import com.example.gymmanagement.data.repository.UserRepository
//import com.example.gymmanagement.data.repository.UserRepositoryImpl
//import com.example.gymmanagement.ui.theme.GymManagementAppTheme
//import com.example.gymmanagement.viewmodel.AdminMemberViewModel
//import kotlinx.coroutines.flow.Flow
//import kotlinx.coroutines.flow.flowOf
//
//private val DeepBlue = Color(0xFF0000CD)
//private val LightBlue = Color(0xFFE6E9FD)
//
//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun AdminMemberScreen(
//    viewModel: AdminMemberViewModel
//) {
//    val members by viewModel.members.collectAsState(initial = emptyList())
//    var searchId by remember { mutableStateOf("") }
//    var searchedMember by remember { mutableStateOf<UserProfile?>(null) }
//
//    Column(
//        modifier = Modifier
//            .fillMaxSize()
//            .background(Color.White)
//    ) {
//        // Top Navigation Bar
//        Box(
//            modifier = Modifier
//                .fillMaxWidth()
//                .background(Color(0xFF0000CD))
//                .padding(16.dp)
//        ) {
//            Text(
//                text = "Members",
//                color = Color.White,
//                fontSize = 20.sp,
//                fontWeight = FontWeight.Medium
//            )
//        }
//
//        Column(
//            modifier = Modifier
//                .fillMaxSize()
//                .padding(16.dp)
//        ) {
//            // Find member section
//            Text(
//                text = "Find member",
//                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
//                modifier = Modifier.padding(bottom = 4.dp)
//            )
//            Text(
//                text = "Trainee ID",
//                style = MaterialTheme.typography.bodyMedium,
//                modifier = Modifier.padding(bottom = 4.dp)
//            )
//            OutlinedTextField(
//                value = searchId,
//                onValueChange = { searchId = it },
//                placeholder = { Text("1") },
//                modifier = Modifier
//                    .fillMaxWidth()
//                    .height(56.dp),
//                shape = RoundedCornerShape(4.dp),
//                colors = OutlinedTextFieldDefaults.colors(
//                    unfocusedBorderColor = LightBlue,
//                    focusedBorderColor = DeepBlue
//                )
//            )
//            Spacer(modifier = Modifier.height(12.dp))
//            Button(
//                onClick = {
//                    searchedMember = members.find { member ->
//                        member.id?.toString() == searchId
//                    }
//                },
//                modifier = Modifier
//                    .width(170.dp)
//                    .height(44.dp),
//                colors = ButtonDefaults.buttonColors(containerColor = DeepBlue),
//                shape = RoundedCornerShape(8.dp)
//            ) {
//                Text("Search", fontSize = 18.sp)
//            }
//
//            Spacer(modifier = Modifier.height(24.dp))
//
//            if (searchedMember != null) {
//                MemberDetailSection(searchedMember!!)
//            } else {
//                // Show the table
//            Text(
//                text = "Members list",
//                style = MaterialTheme.typography.titleMedium,
//                modifier = Modifier.padding(bottom = 8.dp)
//            )
//
//            // Table Header
//            Row(
//                modifier = Modifier
//                    .fillMaxWidth()
//                    .background(LightBlue)
//                    .padding(vertical = 8.dp),
//                verticalAlignment = Alignment.CenterVertically
//            ) {
//                Text("ID", modifier = Modifier.weight(0.7f), fontWeight = FontWeight.Bold)
//                Text("Name", modifier = Modifier.weight(2f), fontWeight = FontWeight.Bold)
//                Text("Age", modifier = Modifier.weight(1f), fontWeight = FontWeight.Bold)
//                Text("BMI", modifier = Modifier.weight(1f), fontWeight = FontWeight.Bold)
//                Spacer(modifier = Modifier.weight(0.5f)) // For delete icon
//            }
//
//            Divider()
//
//            LazyColumn(
//                verticalArrangement = Arrangement.spacedBy(0.dp),
//                modifier = Modifier.fillMaxWidth()
//            ) {
//                items(members) { member ->
//                    Row(
//                        modifier = Modifier
//                            .fillMaxWidth()
//                            .padding(vertical = 8.dp),
//                        verticalAlignment = Alignment.CenterVertically
//                    ) {
//                        Text(member.id?.toString() ?: "-", modifier = Modifier.weight(0.7f))
//                        Text(member.name, modifier = Modifier.weight(2f))
//                        Text(member.age?.toString() ?: "-", modifier = Modifier.weight(1f))
//                            Text(
//                                member.bmi?.let { String.format("%.2f", it) } ?: "-",
//                                modifier = Modifier.weight(1f)
//                            )
//                        IconButton(
//                            onClick = { viewModel.deleteMember(member) },
//                            modifier = Modifier.weight(0.5f)
//                        ) {
//                            Icon(
//                                imageVector = Icons.Default.Delete,
//                                contentDescription = "Delete Member",
//                                tint = Color.Red
//                            )
//                        }
//                    }
//                    Divider()
//                }
//            }
//        }
//        }
//    }
//}
//
//@Composable
//fun MemberDetailSection(member: UserProfile) {
//    Column(
//        modifier = Modifier
//            .padding(start = 16.dp, top = 24.dp)
//    ) {
//        Text(
//            text = "Members Detail",
//            fontSize = 28.sp,
//            fontWeight = FontWeight.Bold,
//            color = Color.Black
//        )
//        Spacer(modifier = Modifier.height(16.dp))
//        DetailRow("Name", member.name)
//        DetailRow("Email", member.email)
//        DetailRow("Age", member.age?.toString() ?: "-")
//        DetailRow("Height", member.height?.let { "${it.toInt()} cm" } ?: "-")
//        DetailRow("Weight", member.weight?.let { "${it.toInt()} KG" } ?: "-")
//        DetailRow("BMI", member.bmi?.let { String.format("%.2f", it) } ?: "-")
//    }
//}
//
//@Composable
//fun DetailRow(label: String, value: String) {
//    Row(
//        modifier = Modifier.padding(vertical = 6.dp)
//    ) {
//        Text(
//            text = label,
//            fontSize = 22.sp,
//            fontWeight = FontWeight.Bold,
//            color = Color.Black,
//            modifier = Modifier.width(90.dp)
//        )
//        Text(
//            text = value,
//            fontSize = 22.sp,
//            color = Color.Gray,
//            fontWeight = FontWeight.Normal,
//            modifier = Modifier.padding(start = 12.dp)
//        )
//    }
//}
//
//
//
