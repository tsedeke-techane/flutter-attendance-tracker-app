enum UserRole {
  student,
  teacher,
}

class User {
  final String id;
  final String name;
  final String email;
  final String ID;
  final UserRole role;
  final int? overallStats;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.ID,
    this.overallStats
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      ID: json['ID'], // Handle optional field
      role: json['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
      overallStats: json['overallStats'] != null ? json['overallStats'] : null,
    );
  }
}
