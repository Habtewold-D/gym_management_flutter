// WorkoutRequest model
class WorkoutRequest {
  final String eventTitle;
  final int sets;
  final int repsOrSecs;
  final int restTime;
  final String? imageUri;
  final bool isCompleted;
  final int userId;

  WorkoutRequest({
    required this.eventTitle,
    required this.sets,
    required this.repsOrSecs,
    required this.restTime,
    this.imageUri,
    this.isCompleted = false,
    required this.userId,
  });

  factory WorkoutRequest.fromJson(Map<String, dynamic> json) {
    return WorkoutRequest(
      eventTitle: json['eventTitle'] as String,
      sets: json['sets'] as int,
      repsOrSecs: json['repsOrSecs'] as int,
      restTime: json['restTime'] as int,
      imageUri: json['imageUri'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventTitle': eventTitle,
      'sets': sets,
      'repsOrSecs': repsOrSecs,
      'restTime': restTime,
      'imageUri': imageUri,
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }
}

// WorkoutUpdateRequest model
class WorkoutUpdateRequest {
  final int id;
  final String? eventTitle;
  final int? sets;
  final int? repsOrSecs;
  final int? restTime;
  final String? imageUri; // Added field
  final int? userId;

  WorkoutUpdateRequest({
    required this.id,
    this.eventTitle,
    this.sets,
    this.repsOrSecs,
    this.restTime,
    this.imageUri, // Added to constructor
    this.userId,
  });

  factory WorkoutUpdateRequest.fromJson(Map<String, dynamic> json) {
    return WorkoutUpdateRequest(
      id: json['id'] as int,
      eventTitle: json['eventTitle'] as String?,
      sets: json['sets'] as int?,
      repsOrSecs: json['repsOrSecs'] as int?,
      restTime: json['restTime'] as int?,
      imageUri: json['imageUri'] as String?, // Added fromJson
      userId: json['userId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      // Always include imageUri so it can be explicitly set to null by the backend.
      // Other fields are conditionally added to avoid overwriting them with null if not provided.
      'imageUri': imageUri, 
    };
    if (eventTitle != null) data['eventTitle'] = eventTitle;
    if (sets != null) data['sets'] = sets;
    if (repsOrSecs != null) data['repsOrSecs'] = repsOrSecs;
    if (restTime != null) data['restTime'] = restTime;
    if (userId != null) data['userId'] = userId;
    return data;
  }
}

// WorkoutResponse model
class WorkoutResponse {
  final int id;
  final String eventTitle;
  final int sets;
  final int repsOrSecs;
  final int restTime;
  final String? imageUri;
  final bool isCompleted;
  final String createdAt;
  final String updatedAt;
  final int userId;
  final String? notes; // added optional notes field

  WorkoutResponse({
    required this.id,
    required this.eventTitle,
    required this.sets,
    required this.repsOrSecs,
    required this.restTime,
    this.imageUri,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.notes, // added parameter
  });

  factory WorkoutResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutResponse(
      id: json['id'] as int,
      eventTitle: json['eventTitle'] as String,
      sets: json['sets'] as int,
      repsOrSecs: json['repsOrSecs'] as int,
      restTime: json['restTime'] as int,
      imageUri: json['imageUri'] as String?,
      isCompleted: json['isCompleted'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      userId: json['userId'] as int,
      notes: json['notes'] as String?, // added assignment
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventTitle': eventTitle,
      'sets': sets,
      'repsOrSecs': repsOrSecs,
      'restTime': restTime,
      'imageUri': imageUri,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'notes': notes, // added key
    };
  }
}

// WorkoutStatsResponse model
class WorkoutStatsResponse {
  final int totalWorkouts;
  final int completedWorkouts;
  final double averageSets;
  final double averageReps;

  WorkoutStatsResponse({
    required this.totalWorkouts,
    required this.completedWorkouts,
    required this.averageSets,
    required this.averageReps,
  });

  factory WorkoutStatsResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutStatsResponse(
      totalWorkouts: json['totalWorkouts'] as int,
      completedWorkouts: json['completedWorkouts'] as int,
      averageSets: (json['averageSets'] as num).toDouble(),
      averageReps: (json['averageReps'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWorkouts': totalWorkouts,
      'completedWorkouts': completedWorkouts,
      'averageSets': averageSets,
      'averageReps': averageReps,
    };
  }
}

// UserProgressResponse model
class UserProgressResponse {
  final int userId;
  final String name;
  final String email;
  final int totalWorkouts;
  final int completedWorkouts;
  final int progressPercentage;

  UserProgressResponse({
    required this.userId,
    required this.name,
    required this.email,
    required this.totalWorkouts,
    required this.completedWorkouts,
    required this.progressPercentage,
  });

  factory UserProgressResponse.fromJson(Map<String, dynamic> json) {
    return UserProgressResponse(
      userId: json['userId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      totalWorkouts: json['totalWorkouts'] as int,
      completedWorkouts: json['completedWorkouts'] as int,
      progressPercentage: json['progressPercentage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'totalWorkouts': totalWorkouts,
      'completedWorkouts': completedWorkouts,
      'progressPercentage': progressPercentage,
    };
  }
}
