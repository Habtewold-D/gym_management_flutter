import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:3000';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  }
  // For iOS simulator or desktop
  return 'http://172.17.98.5:3000';
}

class User {
  final String email;
  User({required this.email});
  factory User.fromJson(Map<String, dynamic> json) => User(email: json['email']);
  Map<String, dynamic> toJson() => {'email': email};
}

class AuthResponse {
  final Map<String, dynamic> data;
  AuthResponse({required this.data});
  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      AuthResponse(data: json);
  // Added getters:
  String get accessToken => data['accessToken'] as String? ?? '';
  User get user => User.fromJson(data['user'] as Map<String, dynamic>);
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
  final String _baseUrl = 'http://localhost:3000';
  final _storage = const FlutterSecureStorage();

  AuthNotifier() : super(const AuthState());
  
  // Added getter:
  User? get currentUser => state.user;
  
  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userJson = prefs.getString('user_data');
      if (token != null) {
        state = AuthState(
          user: User.fromJson(json.decode(userJson!)),
        );
      }
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> _saveAuthData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('user_data', json.encode(user.toJson()));
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_data');
      state = const AuthState();
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        if (responseData['access_token'] == null || responseData['user'] == null) {
          state = const AuthState(error: 'Invalid response format from server');
          return false;
        }

        final authResponse = AuthResponse.fromJson(responseData);
        await _saveAuthData(authResponse.accessToken, authResponse.user);
        return true;
      } else {
        final errorData = json.decode(response.body);
        state = AuthState(error: errorData['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      state = AuthState(error: 'Could not connect to backend: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
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
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        await _saveAuthData(authResponse.accessToken, authResponse.user);
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
    await _loadStoredAuth();
    return state.user;
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'token');
    final userJson = await _storage.read(key: 'user_data');
    if (token != null && userJson != null) {
      state = AuthState(user: User.fromJson(json.decode(userJson)));
    } else {
      state = const AuthState();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});