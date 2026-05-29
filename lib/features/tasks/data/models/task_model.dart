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
    // Helper function to safely get string value
    String getString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is num) return value.toString();
      return '';
    }
    
    // Helper function to safely get project ID
    String getProjectId(dynamic projectData) {
      if (projectData == null) return '';
      if (projectData is String) return projectData;
      if (projectData is Map) {
        return getString(projectData['_id'] ?? projectData['id']);
      }
      return '';
    }
    
    // Helper function to safely get project name
    String getProjectName(dynamic projectData) {
      if (projectData == null) return '';
      if (projectData is Map) {
        return getString(projectData['name']);
      }
      return '';
    }
    
    // Helper function to safely parse date
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      try {
        return DateTime.parse(dateValue.toString());
      } catch (e) {
        return DateTime.now();
      }
    }
    
    // Helper function to get assignees - handles both 'assignees' and 'assignedTo'
    List<Assignee> getAssignees(Map<String, dynamic> json) {
      List<Assignee> result = [];
      
      // Try 'assignees' field first
      var assigneesData = json['assignees'];
      
      // If not found, try 'assignedTo' field
      if (assigneesData == null) {
        assigneesData = json['assignedTo'];
      }
      
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

    return TaskModel(
      id: getString(json['_id'] ?? json['id']),
      title: getString(json['title']),
      description: getString(json['description']),
      status: getString(json['status']),
      priority: getString(json['priority']),
      projectId: getProjectId(json['project'] ?? json['projectId']),
      projectName: getProjectName(json['project'] ?? json['projectName']),
      assignees: getAssignees(json),
      deadline: parseDate(json['deadline']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      comments: (json['comments'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((c) => Comment.fromJson(c))
          .toList(),
      progress: json['percentageComplete'] ?? json['progress'] ?? 0,
    );
  }

  // ... rest of your TaskModel methods (toJson, toCreateJson, etc.)
  
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