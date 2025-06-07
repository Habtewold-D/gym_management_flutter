import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:gym_management_flutter/core/models/member_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gym_management_flutter/core/services/admin_service.dart';

class AdminMemberScreen extends StatefulWidget {
  const AdminMemberScreen({Key? key}) : super(key: key);

  @override
  _AdminMemberScreenState createState() => _AdminMemberScreenState();
}

class _AdminMemberScreenState extends State<AdminMemberScreen> {
  late Future<List<Member>> _membersFuture;
  Member? searchedMember;
  final TextEditingController _searchController = TextEditingController();
  
  Future<List<Member>> fetchMembers() async {
    final adminService = AdminService();
    // Use the AdminService method which uses the correct endpoint from the Kotlin app
    return await adminService.getMembers();
  }

  // Helper function to retrieve the auth token.
  // This version retrieves the token from secure storage.
  Future<String> getAuthToken() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token'); 
    if (token == null || token.isEmpty) {
      throw Exception("No auth token found. Please log in.");
    }
    return token;
  }
  
  @override
  void initState() {
    super.initState();
    _membersFuture = fetchMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshMembers() async {
    try {
      setState(() {
        _membersFuture = fetchMembers();
        searchedMember = null;
        _searchController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing members: $e')),
        );
      }
    }
  }
  
  void _performSearch(List<Member> members) {
    setState(() {
      searchedMember = members.firstWhereOrNull((member) =>
        member.id.toString() == _searchController.text.trim());
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gym Progress"),
        backgroundColor: const Color(0xFF241A87),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMembers,
        child: FutureBuilder<List<Member>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return const Center(child: Text('No members found'));
              
            List<Member> members = snapshot.data!;
            final filteredMembers = members.where((member) =>
                member.role.toLowerCase() != "admin").toList();
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Find member",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            key: const Key("search_by_id_field"),
                            decoration: const InputDecoration(
                              labelText: "Trainee ID",
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _performSearch(members),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF241A87),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          child: const Text("Search", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (searchedMember != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Members Detail",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        MemberDetailSection(member: searchedMember!),
                      ],
                    )
                  else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Members list",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Age')),
                          DataColumn(label: Text('BMI')),
                          DataColumn(label: Text('')), // For the delete icon
                        ],
                        rows: filteredMembers.map((member) => DataRow(
                          cells: [
                            DataCell(Text(member.id.toString())),
                            DataCell(Text(member.name)),
                            DataCell(Text(member.age?.toString() ?? 'N/A')),
                            DataCell(Text(member.bmi?.toStringAsFixed(2) ?? 'N/A')),
                            DataCell(IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Member'),
                                    content: Text('Are you sure you want to delete ${member.name}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  try {
                                    final adminService = AdminService();
                                    await adminService.deleteMember(member.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Member deleted successfully')),
                                      );
                                    }
                                    _refreshMembers();
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error deleting member: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                            )),
                          ],
                        )).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MemberDetailSection extends StatelessWidget {
  final Member member;
  const MemberDetailSection({Key? key, required this.member}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Name:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(member.name, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(member.email, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Age:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(member.age?.toString() ?? 'N/A', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Height:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${member.height?.toStringAsFixed(1) ?? 'N/A'} cm', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Weight:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${member.weight?.toStringAsFixed(1) ?? 'N/A'} KG', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("BMI:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(member.bmi?.toStringAsFixed(2) ?? 'N/A', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
