import 'package:flutter/material.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectRepository repository;

  ProjectProvider({required this.repository});

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _expandedIndex; // Track which project is expanded

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get expandedIndex => _expandedIndex;

  Future<void> fetchProjects() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _projects = await repository.getAllProjects();
      print('Fetched ${_projects.length} projects');
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching projects: $e');
    } finally {
      _setLoading(false);
    }
  }

  void toggleExpand(int index) {
    if (_expandedIndex == index) {
      _expandedIndex = null; // Collapse if same index
    } else {
      _expandedIndex = index; // Expand new index
    }
    notifyListeners();
  }

  void collapseAll() {
    _expandedIndex = null;
    notifyListeners();
  }

  // Get projects by status
  List<ProjectModel> getProjectsByStatus(String status) {
    return _projects.where((p) => p.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Get projects by manager
  List<ProjectModel> getProjectsByManager(String managerId) {
    return _projects.where((p) => p.manager.id == managerId).toList();
  }

  // Search projects by name
  List<ProjectModel> searchProjects(String query) {
    if (query.isEmpty) return _projects;
    return _projects.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) ||
      p.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
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