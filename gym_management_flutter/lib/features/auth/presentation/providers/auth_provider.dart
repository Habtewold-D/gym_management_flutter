import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

  AuthNotifier() : super(const AuthState());

  User? get currentUser => state.user;

  Future<void> _saveAuthData(String token, User user) async {
    try {
      print('Saving token: $token'); // Debug log
      await _secureStorage.write(key: 'auth_token', value: token);
      await _secureStorage.write(key: 'user_data', value: json.encode(user.toJson()));
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: 'Failed to save auth data: $e');
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_data');
      state = const AuthState();
    } catch (e) {
      state = AuthState(error: 'Failed to clear auth data: $e');
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
        final token = responseData['access_token'];
        final userData = responseData['user'];
        if (token == null || userData == null) {
          state = const AuthState(error: 'Invalid response format from server');
          return false; // fixed: removed accidental "|" character
        }

        final user = User.fromJson(userData);
        await _saveAuthData(token, user);

        if (user.role.toLowerCase() != 'admin') {
          state = AuthState(error: 'You do not have permission to access this area');
          return false;
        }

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
      final token = await _secureStorage.read(key: 'auth_token');
      final userJson = await _secureStorage.read(key: 'user_data');
      print('Checked token: $token'); // Debug log
      if (token != null && userJson != null) {
        state = AuthState(user: User.fromJson(json.decode(userJson)));
      } else {
        state = const AuthState();
      }
    } catch (e) {
      state = AuthState(error: 'Failed to check auth status: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});