import 'package:flutter/foundation.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/event.dart';
import '../../domain/models/member.dart';
import '../../domain/models/progress.dart';
import '../../data/services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService;
  List<Workout> _workouts = [];
  List<Event> _events = [];
  List<Member> _members = [];
  List<Progress> _progress = [];
  bool _isLoading = false;
  String? _error;

  AdminProvider(this._adminService);

  List<Workout> get workouts => _workouts;
  List<Event> get events => _events;
  List<Member> get members => _members;
  List<Progress> get progress => _progress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkouts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workouts = await _adminService.getWorkouts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _adminService.getEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await _adminService.getMembers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProgress() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _progress = await _adminService.getProgress();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createWorkout(Workout workout) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newWorkout = await _adminService.createWorkout(workout);
      _workouts.add(newWorkout);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEvent = await _adminService.createEvent(event);
      _events.add(newEvent);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteWorkout(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteWorkout(id);
      _workouts.removeWhere((workout) => workout.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEvent(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteEvent(id);
      _events.removeWhere((event) => event.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 