import 'package:flutter/material.dart'; // Add this for Colors

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final TeamInfo team;
  final ManagerInfo manager;
  final DateTime startDate;
  final DateTime deadline;
  final String status;
  final int progress;
  final List<Contributor> contributors;
  // task statistics
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;
  final int overdueTasks;
  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.team,
    required this.manager,
    required this.startDate,
    required this.deadline,
    required this.status,
    required this.progress,
    required this.contributors,
    //======================
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.pendingTasks,
    required this.overdueTasks,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final tasks = json['tasks'] ?? {};
    return ProjectModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      team: TeamInfo.fromJson(json['team'] ?? {}),
      manager: ManagerInfo.fromJson(json['manager'] ?? {}),
      startDate: DateTime.parse(
        json['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      deadline: DateTime.parse(
        json['deadline'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'unknown',
      progress: json['progress'] ?? 0,
      contributors: (json['contributors'] as List? ?? [])
          .map((c) => Contributor.fromJson(c))
          .toList(),
      //======================
      totalTasks: tasks['total'] ?? json['totalTasks'] ?? 0,
      completedTasks: tasks['completed'] ?? json['completedTasks'] ?? 0,
      inProgressTasks: tasks['inProgress'] ?? json['inProgressTasks'] ?? 0,
      pendingTasks: tasks['pending'] ?? json['pendingTasks'] ?? 0,
      overdueTasks: tasks['overdue'] ?? json['overdueTasks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'team': team.toJson(),
      'manager': manager.toJson(),
      'startDate': startDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'status': status,
      'progress': progress,
      'contributors': contributors.map((c) => c.toJson()).toList(),
    };
  }

  // Helper getters for UI
  String get formattedStartDate {
    return _formatDate(startDate);
  }

  String get formattedDeadline {
    return _formatDate(deadline);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class TeamInfo {
  final String id;
  final String name;
  final List<dynamic> members;

  TeamInfo({required this.id, required this.name, required this.members});

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      members: json['members'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'members': members};
  }
}

class ManagerInfo {
  final String id;
  final String name;
  final String email;

  ManagerInfo({required this.id, required this.name, required this.email});

  factory ManagerInfo.fromJson(Map<String, dynamic> json) {
    return ManagerInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'email': email};
  }
}

class Contributor {
  final String id;
  final String name;
  final String email;

  Contributor({required this.id, required this.name, required this.email});

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'email': email};
  }
}
