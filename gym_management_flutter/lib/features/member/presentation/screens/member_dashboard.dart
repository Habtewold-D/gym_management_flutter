import 'package:flutter/material.dart';

class MemberDashboard extends StatelessWidget {
  const MemberDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Dashboard'),
        backgroundColor: const Color(0xFF241A87),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Member Dashboard - Coming Soon'),
      ),
    );
  }
} 