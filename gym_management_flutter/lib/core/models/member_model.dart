// Updated Member model to mirror the Kotlin UserProfile/UserResponse definitions

class Member {
  final int id;
  final String name;
  final String email;
  final int? age;               // Optional, defaults to null
  final double? height;         // Optional, in cm
  final double? weight;         // Optional, in kg
  final double? bmi;            // Optional BMI value
  final String role;            // "admin" or "member"
  final String joinDate;
  final String membershipStatus; // defaults to "active"

  Member({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.height,
    this.weight,
    this.bmi,
    required this.role,
    required this.joinDate,
    this.membershipStatus = "active",
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] != null ? json['age'] as int : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      role: json['role'] as String,
      joinDate: json['joinDate'] as String,
      membershipStatus: json['membershipStatus'] as String? ?? "active",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'role': role,
      'joinDate': joinDate,
      'membershipStatus': membershipStatus,
    };
  }
}