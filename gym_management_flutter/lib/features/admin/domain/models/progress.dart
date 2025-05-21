class Progress {
  final int userId;
  final String name;
  final String email;
  final int totalWorkouts;
  final int completedWorkouts;
  final int progressPercentage;

  Progress({
    required this.userId,
    required this.name,
    required this.email,
    required this.totalWorkouts,
    required this.completedWorkouts,
    required this.progressPercentage,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
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