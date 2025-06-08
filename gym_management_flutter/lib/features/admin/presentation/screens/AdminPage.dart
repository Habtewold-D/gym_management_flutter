import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'AdminWorkoutScreen.dart'; // updated import to match file name
import 'AdminEventScreen.dart';   // updated import
import 'AdminMemberScreen.dart';  // updated import
import 'AdminProgressScreen.dart';// updated import

// New Riverpod notifier for admin navigation:
class AdminNavigationNotifier extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  void setIndex(int index) {
    if (index != _selectedIndex) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
final adminNavigationProvider = ChangeNotifierProvider<AdminNavigationNotifier>(
    (ref) => AdminNavigationNotifier());

// Modified AdminPage to use Navigator 2 with Riverpod:
class AdminPage extends ConsumerWidget {
  const AdminPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navNotifier = ref.watch(adminNavigationProvider);
    final pages = [
      const AdminWorkoutScreen(userId: 0), // pass int userId
      const AdminEventScreen(userId: 0),     // pass int userId
      const AdminMemberScreen(),
      const AdminProgressScreen(),
    ];
    
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Admin Dashboard"),
      //   backgroundColor: const Color(0xFF241A87),
      // ),
      body: Navigator(
        pages: [
          MaterialPage(
            key: ValueKey(navNotifier.selectedIndex),
            child: pages[navNotifier.selectedIndex],
          )
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          return true;
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navNotifier.selectedIndex,
        onTap: (index) =>
            ref.read(adminNavigationProvider.notifier).setIndex(index),
        type: BottomNavigationBarType.fixed,
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
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
