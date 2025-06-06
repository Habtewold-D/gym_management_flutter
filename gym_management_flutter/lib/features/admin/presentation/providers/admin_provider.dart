import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/progress_model.dart';
import 'package:gym_management_flutter/core/models/workout_models.dart';
import 'package:gym_management_flutter/core/models/event_model.dart';
import 'package:gym_management_flutter/core/models/member_model.dart';
import 'package:gym_management_flutter/core/services/admin_service.dart';

// Use the updated parameterless AdminService()
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService;
  
  List<WorkoutResponse> _workouts = [];
  List<EventResponse> _events = [];
  List<Member> _members = [];
  List<TraineeProgress> _progress = [];
  bool _isLoading = false;
  String? _error;
  
  String? _successMessage;
  String? _validationError;
  
  List<WorkoutResponse> get workouts => _workouts;
  List<EventResponse> get events => _events;
  List<Member> get members => _members;
  List<TraineeProgress> get progress => _progress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? get successMessage => _successMessage;
  void setSuccessMessage(String? message) {
    _successMessage = message;
    notifyListeners();
  }
  String? get validationError => _validationError;
  void setValidationError(String message) {
    _validationError = message;
    notifyListeners();
  }
  
  AdminProvider(this._adminService);
  
  Future<void> loadWorkouts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _workouts = await _adminService.getWorkouts();
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEvents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _events = await _adminService.getEvents();
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMembers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _members = await _adminService.getMembers();
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadProgress() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _progress = await _adminService.getProgress();
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> createWorkout(WorkoutRequest workoutRequest) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final newWorkout = await _adminService.createWorkout(workoutRequest);
      _workouts = [..._workouts, newWorkout];
      setSuccessMessage('Workout created successfully');
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateWorkout(WorkoutUpdateRequest workoutUpdateRequest) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final updatedWorkout = await _adminService.updateWorkout(workoutUpdateRequest);
      _workouts = _workouts.map((w) => w.id == updatedWorkout.id ? updatedWorkout : w).toList();
      setSuccessMessage('Workout updated successfully');
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteWorkout(int workoutId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _adminService.deleteWorkout(workoutId);
      _workouts.removeWhere((w) => w.id == workoutId);
      setSuccessMessage('Workout deleted successfully');
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> createEvent(EventRequest eventRequest) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final newEvent = await _adminService.createEvent(eventRequest);
      _events = [..._events, newEvent];
      setSuccessMessage('Event created successfully');
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateEvent(EventUpdateRequest eventUpdateRequest) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final updatedEvent = await _adminService.updateEvent(eventUpdateRequest);
      _events = _events.map((e) => e.id == updatedEvent.id ? updatedEvent : e).toList();
      setSuccessMessage('Event updated successfully');
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteEvent(int eventId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _adminService.deleteEvent(eventId);
      _events.removeWhere((e) => e.id == eventId);
      setSuccessMessage('Event deleted successfully');
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteMember(Member member) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _members.remove(member);
      setSuccessMessage('Member deleted successfully');
    } catch (e) {
      _error = e.toString();
      if (e.toString().contains('No authentication token found') || e.toString().contains('401')) {
        _error = 'Please login again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

final adminProvider = ChangeNotifierProvider<AdminProvider>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminProvider(adminService);
});