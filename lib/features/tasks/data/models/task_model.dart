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
    // Safe getter for string values
    String _getString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is num) return value.toString();
      return '';
    }

    // Safe getter for project ID (handles both Map and String)
    String _getProjectId(dynamic projectData) {
      if (projectData == null) return '';
      if (projectData is String) return projectData;
      if (projectData is Map) {
        return _getString(projectData['_id'] ?? projectData['id']);
      }
      return '';
    }

    // Safe getter for project name
    String _getProjectName(dynamic projectData) {
      if (projectData == null) return '';
      if (projectData is Map) {
        return _getString(projectData['name']);
      }
      return _getString(projectData);
    }

    // Safe date parser
    DateTime _parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      try {
        return DateTime.parse(dateValue.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    // Safe assignees parser
    List<Assignee> _getAssignees(dynamic assigneesData) {
      List<Assignee> result = [];
      if (assigneesData == null) return result;
      
      if (assigneesData is List) {
        for (var item in assigneesData) {
          if (item is Map<String, dynamic>) {
            result.add(Assignee.fromJson(item));
          } else if (item is String) {
            result.add(Assignee(id: item, name: 'Unknown', email: ''));
          }
        }
      } else if (assigneesData is Map<String, dynamic>) {
        result.add(Assignee.fromJson(assigneesData));
      }
      return result;
    }

    // Get project info - try multiple possible field names
    String projectId = '';
    String projectName = '';
    
    // Try to get from 'project' field
    if (json['project'] != null) {
      projectId = _getProjectId(json['project']);
      projectName = _getProjectName(json['project']);
    }
    
    // If not found, try direct fields
    if (projectId.isEmpty && json['projectId'] != null) {
      projectId = _getString(json['projectId']);
    }
    if (projectName.isEmpty && json['projectName'] != null) {
      projectName = _getString(json['projectName']);
    }

    return TaskModel(
      id: _getString(json['_id'] ?? json['id']),
      title: _getString(json['title']),
      description: _getString(json['description']),
      status: _getString(json['status']),
      priority: _getString(json['priority']),
      projectId: projectId,
      projectName: projectName,
      assignees: _getAssignees(json['assignees']),
      deadline: _parseDate(json['deadline']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      comments: (json['comments'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((c) => Comment.fromJson(c))
          .toList(),
      progress: json['progress'] is num ? (json['progress'] as num).toInt() : 0,
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
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
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