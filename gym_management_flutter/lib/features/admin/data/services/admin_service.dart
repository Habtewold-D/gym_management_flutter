import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/workout.dart';
import '../../domain/models/event.dart';
import '../../domain/models/member.dart';
import '../../domain/models/progress.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminService {
  final String baseUrl;
  final AuthProvider authProvider;

  AdminService(this.baseUrl, this.authProvider);

  Future<List<Workout>> getWorkouts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/workouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Workout.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load workouts');
    }
  }

  Future<List<Event>> getEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<Member>> getMembers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Member.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load members');
    }
  }

  Future<List<Progress>> getProgress() async {
    final response = await http.get(
      Uri.parse('$baseUrl/workouts/users/all-progress'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Progress.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load progress');
    }
  }

  Future<Workout> createWorkout(Workout workout) async {
    final response = await http.post(
      Uri.parse('$baseUrl/workouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.accessToken}',
      },
      body: json.encode(workout.toJson()),
    );

    if (response.statusCode == 201) {
      return Workout.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create workout');
    }
  }

  Future<Event> createEvent(Event event) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.accessToken}',
      },
      body: json.encode(event.toJson()),
    );

    if (response.statusCode == 201) {
      return Event.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create event');
    }
  }

  Future<void> deleteWorkout(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/workouts/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete workout');
    }
  }

  Future<void> deleteEvent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }
} 