import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/networks/api_exception.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository repository;

  ProfileProvider({required this.repository});

  ProfileModel? _profile;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isUploading = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  // Fetch user profile
  Future<void> fetchProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _profile = await repository.getProfile();
      print('Profile fetched: ${_profile?.name}');
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
      _errorMessage = 'Failed to load profile. Please try again.';
      print('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(Uint8List imageBytes, String fileName) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageUrl = await repository.uploadProfilePicture(imageBytes, fileName);
      _isUploading = false;
      notifyListeners();
      return imageUrl;
      
    } catch (e) {
      _errorMessage = 'Failed to upload profile picture: ${e.toString()}';
      print('Upload error: $e');
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  // Update user profile with picture URL
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? password,
    String? profilePicture,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProfile = await repository.updateProfile(
        userId: userId,
        name: name,
        email: email,
        password: password,
        profilePicture: profilePicture,
      );
      
      _profile = updatedProfile;
      _isUpdating = false;
      notifyListeners();
      return true;
      
    } on UnauthorizedException catch (e) {
      _errorMessage = 'Session expired. Please login again.';
      print('Unauthorized: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    } on ServerException catch (e) {
      _errorMessage = 'Server error. Please try again later.';
      print('Server error: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      print('API error: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      print('Unexpected error: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
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