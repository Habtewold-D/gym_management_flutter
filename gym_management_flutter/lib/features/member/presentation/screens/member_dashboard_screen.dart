import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_management_flutter/features/member/presentation/screens/member_workouts_screen.dart';
import 'package:gym_management_flutter/features/member/presentation/screens/member_events_screen.dart';
import 'package:gym_management_flutter/features/member/presentation/screens/member_profile_screen.dart';

// Define the tabs that will be used in the member dashboard
const List<String> _tabs = ['workouts', 'events', 'profile'];

class MemberDashboardScreen extends ConsumerStatefulWidget {
  final String tab;

  const MemberDashboardScreen({super.key, required this.tab});

  @override
  ConsumerState<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends ConsumerState<MemberDashboardScreen> {
  late final PageController _pageController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _tabs.indexOf(widget.tab);
    if (_selectedIndex == -1) _selectedIndex = 0;
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Ensure the URL reflects the initial tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go('/member/${_tabs[_selectedIndex]}');
      }
    });
  }

  @override
  void didUpdateWidget(MemberDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tab != oldWidget.tab) {
      final newIndex = _tabs.indexOf(widget.tab);
      if (newIndex != -1 && newIndex != _selectedIndex) {
        setState(() => _selectedIndex = newIndex);
        _pageController.jumpToPage(newIndex);
      }
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
        _pageController.jumpToPage(index);
      });
      context.go('/member/${_tabs[index]}');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          MemberWorkoutsScreen(),
          MemberEventsScreen(),
          MemberProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black87,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
