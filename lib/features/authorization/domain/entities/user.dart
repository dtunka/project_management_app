class User {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.createdAt,
    this.updatedAt,
  });
}
