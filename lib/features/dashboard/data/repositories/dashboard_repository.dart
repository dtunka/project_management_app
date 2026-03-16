import '../../../../core/networks/api_client.dart';

import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient apiClient;

  DashboardRepository({required this.apiClient});

  Future<DashboardModel> getDashboardStats(String token) async {
    try {
      final response = await apiClient.get(
        'reports/dashboard',
        headers: {"Authorization": "Bearer $token"},
      );

      //print("Dashboard API Response: $response");

      return DashboardModel.fromJson(response['data']);
    } catch (e) {
      print("Dashboard API Error: $e");
      rethrow;
    }
  }
} 
