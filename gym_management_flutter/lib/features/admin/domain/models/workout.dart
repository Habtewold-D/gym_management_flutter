class Workout {
  final int id;
  final String eventTitle;
  final int userId;
  final int sets;
  final int repsOrSecs;
  final int restTime;
  final String? imageUri;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workout({
    required this.id,
    required this.eventTitle,
    required this.userId,
    required this.sets,
    required this.repsOrSecs,
    required this.restTime,
    this.imageUri,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as int,
      eventTitle: json['eventTitle'] as String,
      userId: json['userId'] as int,
      sets: json['sets'] as int,
      repsOrSecs: json['repsOrSecs'] as int,
      restTime: json['restTime'] as int,
      imageUri: json['imageUri'] as String?,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventTitle': eventTitle,
      'userId': userId,
      'sets': sets,
      'repsOrSecs': repsOrSecs,
      'restTime': restTime,
      'imageUri': imageUri,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 