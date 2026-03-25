import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
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

      final response = await apiClient.get(
        'users/me',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Get profile response: $response');

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
    String? profilePicture,
  }) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final updateData = <String, dynamic>{};
      if (name != null && name.isNotEmpty) updateData['name'] = name;
      if (email != null && email.isNotEmpty) updateData['email'] = email;
      if (password != null && password.isNotEmpty) updateData['password'] = password;
      if (profilePicture != null && profilePicture.isNotEmpty) updateData['profilePicture'] = profilePicture;

      final response = await apiClient.patch(
        'users/$userId',
        body: updateData,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Update profile response: $response');

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

  // Upload profile picture - Web compatible
  Future<String> uploadProfilePicture(Uint8List imageBytes, String fileName) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      // Create multipart request for file upload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiClient.baseUrl}/upload/profile'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Create multipart file from bytes
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload response status: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Extract the file URL from response
        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is Map<String, dynamic>) {
            return data['url'] ?? data['fileUrl'] ?? data['path'] ?? '';
          } else if (data is String) {
            return data;
          }
        } else if (responseData.containsKey('url')) {
          return responseData['url'];
        } else if (responseData.containsKey('fileUrl')) {
          return responseData['fileUrl'];
        }
        
        return responseData['message'] ?? '';
      } else {
        throw ApiException('Failed to upload image: ${response.statusCode}');
      }
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in uploadProfilePicture: $e');
      throw ApiException('Failed to upload profile picture: ${e.toString()}');
    }
  }
}