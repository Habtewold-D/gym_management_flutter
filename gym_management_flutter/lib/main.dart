import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

void main() {
  runApp(const ProviderScope(child: GymManagementApp()));
}

class GymManagementApp extends ConsumerWidget {
  const GymManagementApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return MaterialApp.router(
      title: 'Gym Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerDelegate: MyRouterDelegate(authState),
      routeInformationParser: MyRouteInformationParser(),
    );
  }
}

class MyRoutePath {
  final String location;
  const MyRoutePath(this.location);
}

class MyRouterDelegate extends RouterDelegate<MyRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<MyRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final authState; // Auth state from Riverpod
  String? _selectedPage; // 'login' or 'register'

  MyRouterDelegate(this.authState);

  // Callback to be passed to SplashScreen.
  void _onLoginSelected() {
    _selectedPage = '/login';
    notifyListeners();
  }
  void _onRegisterSelected() {
    _selectedPage = '/register';
    notifyListeners();
  }

  @override
  MyRoutePath? get currentConfiguration {
    if (authState.isLoading || (_selectedPage == null && authState.user == null)) {
      return const MyRoutePath('/splash');
    }
    if (authState.user != null) return const MyRoutePath('/home');
    return MyRoutePath(_selectedPage!);
  }

  @override
  Widget build(BuildContext context) {
    List<Page> pages = [];
    if (authState.isLoading || (_selectedPage == null && authState.user == null)) {
      // SplashScreen now provides buttons through callbacks.
      pages.add(MaterialPage(
          key: const ValueKey('Splash'),
          child: SplashScreen(
            onLoginSelected: _onLoginSelected,
            onRegisterSelected: _onRegisterSelected,
          )));
    } else if (authState.user != null) {
      pages.add(MaterialPage(
          key: const ValueKey('Home'),
          child: Scaffold(
            appBar: AppBar(title: const Text("Home")),
            body: Center(child: Text("Welcome, ${authState.user!.email}")),
          )));
    } else if (_selectedPage == '/login') {
      pages.add(const MaterialPage(key: ValueKey('Login'), child: LoginScreen()));
    } else if (_selectedPage == '/register') {
      pages.add(const MaterialPage(key: ValueKey('Register'), child: RegisterScreen()));
    }
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        // Reset selection when a page is popped.
        _selectedPage = null;
        notifyListeners();
        return true;
      },
    );
  }
  
  @override
  Future<void> setNewRoutePath(MyRoutePath configuration) async {
    // No-op; navigation is controlled by auth state and splash callbacks.
  }
}

class MyRouteInformationParser extends RouteInformationParser<MyRoutePath> {
  @override
  Future<MyRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '');
    if (uri.path.isEmpty) return const MyRoutePath('/splash');
    return MyRoutePath(uri.path);
  }
  
  @override
  RouteInformation restoreRouteInformation(MyRoutePath configuration) {
    return RouteInformation(location: configuration.location);
  }
}
