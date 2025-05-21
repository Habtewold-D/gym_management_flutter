class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? age;
  final double? height;
  final double? weight;
  final double? bmi;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.age,
    this.height,
    this.weight,
    this.bmi,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      age: json['age'] as int?,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'age': age,
      'height': height,
      'weight': weight,
      'bmi': bmi,
    };
  }
} 