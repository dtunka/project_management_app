import 'package:flutter/material.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';
import '../../../../core/networks/api_exception.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectRepository repository;

  ProjectProvider({required this.repository});

  List<ProjectModel> _projects = [];
  List<ProjectModel> _allProjects = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _expandedIndex;
  String _currentUserRole = 'member';
  String _currentUserId = '';

  List<ProjectModel> get projects => _projects;
  List<ProjectModel> get allProjects => _allProjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get expandedIndex => _expandedIndex;
  String get currentUserRole => _currentUserRole;
  String get currentUserId => _currentUserId;

  // Set user info when logging in
  void setUserInfo(String userId, String role) {
    print('=== SETTING USER INFO ===');
    print('User ID: $userId');
    print('User Role: $role');
    _currentUserId = userId;
    _currentUserRole = role.toLowerCase();
    notifyListeners();
  }

  // Fetch projects based on user role
  Future<void> fetchProjects() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      print('=== FETCHING PROJECTS ===');
      print('User Role: $_currentUserRole');
      print('User ID: $_currentUserId');
      
      if (_currentUserRole == 'manager') {
        // Use manager-specific endpoint
        print('Fetching projects for manager with ID: $_currentUserId');
        _allProjects = await repository.getProjectsByManager(_currentUserId);
        print('Fetched ${_allProjects.length} projects for manager');
      } else {
        // Use all projects endpoint for admin
        print('Fetching all projects for admin');
        _allProjects = await repository.getAllProjects();
        print('Fetched ${_allProjects.length} total projects');
      }
      
      _filterProjectsByRole();
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
      _errorMessage = 'Failed to load projects. Please try again.';
      print('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filter projects based on user role
  void _filterProjectsByRole() {
    print('=== FILTERING PROJECTS BY ROLE ===');
    print('Current user role: $_currentUserRole');
    print('Current user ID: $_currentUserId');
    print('Total all projects: ${_allProjects.length}');
    
    switch (_currentUserRole) {
      case 'admin':
        _projects = List.from(_allProjects);
        print('Admin sees ${_projects.length} projects');
        break;
      case 'manager':
        // Manager sees projects where they are the manager
        _projects = _allProjects.where((project) {
          print('Comparing: Project Manager ID: ${project.manager.id} vs Current User ID: $_currentUserId');
          return project.manager.id == _currentUserId;
        }).toList();
        print('Manager sees ${_projects.length} projects (managed by them)');
        break;
      case 'member':
        _projects = _allProjects.where((project) 
          => project.contributors.any((contributor) => contributor.id == _currentUserId)
        ).toList();
        print('Member sees ${_projects.length} projects (they contribute to)');
        break;
      default:
        _projects = [];
    }
    notifyListeners();
  }

  // Get projects due within a specific number of days
  List<ProjectModel> getProjectsDueWithinDays(int days) {
    final now = DateTime.now();
    final deadline = now.add(Duration(days: days));
    
    return _projects.where((project) {
      if (project.status == 'completed' || project.status == 'cancelled') {
        return false;
      }
      return project.deadline.isAfter(now) && 
             project.deadline.isBefore(deadline);
    }).toList();
  }

  // Get overdue projects
  List<ProjectModel> getOverdueProjects() {
    final now = DateTime.now();
    return _projects.where((project) {
      if (project.status == 'completed' || project.status == 'cancelled') {
        return false;
      }
      return project.deadline.isBefore(now);
    }).toList();
  }

  // Get projects by status
  List<ProjectModel> getProjectsByStatus(String status) {
    return _projects.where((p) => p.status == status).toList();
  }

  // Get project statistics
  Map<String, dynamic> getProjectStatistics() {
    final totalProjects = _projects.length;
    final completedProjects = _projects.where((p) => p.status == 'completed').length;
    final inProgressProjects = _projects.where((p) => p.status == 'in_progress').length;
    final onHoldProjects = _projects.where((p) => p.status == 'on_hold').length;
    final cancelledProjects = _projects.where((p) => p.status == 'cancelled').length;
    
    // Calculate total tasks
    int totalTasks = 0;
    int completedTasks = 0;
    int inProgressTasks = 0;
    int overdueTasks = 0;
    
    for (var project in _projects) {
      totalTasks += project.totalTasks;
      completedTasks += project.completedTasks;
      inProgressTasks += project.inProgressTasks;
      overdueTasks += project.overdueTasks;
    }
    
    final completionRate = totalTasks > 0 
        ? (completedTasks / totalTasks * 100).round() 
        : 0;
    
    return {
      'totalProjects': totalProjects,
      'completedProjects': completedProjects,
      'inProgressProjects': inProgressProjects,
      'onHoldProjects': onHoldProjects,
      'cancelledProjects': cancelledProjects,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'inProgressTasks': inProgressTasks,
      'overdueTasks': overdueTasks,
      'completionRate': completionRate,
    };
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