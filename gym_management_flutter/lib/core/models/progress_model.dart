// Updated to mirror TraineeProgress.kt from Jetpack Compose

class TraineeProgress {
  final int userId;
  final String name;
  final String email;
  final int completedWorkouts;
  final int totalWorkouts;
  final int progressPercentage;
  
  TraineeProgress({
    required this.userId,
    required this.name,
    required this.email,
    required this.completedWorkouts,
    required this.totalWorkouts,
    required this.progressPercentage,
  });
  
  factory TraineeProgress.fromJson(Map<String, dynamic> json) {
    return TraineeProgress(
      userId: json['userId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      completedWorkouts: json['completedWorkouts'] as int,
      totalWorkouts: json['totalWorkouts'] as int,
      progressPercentage: json['progressPercentage'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'completedWorkouts': completedWorkouts,
      'totalWorkouts': totalWorkouts,
      'progressPercentage': progressPercentage,
    };
  }
}