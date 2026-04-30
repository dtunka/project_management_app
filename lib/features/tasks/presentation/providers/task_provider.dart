import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../../../core/networks/api_exception.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository repository;
  TaskProvider({required this.repository});

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;
  int? _expandedIndex;
  String _statusFilter = 'all';
  String _currentUserId = '';
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  int? get expandedIndex => _expandedIndex;
  String get statusFilter => _statusFilter;


  // Fetch all tasks
  Future<void> fetchTasks() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _tasks = await repository.getAllTasks();
      print('Fetched ${_tasks.length} tasks');
    } on UnauthorizedException catch (e) {
      _errorMessage = 'Session expired. Please login again.';
      print('Unauthorized: $e');
    } on ServerException catch (e) {
      _errorMessage = 'Server error. Please try again later.';
      print('Server error: $e');
    } on ApiException catch (e) {
      _errorMessage = e.message;
      print('API error: $e');
    } catch (e) {
      _errorMessage = 'Failed to load tasks. Please try again.';
      print('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filter tasks by status
  List<TaskModel> getFilteredTasks() {
    if (_statusFilter == 'all') {
      return _tasks;
    }
    return _tasks.where((task) => task.status == _statusFilter).toList();
  }

  // Set status filter
  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  // Create new task
  Future<TaskModel?> createTask(Map<String, dynamic> taskData) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final newTask = await repository.createTask(taskData);
      _tasks.add(newTask);
      _setLoading(false);
      return newTask;
    } catch (e) {
      _errorMessage = 'Failed to create task: ${e.toString()}';
      print('Error creating task: $e');
      _setLoading(false);
      return null;
    }
  }

  // Update task
  Future<TaskModel?> updateTask(String taskId, Map<String, dynamic> updateData) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await repository.updateTask(taskId, updateData);
      
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      
      _isUpdating = false;
      notifyListeners();
      return updatedTask;
    } catch (e) {
      _errorMessage = 'Failed to update task: ${e.toString()}';
      print('Error updating task: $e');
      _isUpdating = false;
      notifyListeners();
      return null;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteTask(taskId);
      
      _tasks.removeWhere((t) => t.id == taskId);
      
      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete task: ${e.toString()}';
      print('Error deleting task: $e');
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  // Add comment to task
  Future<Comment?> addComment(String taskId, String text, {List<String>? attachments}) async {
    try {
      final newComment = await repository.addComment(taskId, text, attachments: attachments);
      
      // Update task with new comment
      final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        final updatedComments = List<Comment>.from(_tasks[taskIndex].comments)..add(newComment);
        _tasks[taskIndex] = TaskModel(
          id: _tasks[taskIndex].id,
          title: _tasks[taskIndex].title,
          description: _tasks[taskIndex].description,
          status: _tasks[taskIndex].status,
          priority: _tasks[taskIndex].priority,
          projectId: _tasks[taskIndex].projectId,
          projectName: _tasks[taskIndex].projectName,
          assignees: _tasks[taskIndex].assignees,
          deadline: _tasks[taskIndex].deadline,
          createdAt: _tasks[taskIndex].createdAt,
          updatedAt: _tasks[taskIndex].updatedAt,
          comments: updatedComments,
          progress: _tasks[taskIndex].progress,
        );
      }
      
      notifyListeners();
      return newComment;
    } catch (e) {
      _errorMessage = 'Failed to add comment: ${e.toString()}';
      print('Error adding comment: $e');
      notifyListeners();
      return null;
    }
  }
  void setCurrentUser(String userId) {
  _currentUserId = userId;
}
 
 // Get tasks assigned to current user (for member view)
Future<void> fetchMyTasks() async {
  _setLoading(true);
  _errorMessage = null;

  try {
    final allTasks = await repository.getAllTasks();
    // Filter tasks where current user is an assignee
    _tasks = allTasks.where((task) => 
      task.assignees.any((assignee) => assignee.id == _currentUserId)
    ).toList();
    print('Fetched ${_tasks.length} tasks for member');
  } catch (e) {
    _errorMessage = 'Failed to load tasks: ${e.toString()}';
    print('Error fetching member tasks: $e');
  } finally {
    _setLoading(false);
  }
}
  void toggleExpand(int index) {
    if (_expandedIndex == index) {
      _expandedIndex = null;
    } else {
      _expandedIndex = index;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}