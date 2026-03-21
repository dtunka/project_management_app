import './team_memeber_model.dart';
class TeamModel {
  final String id;
  final String name;
  final String description;
  final String? manager;
  final List<TeamMember> members;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeamModel({
    required this.id,
    required this.name,
    required this.description,
    this.manager,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      manager: json['manager'],
      members: (json['members'] as List? ?? [])
          .map((m) => TeamMember.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      if (manager != null) 'manager': manager,
      'members': members.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'description': description,
      'members': members.map((m) => m.id).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  int get memberCount => members.length;
}