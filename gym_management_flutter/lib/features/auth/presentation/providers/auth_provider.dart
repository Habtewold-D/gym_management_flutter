import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/models/user.dart';
import '../../domain/models/auth_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

class AuthProvider with ChangeNotifier {
  static final String _baseUrl = getBaseUrl();
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';
  final _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _userRole;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  String? get accessToken => _accessToken;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _accessToken != null;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson));
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _saveAuthData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, json.encode(user.toJson()));
      _accessToken = token;
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      _accessToken = null;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        debugPrint('Decoded response: $responseData');
        
        if (responseData['access_token'] == null || responseData['user'] == null) {
          _error = 'Invalid response format from server';
          debugPrint('Invalid response format: $responseData');
          return false;
        }

        final authResponse = AuthResponse.fromJson(responseData);
        await _saveAuthData(authResponse.accessToken, authResponse.user);
        
        // Set the role from the user object
        _userRole = authResponse.user.role;
        await _storage.write(key: 'role', value: _userRole);
        
        debugPrint('User role set to: $_userRole');
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Login failed';
        debugPrint('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      _error = 'Could not connect to backend: $e';
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    _error = null;
    notifyListeners();

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
        _error = errorData['message'] ?? 'Registration failed';
        debugPrint('Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      _error = 'Could not connect to backend: $e';
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
    _userRole = null;
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'role');
    notifyListeners();
  }

  Future<User?> getCurrentUser() async {
    await _loadStoredAuth();
    return _currentUser;
  }

  Future<void> checkAuthStatus() async {
    _accessToken = await _storage.read(key: 'token');
    _userRole = await _storage.read(key: 'role');
    notifyListeners();
  }
} 