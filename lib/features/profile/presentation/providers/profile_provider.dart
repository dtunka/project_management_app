import 'package:flutter/material.dart';
import 'package:project_management_app/features/profile/data/repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';
import '../../../../core/networks/api_exception.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository repository;

  ProfileProvider({required this.repository});

  ProfileModel? _profile;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
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

  // Update user profile
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? password,
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