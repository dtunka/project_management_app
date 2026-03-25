import 'package:flutter/material.dart';
import 'package:project_management_app/features/authorization/domain/entities/user.dart';
import '../../data/repositories/auth_repo_impl.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepositoryImpl authRepository;
  
  AuthProvider(this.authRepository);

  User? _user; // Change to User? (from domain)
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRegistered = false;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRegistered => _isRegistered;
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await authRepository.login(email, password);
      _user = user; // Now this works because both are User type
      _isLoading = false;
      notifyListeners();
      
      print('Login successful: ${user.name} - Role: ${user.role}');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
      _isRegistered = false; 
    notifyListeners();

    try {
      final user = await authRepository.register(email, password, role);
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}