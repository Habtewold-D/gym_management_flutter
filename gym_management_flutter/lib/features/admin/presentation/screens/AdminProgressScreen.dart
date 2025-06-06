import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gym_management_flutter/core/services/admin_service.dart';

class AdminProgressScreen extends StatefulWidget {
  const AdminProgressScreen({Key? key}) : super(key: key);
  
  @override
  _AdminProgressScreenState createState() => _AdminProgressScreenState();
}

class _AdminProgressScreenState extends State<AdminProgressScreen> {
  late Future<List<dynamic>> _progressFuture;
  
  Future<List<dynamic>> fetchProgress() async {
    final adminService = AdminService();
    final headers = await adminService.getHeaders();
    final response = await http.get(
      Uri.parse('${adminService.baseUrl}/workouts/users/all-progress'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load progress: ${response.statusCode} ${response.body}');
    }
  }
  
  @override
  void initState() {
    super.initState();
    _progressFuture = fetchProgress();
  }
  
  Future<void> _refreshProgress() async {
    setState(() {
      _progressFuture = fetchProgress();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Progress"),
        backgroundColor: const Color(0xFF241A87),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProgress,
        child: FutureBuilder<List<dynamic>>(
          future: _progressFuture,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if(snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            if(!snapshot.hasData || snapshot.data!.isEmpty)
              return const Center(child: Text('No progress found'));
              
            final progressList = snapshot.data!;
            return ListView.builder(
              itemCount: progressList.length,
              itemBuilder: (context, index) {
                final progress = progressList[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("User: ${progress['name'] ?? 'N/A'}"),
                    subtitle: Text("Completion: ${progress['progressPercentage'] ?? 0}%"),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
