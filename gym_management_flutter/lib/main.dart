import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/admin/presentation/screens/AdminPage.dart';
import 'features/member/presentation/screens/member_workouts_screen.dart';
import 'features/member/presentation/screens/member_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: GymManagementApp(),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    // Public routes
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    
    // Protected routes
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminPage(),
    ),
    // Member dashboard with tabs
    GoRoute(
      path: '/member/:tab(workouts|profile)',
      name: 'member_dashboard',
      builder: (context, state) {
        final tab = state.pathParameters['tab'] ?? 'workouts';
        return MemberDashboardScreen(tab: tab);
      },
    ),
    // Redirect root member path to workouts tab
    GoRoute(
      path: '/member',
      redirect: (context, state) => '/member/workouts',
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    try {
      final authState = ProviderScope.containerOf(context).read(authProvider);
      final isLoggedIn = authState.user != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register' ||
                          state.matchedLocation == '/splash';
      
      // If user is not logged in and trying to access protected route, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      
      // If user is logged in and trying to access auth route, redirect to appropriate dashboard
      if (isLoggedIn && isAuthRoute && state.matchedLocation != '/splash') {
        return authState.user!.role.toLowerCase() == 'admin' 
            ? '/admin' 
            : '/member/workouts'; // Always redirect members to workouts tab
      }
    } catch (e) {
      // If we can't read the auth state, redirect to login
      return '/login';
    }
    
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);

class GymManagementApp extends ConsumerWidget {
  const GymManagementApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes
    ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (!context.mounted) return;
        
        // Only handle navigation if this is a real state change, not initial build
        if (previous?.user?.id != next.user?.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            
            // Handle login/logout redirects
            if (next.user != null) {
              // User logged in or changed
              final currentRoute = GoRouterState.of(context).matchedLocation;
              final isAuthRoute = currentRoute == '/login' || 
                                currentRoute == '/register' ||
                                currentRoute == '/splash';
              
              if (isAuthRoute) {
                final route = next.user!.role.toLowerCase() == 'admin' ? '/admin' : '/member/workouts';
                context.go(route);
              }
            } else if (previous?.user != null) {
              // User logged out - only redirect if not already on login page
              final currentRoute = GoRouterState.of(context).matchedLocation;
              if (currentRoute != '/login') {
                context.go('/login');
              }
            }
          });
        }
      },
    );
    
    return MaterialApp.router(
      title: 'Gym Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF241A87),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
      routerConfig: _router,
    );
  }
}


