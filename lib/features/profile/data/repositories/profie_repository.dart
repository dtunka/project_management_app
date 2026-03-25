import '../../../../core/networks/api_client.dart';
import '../../../../core/networks/token_manager.dart';
import '../../../../core/networks/api_exception.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository({required this.apiClient});

  // Get current user profile
  Future<ProfileModel> getProfile() async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      // Based on Postman collection: GET /api/users/{userId}
      // We need to get the current user ID from token or store it during login
      // For now, we'll use a method that gets the current user's profile
      final response = await apiClient.get(
        'users/me', // This endpoint might not exist, alternative is to store user ID
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Get profile response: $response');

      // Extract user data from response
      Map<String, dynamic> userData = {};
      
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          userData = data;
        } else {
          userData = response;
        }
      } else {
        userData = response;
      }

      return ProfileModel.fromJson(userData);
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in getProfile: $e');
      throw ApiException('Failed to fetch profile: ${e.toString()}');
    }
  }

  // Update user profile
  Future<ProfileModel> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? password,
  }) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      // Based on Postman collection: PATCH /api/users/{userId}
      final updateData = <String, dynamic>{};
      if (name != null && name.isNotEmpty) updateData['name'] = name;
      if (email != null && email.isNotEmpty) updateData['email'] = email;
      if (password != null && password.isNotEmpty) updateData['password'] = password;

      final response = await apiClient.patch(
        'users/$userId',
        body: updateData,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Update profile response: $response');

      // Extract updated user data
      Map<String, dynamic> userData = {};
      
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          userData = data;
        } else {
          userData = response;
        }
      } else {
        userData = response;
      }

      return ProfileModel.fromJson(userData);
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in updateProfile: $e');
      throw ApiException('Failed to update profile: ${e.toString()}');
    }
  }
}