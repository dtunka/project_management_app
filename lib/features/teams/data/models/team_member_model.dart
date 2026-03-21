class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

// Simple user model for member selection
class SimpleUser {
  final String id;
  final String name;
  final String email;
  final String role;

  SimpleUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
    );
  }
}