import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/screens/splash/SplashScreen.dart';
import '../ui/screens/login/LoginScreen.dart';
import '../ui/screens/register/RegisterScreen.dart';
import '../ui/screens/admin/AdminPage.dart';
import '../ui/screens/member/MemberScreen.dart';
import 'AppRoutes.dart';

@Composable
void AppNavigation() {
  final navController = rememberNavController();
  // ...existing authViewModel and state collection...
  NavHost(
    navController: navController,
    startDestination: AppRoutes.SPLASH,
  ) {
    composable(AppRoutes.SPLASH) {
      SplashScreen(navController: navController /*, viewModel: authViewModel */);
    }
    composable(AppRoutes.LOGIN) {
      LoginScreen(
        navController: navController,
        // ... pass required callbacks and viewModel ...
        onLoginSuccess: (isAdmin) {
          final route = isAdmin ? AppRoutes.ADMIN : AppRoutes.MEMBER;
          navController.navigate(route) {
            popUpTo(AppRoutes.LOGIN) { inclusive = true }
            launchSingleTop = true;
          }
        },
      );
    }
    composable(AppRoutes.REGISTER) {
      RegisterScreen(
        navController: navController,
        // ... pass viewModel or callbacks ...
      );
    }
    // Admin route now points to AdminPage.
    composable(AppRoutes.ADMIN) {
      const AdminPage();
    }
    // Member route remains as before.
    composable(AppRoutes.MEMBER) {
      MemberScreen(navController: navController /*, viewModel: authViewModel */);
    }
  }
}
