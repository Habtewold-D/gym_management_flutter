import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:gym_management_flutter/core/services/admin_service.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_management_flutter/navigation/app_routes.dart';
import 'package:flutter/services.dart';
import 'package:gym_management_flutter/utils/app_theme_utils.dart';

class AdminProgressScreen extends ConsumerStatefulWidget {
  const AdminProgressScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<AdminProgressScreen> createState() => _AdminProgressScreenState();
}

class _AdminProgressScreenState extends ConsumerState<AdminProgressScreen> {
  late Future<List<dynamic>> _progressFuture;
  
  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go(AppRoutes.LOGIN);
    }
  }
  
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
    // Set system UI overlay style when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppThemeUtils.setSystemUIOverlay();
    });
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
        title: const Text('Gym Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProgress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Daily Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0000CD),
                ),
              ),
            ),
            Expanded(
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
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: const Color(0xFFB0C4DE),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${index + 1}. ${progress['name'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${progress['progressPercentage'] ?? 0}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
