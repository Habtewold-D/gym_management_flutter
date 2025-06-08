import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:gym_management_flutter/features/auth/presentation/screens/splash_screen.dart';
import 'package:gym_management_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:gym_management_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:gym_management_flutter/features/admin/presentation/screens/AdminPage.dart';
import 'package:gym_management_flutter/features/member/presentation/screens/member_workouts_screen.dart';
import 'package:gym_management_flutter/features/member/presentation/screens/member_dashboard_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    ProviderScope(
      child: const GymManagementApp(),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class GymManagementApp extends ConsumerWidget {
  const GymManagementApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set system UI overlay style for the entire app
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Create the router inside build to access ref
    final router = GoRouter(
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
          path: '/member/workouts',
          name: 'member_workouts',
          builder: (context, state) => const MemberDashboardScreen(tab: 'workouts'),
        ),
        GoRoute(
          path: '/member/events',
          name: 'member_events',
          builder: (context, state) => const MemberDashboardScreen(tab: 'events'),
        ),
        GoRoute(
          path: '/member/profile',
          name: 'member_profile',
          builder: (context, state) => const MemberDashboardScreen(tab: 'profile'),
        ),
        // Redirect root member path to workouts tab
        GoRoute(
          path: '/member',
          redirect: (context, state) => '/member/workouts',
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final authState = ref.read(authProvider);
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
              : '/member/workouts';
        }
        
        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri.path}'),
        ),
      ),
    );
    
    // Listen to auth state changes
    ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.user?.id != next.user?.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            
            try {
              final currentLocation = GoRouterState.of(context).matchedLocation;
              debugPrint('Auth state changed - current location: $currentLocation');
              
              if (next.user != null) {
                // User logged in
                final isAuthRoute = currentLocation == '/login' || 
                                  currentLocation == '/register' ||
                                  currentLocation == '/splash';
                
                if (isAuthRoute) {
                  final route = next.user!.role.toLowerCase() == 'admin' 
                      ? '/admin' 
                      : '/member/workouts';
                  debugPrint('Redirecting to: $route');
                  router.go(route);
                }
              } else if (previous?.user != null) {
                // User logged out
                if (currentLocation != '/login') {
                  debugPrint('User logged out, redirecting to login');
                  router.go('/login');
                }
              }
            } catch (e) {
              debugPrint('Error in auth state listener: $e');
            }
          });
        }
      },
    );

    return MaterialApp.router(
      title: 'Gym Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF241A87),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: const Color(0xFF241A87),
        ).copyWith(
          secondary: const Color(0xFF241A87),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF241A87),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF241A87),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF241A87), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[700]),
          floatingLabelStyle: const TextStyle(color: Color(0xFF241A87)),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}


