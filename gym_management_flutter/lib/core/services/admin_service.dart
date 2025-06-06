import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_models.dart';
import '../models/event_model.dart';
import '../models/member_model.dart';
import '../models/progress_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:3000';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://172.17.98.5:3000';
}

class AdminService {
  final String baseUrl = getBaseUrl();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  AdminService();

  Future<Map<String, String>> getHeaders() async {
    final token = await _secureStorage.read(key: 'auth_token');
    print('Token for request: $token'); // Debug log
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  Future<List<WorkoutResponse>> getWorkouts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workouts'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => WorkoutResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load workouts: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load workouts: $e');
    }
  }
  
  Future<List<EventResponse>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => EventResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }
  
  Future<List<Member>> getMembers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/members'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Member.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load members: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load members: $e');
    }
  }
  
  Future<List<TraineeProgress>> getProgress() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workouts/users/all-progress'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => TraineeProgress.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load progress: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load progress: $e');
    }
  }
  
  Future<WorkoutResponse> createWorkout(WorkoutRequest workoutRequest) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workouts'),
        headers: await getHeaders(),
        body: json.encode(workoutRequest.toJson()),
      );
      if (response.statusCode == 201) {
        return WorkoutResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create workout: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create workout: $e');
    }
  }
  
  Future<WorkoutResponse> updateWorkout(WorkoutUpdateRequest workoutUpdateRequest) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/workouts/${workoutUpdateRequest.id}'),
        headers: await getHeaders(),
        body: json.encode(workoutUpdateRequest.toJson()),
      );
      if (response.statusCode == 200) {
        return WorkoutResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update workout: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update workout: $e');
    }
  }
  
  Future<void> deleteWorkout(int workoutId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/workouts/$workoutId'),
        headers: await getHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete workout: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }
  
  Future<EventResponse> createEvent(EventRequest eventRequest) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: await getHeaders(),
        body: json.encode(eventRequest.toJson()),
      );
      if (response.statusCode == 201) {
        return EventResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create event: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }
  
  Future<EventResponse> updateEvent(EventUpdateRequest eventUpdateRequest) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/events/${eventUpdateRequest.id}'),
        headers: await getHeaders(),
        body: json.encode(eventUpdateRequest.toJson()),
      );
      if (response.statusCode == 200) {
        return EventResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update event: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }
  
  Future<void> deleteEvent(int eventId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: await getHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete event: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}