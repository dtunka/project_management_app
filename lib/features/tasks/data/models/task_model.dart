import './comment_model.dart';
import 'package:flutter/material.dart'; 
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String projectId;
  final String projectName;
  final List<Assignee> assignees;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> comments;
  final int progress;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    required this.projectName,
    required this.assignees,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
    this.progress = 0,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      projectId: json['projectId'] ?? json['project']['_id'] ?? '',
      projectName: json['project']?['name'] ?? json['projectName'] ?? '',
      assignees: (json['assignees'] as List? ?? [])
          .map((a) => Assignee.fromJson(a))
          .toList(),
      deadline: DateTime.parse(json['deadline'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      comments: (json['comments'] as List? ?? [])
          .map((c) => Comment.fromJson(c))
          .toList(),
      progress: json['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'projectId': projectId,
      'assignees': assignees.map((a) => a.toJson()).toList(),
      'deadline': deadline.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'progress': progress,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'projectId': projectId,
      'assignees': assignees.map((a) => a.id).toList(),
      'deadline': deadline.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'deadline': deadline.toIso8601String(),
    };
    if (assignees.isNotEmpty) {
      data['assignees'] = assignees.map((a) => a.id).toList();
    }
    return data;
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'overdue':
        return 'Overdue';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get priorityText {
    switch (priority.toLowerCase()) {
      case 'critical':
        return 'Critical';
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return priority;
    }
  }

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class Assignee {
  final String id;
  final String name;
  final String email;

  Assignee({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Assignee.fromJson(Map<String, dynamic> json) {
    return Assignee(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
  }
}