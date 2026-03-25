import 'package:flutter/material.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../../core/networks/token_manager.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardRepository repository;

  DashboardProvider({required this.repository});

  DashboardModel? _dashboard;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      _dashboard = await repository.getDashboardStats(token);
      print("Dashboard loaded: ${_dashboard?.totalProjects} projects");
    } catch (e) {
      _errorMessage = e.toString();
      print("Dashboard Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}