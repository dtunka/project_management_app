class UserModel {
  final String id;
  final String name;
  final String email;
  final String? password; // Optional for updates
  final String role;
  final List<String>? projects;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
    this.projects,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
      projects: json['projects'] != null 
          ? List<String>.from(json['projects']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (password != null) 'password': password,
      if (projects != null) 'projects': projects,
    };
  }

  // For update requests (PATCH)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (password != null && password!.isNotEmpty) 'password': password,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    List<String>? projects,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      projects: projects ?? this.projects,
    );
  }
}