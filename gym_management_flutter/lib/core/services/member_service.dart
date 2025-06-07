import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/core/models/user_profile.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/core/services/auth_service.dart';
import 'package:flutter/foundation.dart';

final memberServiceProvider = Provider<MemberService>((ref) {
  final authService = ref.read(authServiceProvider);
  return MemberService(authService);
});

class MemberService {
  final Dio _dio;
  final String _baseUrl;
  final String _basePath;
  final String _usersPath;
  final AuthService _authService;

  MemberService(AuthService authService, {Dio? dio}) 
      : _authService = authService,
        _dio = dio ?? Dio(),
        _baseUrl = _getBaseUrl(),
        _basePath = '${_getBaseUrl()}/member',
        _usersPath = '${_getBaseUrl()}/users' {
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          options.headers['Content-Type'] = 'application/json';
        }
        return handler.next(options);
      },
    ));
  }
  
  static String _getBaseUrl() {
    // Return localhost for mobile and web
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    // For Android emulator, use 10.0.2.2 to access localhost
    return 'http://10.0.2.2:3000';
  }

  /// Get the current authenticated user's ID
  String? getCurrentUserId() {
    try {
      return _authService.userId;
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
      return null;
    }
  }
  
  /// Get the current user's token
  Future<String?> getToken() async {
    try {
      return await _authService.getToken();
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  /// Fetches the current member's profile
  Future<UserProfile> getProfile(int userId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.get(
        '$_usersPath/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status! < 500,
        ),
      );
      
      if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to view this profile');
      } else if (response.statusCode != 200) {
        throw Exception('Failed to load profile: ${response.data?['message'] ?? 'Unknown error'}');
      }
      
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error fetching member profile: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      rethrow;
    }
  }

  /// Updates the current member's profile
  Future<UserProfile> updateProfile(UserProfile userProfile) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.patch(
        '$_usersPath/${userProfile.id}',
        data: userProfile.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status! < 500,
        ),
      );
      
      if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to update this profile');
      } else if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.data?['message'] ?? 'Unknown error'}');
      }
      
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error updating member profile: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      rethrow;
    }
  }

  /// Fetches all workouts assigned to the current member
  Future<List<WorkoutResponse>> getMemberWorkouts() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.get(
        '$_baseUrl/workouts/my-workout',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status! < 500,
        ),
      );
      
      if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (response.statusCode != 200) {
        throw Exception('Failed to load workouts: ${response.data?['message'] ?? 'Unknown error'}');
      }
      
      return (response.data as List)
          .map((json) => WorkoutResponse.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint('Error fetching member workouts: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('You do not have permission to view your workouts');
      }
      rethrow;
    }
  }
  


  /// Fetches a specific workout by ID
  Future<WorkoutResponse> getWorkoutById(String workoutId) async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get(
        '$_basePath/workouts/$workoutId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return WorkoutResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error fetching workout $workoutId: ${e.message}');
      rethrow;
    }
  }

  /// Updates the completion status of a workout
  Future<void> updateWorkoutStatus({
    required String workoutId,
    required bool isCompleted,
    required String userId,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.patch(
        '$_baseUrl/workouts/$workoutId',
        data: {
          'isCompleted': isCompleted,
          'userId': userId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status! < 500,
        ),
      );
      
      if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode != 200) {
        throw Exception('Failed to update workout status: ${response.data?['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      debugPrint('Error updating workout status: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      rethrow;
    }
  }

  Future<void> markWorkoutAsCompleted(String workoutId, bool isCompleted) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      debugPrint('Sending PATCH to: $_baseUrl/workouts/$workoutId/toggle-completion');
      
      final response = await _dio.patch(
        '$_baseUrl/workouts/$workoutId/toggle-completion',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to update workout status: ${response.data?['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      debugPrint('DioError in markWorkoutAsCompleted: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 403) {
        throw Exception('You do not have permission to update this workout');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Workout not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      rethrow;
    } catch (e) {
      debugPrint('Error in markWorkoutAsCompleted: $e');
      rethrow;
    }
  }

  /// Fetches all events available to the current member
  Future<List<EventResponse>> getMemberEvents() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      debugPrint('Fetching events from: $_baseUrl/events');
      
      final response = await _dio.get(
        '$_baseUrl/events',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500, // Don't throw for 4xx errors
        ),
      );
      
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => EventResponse.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error fetching member events: $e');
      if (e.response != null) {
        debugPrint('Response data: ${e.response?.data}');
        debugPrint('Status code: ${e.response?.statusCode}');
      }
      debugPrint('Error fetching member events: ${e.message}');
      rethrow;
    }
  }

  /// Uploads a profile image for the current member
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.post(
        '$_basePath/profile/image',
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(imageFile.path),
        }),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['imageUrl'];
    } on DioException catch (e) {
      debugPrint('Error uploading profile image: ${e.message}');
      rethrow;
    }
  }

  /// Handles errors from API calls
  Never _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        throw error.response?.data['message'] ?? 'An error occurred';
      } else {
        throw error.message ?? 'Network error occurred';
      }
    }
    throw error.toString();
  }
}
