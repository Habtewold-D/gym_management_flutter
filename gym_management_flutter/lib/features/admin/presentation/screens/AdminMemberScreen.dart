import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:gym_management_flutter/core/models/member_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // new import

class AdminMemberScreen extends StatefulWidget {
  const AdminMemberScreen({Key? key}) : super(key: key);

  @override
  _AdminMemberScreenState createState() => _AdminMemberScreenState();
}

class _AdminMemberScreenState extends State<AdminMemberScreen> {
  late Future<List<dynamic>> _membersFuture;
  String searchId = "";
  Member? searchedMember;
  
  Future<List<dynamic>> fetchMembers() async {
    final token = await getAuthToken(); // retrieve saved token
    print("Fetching members with token: $token"); // added logging
    final response = await http.get(
      Uri.parse('http://localhost:3000/admin/users/members'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print("Response for members: ${response.statusCode}\nBody: ${response.body}"); // added logging
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Token may be expired or invalid.');
    } else {
      throw Exception('Failed to load members');
    }
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
  
  Future<void> _refreshMembers() async {
    setState(() {
      _membersFuture = fetchMembers();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Members"),
        backgroundColor: const Color(0xFF241A87),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMembers,
        child: FutureBuilder<List<dynamic>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if(snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            if(!snapshot.hasData || snapshot.data!.isEmpty)
              return const Center(child: Text('No members found'));
              
            List<Member> members = [];
            snapshot.data!.forEach((e) {
              members.add(Member(
                id: e['id'],
                name: e['name'],
                email: e['email'] ?? '',
                role: e['role'] ?? '',
                joinDate: e['joinDate'] ?? '',  // added joinDate parameter
              ));
            });
            
            final filteredMembers = members.where((member) => member.role.toLowerCase() != "admin").toList();
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    key: const Key("search_by_id_field"), // added unique key so that the input gets an id/name attribute
                    decoration: const InputDecoration(
                      labelText: "Search by ID"
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchId = value;
                        searchedMember = members.firstWhereOrNull((member) => member.id.toString() == searchId.trim());
                      });
                    },
                  ),
                ),
                if(searchedMember != null)
                  Expanded(child: MemberDetailSection(member: searchedMember!))
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredMembers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListTile(
                            title: Text(member.name),
                            subtitle: Text('ID: ${member.id}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Call API to delete member here
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF241A87),
        child: const Icon(Icons.person_add),
        onPressed: () {
          // Member registration UI
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Add Member"),
              content: const Text("Member registration UI goes here."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                )
              ],
            ),
          );
        },
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${member.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("ID: ${member.id}", style: const TextStyle(fontSize: 16)),
            // Add more details if available
          ],
        ),
      ),
    );
  }
}
