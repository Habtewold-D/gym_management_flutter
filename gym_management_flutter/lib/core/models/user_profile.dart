class UserProfile {
  final int id;
  final String name;
  final String email;
  final int? age;
  final double? height;
  final double? weight;
  final double? bmi;
  final String role;
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.height,
    this.weight,
    this.bmi,
    this.role = "user"
  });
}
