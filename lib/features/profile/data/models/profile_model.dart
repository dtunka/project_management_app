class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String? profilePicture; // New field for profile picture URL
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? true,
      profilePicture: json['profilePicture'] ?? json['avatar'] ?? json['profileImage'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      if (profilePicture != null) 'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // For update request (PATCH)
  Map<String, dynamic> toUpdateJson({
    String? name,
    String? email,
    String? password,
    String? profilePicture,
  }) {
    final Map<String, dynamic> data = {};
    if (name != null && name.isNotEmpty) data['name'] = name;
    if (email != null && email.isNotEmpty) data['email'] = email;
    if (password != null && password.isNotEmpty) data['password'] = password;
    if (profilePicture != null && profilePicture.isNotEmpty) data['profilePicture'] = profilePicture;
    return data;
  }
}