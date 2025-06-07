class UserProfile {
  final int id;
  final String name;
  final String email;
  final int? age;
  final double? height;
  final double? weight;
  final double? bmi;
  final String role;
  final String? joinDate;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.height,
    this.weight,
    this.bmi,
    this.role = "user",
    this.joinDate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      age: json['age'] is int ? json['age'] : (json['age'] != null ? int.tryParse(json['age'].toString()) : null),
      height: json['height'] is double ? json['height'] : (json['height'] != null ? double.tryParse(json['height'].toString()) : null),
      weight: json['weight'] is double ? json['weight'] : (json['weight'] != null ? double.tryParse(json['weight'].toString()) : null),
      bmi: json['bmi'] is double ? json['bmi'] : (json['bmi'] != null ? double.tryParse(json['bmi'].toString()) : null),
      role: (json['role'] as String?) ?? 'user',
      joinDate: json['joinDate']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (age != null) 'age': age,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (bmi != null) 'bmi': bmi,
      'role': role,
      if (joinDate != null) 'joinDate': joinDate,
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    int? age,
    double? height,
    double? weight,
    double? bmi,
    String? role,
    String? joinDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      role: role ?? this.role,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}
