import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  return AuthService();
});

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';

  String? _token;
  String? _refreshToken;
  String? _userId;
  String? _userRole;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get userId => _userId;
  String? get userRole => _userRole;

  AuthService() {
    // Load saved auth data on initialization
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    _token = await _storage.read(key: _tokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    _userId = await _storage.read(key: _userIdKey);
    _userRole = await _storage.read(key: _userRoleKey);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      // This should be called from your API service
      // final response = await _apiService.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });
      
      // For now, we'll simulate a successful login
      await saveAuthData(
        token: 'dummy_token',
        refreshToken: 'dummy_refresh_token',
        userId: '1',
        userRole: 'admin', // or 'member' based on user
      );
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String userRole,
  }) async {
    _token = token;
    _refreshToken = refreshToken;
    _userId = userId;
    _userRole = userRole;
    
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userRoleKey, value: userRole),
    ]);
    
    notifyListeners();
  }

  Future<Map<String, String?>> getAuthData() async {
    return {
      'token': _token,
      'refreshToken': _refreshToken,
      'userId': _userId,
      'userRole': _userRole,
    };
  }

  Future<String?> getToken() async {
    _token ??= await _storage.read(key: _tokenKey);
    return _token;
  }

  Future<String?> getRefreshToken() async {
    _refreshToken ??= await _storage.read(key: _refreshTokenKey);
    return _refreshToken;
  }

  Future<String?> getUserId() async {
    _userId ??= await _storage.read(key: _userIdKey);
    return _userId;
  }

  Future<String?> getUserRole() async {
    _userRole ??= await _storage.read(key: _userRoleKey);
    return _userRole;
  }

  Future<void> clearAuthData() async {
    _token = null;
    _refreshToken = null;
    _userId = null;
    _userRole = null;
    
    await _storage.deleteAll();
    notifyListeners();
  }
}
