import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:3000';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://172.17.98.5:3000';
}

class User {
  final String email;
  final String role;
  final int id;
  final String? name;

  User({
    required this.email,
    required this.role,
    required this.id,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json['email'] ?? '',
        role: json['role'] ?? 'user',
        id: json['id'] ?? 0,
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'role': role,
        'id': id,
        'name': name,
      };
}

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, User? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final String _baseUrl = getBaseUrl();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _initialized = false;
  bool _mounted = true;
  
  bool get mounted => _mounted;

  AuthNotifier() : super(const AuthState(isLoading: true)) {
    // Initialize auth state
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await checkAuthStatus();
    } finally {
      state = state.copyWith(isLoading: false);
      _initialized = true;
    }
  }

  bool get isInitialized => _initialized;

  User? get currentUser => state.user;

  Future<void> _saveAuthData(String token, User user) async {
    try {
      debugPrint('Saving auth data for user: ${user.email}');
      await _secureStorage.write(key: 'auth_token', value: token);
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(user.toJson()),
      );
      debugPrint('Auth data saved successfully');
      if (mounted) {
        state = AuthState(
          user: user,
          error: null,
          isLoading: state.isLoading,
        );
      }
    } catch (e) {
      final error = 'Failed to save auth data: $e';
      debugPrint(error);
      if (mounted) {
        state = state.copyWith(error: error);
      }
      rethrow;
    }
  }

  // Clear any error from the state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
  
  Future<void> _clearAuthData() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_data');
      if (mounted) {
        state = const AuthState();
      }
    } catch (e) {
      if (mounted) {
        state = AuthState(error: 'Failed to clear auth data: $e');
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('Attempting login for email: $email');
      state = state.copyWith(isLoading: true, error: null);
      
      // Ensure state is updated before proceeding
      await Future.delayed(Duration.zero);
      
      // Remove /api from the URL as per user's note
      final baseUrl = _baseUrl.replaceAll('/api', '');
      final url = '$baseUrl/auth/login';
      debugPrint('Using login URL: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = json.decode(response.body);
          
          // Handle the response format with access_token and user object
          final userJson = data['user'] is Map ? data['user'] : data;
          final token = data['access_token'] as String? ?? data['token'] as String?;
          
          if (userJson == null || token == null) {
            throw Exception('Invalid response format: Missing user or token');
          }
          
          debugPrint('User data: $userJson');
          final user = User.fromJson(userJson);
          
          debugPrint('Login successful for user: ${user.email}, role: ${user.role}');
          debugPrint('Saving auth data...');
          
          // Save auth data and wait for it to complete
          await _saveAuthData(token, user);
          
          debugPrint('Auth data saved, updating state...');
          
          // Update state with the new user
          if (mounted) {
            state = state.copyWith(
              user: user, 
              error: null,
              isLoading: false,
            );
            debugPrint('State updated with user: ${state.user?.email}');
          }
          
          return true;
        } catch (e) {
          debugPrint('Error parsing login response: $e');
          throw Exception('Failed to process login response');
        }
      } else {
        String errorMessage = 'Login failed';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {
          errorMessage = 'Invalid server response';
        }
        debugPrint('Login failed: $errorMessage (Status: ${response.statusCode})');
        state = state.copyWith(error: errorMessage, user: null);
        return false;
      }
    } on http.ClientException catch (e) {
      final error = 'Network error: ${e.message}';
      debugPrint(error);
      state = state.copyWith(error: error, user: null);
      return false;
    } on TimeoutException {
      const error = 'Connection timeout. Please check your internet connection.';
      debugPrint(error);
      state = state.copyWith(error: error, user: null);
      return false;
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      state = state.copyWith(
        error: 'An unexpected error occurred. Please try again.',
        user: null,
      );
      return false;
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required int age,
    required double height,
    required double weight,
  }) async {
    state = const AuthState(isLoading: true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'age': age,
          'height': height,
          'weight': weight,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final token = responseData['access_token'];
        final userData = responseData['user'];
        if (token == null || userData == null) {
          state = const AuthState(error: 'Invalid response format from server');
          return false;
        }

        final user = User.fromJson(userData);
        await _saveAuthData(token, user);
        return true;
      } else {
        final errorData = json.decode(response.body);
        state = AuthState(error: errorData['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      state = AuthState(error: 'Could not connect to backend: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
  }

  Future<User?> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(key: 'user_data');
      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }
      return null;
    } catch (e) {
      state = AuthState(error: 'Failed to load user data: $e');
      return null;
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final token = await _secureStorage.read(key: 'auth_token');
      final userData = await _secureStorage.read(key: 'user_data');
      
      if (token != null && userData != null) {
        try {
          final user = User.fromJson(json.decode(userData));
          state = state.copyWith(
            user: user,
            error: null,
            isLoading: false,
          );
        } catch (e) {
          // Clear invalid user data
          await _clearAuthData();
          state = state.copyWith(
            user: null,
            error: 'Session expired. Please login again.',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          user: null,
          error: null,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to check authentication status: $e',
        isLoading: false,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = AuthNotifier();
  // Check auth status when the app starts
  Future.microtask(() => auth.checkAuthStatus());
  return auth;
});