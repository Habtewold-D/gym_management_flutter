import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'member_workouts_screen.dart';
import 'member_profile_screen.dart';

class MemberDashboardScreen extends ConsumerStatefulWidget {
  final String tab;
  
  const MemberDashboardScreen({
    Key? key,
    this.tab = 'workouts',
  }) : super(key: key);

  @override
  ConsumerState<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends ConsumerState<MemberDashboardScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const MemberWorkoutsScreen(),
    const MemberProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getIndexFromTab(widget.tab);
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getIndexFromTab(String tab) {
    switch (tab) {
      case 'profile':
        return 1;
      case 'workouts':
      default:
        return 0;
    }
  }

  String _getTabFromIndex(int index) {
    switch (index) {
      case 1:
        return 'profile';
      case 0:
      default:
        return 'workouts';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
    // Update the URL when tab changes
    final tab = _getTabFromIndex(index);
    context.go('/member/$tab');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF241A87),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
