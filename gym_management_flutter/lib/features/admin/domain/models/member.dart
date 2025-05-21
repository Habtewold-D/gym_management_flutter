class Member {
  final int id;
  final String name;
  final String email;
  final String role;
  final int age;
  final double height;
  final double weight;
  final double bmi;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.age,
    required this.height,
    required this.weight,
    required this.bmi,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      age: json['age'] as int,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
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