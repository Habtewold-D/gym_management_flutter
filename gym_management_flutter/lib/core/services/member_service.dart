import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/event_model.dart' show EventResponse;
import 'package:gym_management_flutter/core/models/user_profile.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/core/services/auth_service.dart';

final memberServiceProvider = Provider<MemberService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return MemberService(authService);
});

class MemberService {
  final AuthService _authService;
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000';
  String get _basePath => '$_baseUrl/member';

  MemberService(this._authService);

  /// Fetches all workouts assigned to a specific member
  Future<List<WorkoutResponse>> getMemberWorkouts({required String userId}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.get(
        '$_basePath/users/$userId/workouts',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
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
        '$_basePath/users/$userId/workouts/$workoutId/status',
        data: {'isCompleted': isCompleted},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );
      
      if (response.statusCode == 401) {
        throw Exception('Authentication required');
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

  /// Fetches all events available to the current member
  Future<List<EventResponse>> getMemberEvents() async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get(
        '$_basePath/events',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List)
          .map((json) => EventResponse.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint('Error fetching member events: ${e.message}');
      rethrow;
    }
  }

  /// Registers the current member for an event
  Future<void> registerForEvent(String eventId) async {
    try {
      final token = await _authService.getToken();
      await _dio.post(
        '$_basePath/events/$eventId/register',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      debugPrint('Error registering for event: ${e.message}');
      rethrow;
    }
  }

  /// Fetches the current member's profile
  Future<UserProfile> getMemberProfile() async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get(
        '$_basePath/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error fetching member profile: ${e.message}');
      rethrow;
    }
  }

  /// Updates the current member's profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.put(
        '$_basePath/profile',
        data: profile.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error updating profile: ${e.message}');
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
