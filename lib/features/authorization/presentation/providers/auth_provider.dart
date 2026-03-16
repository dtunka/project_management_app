import 'package:flutter/material.dart';
import '../../data/repositories/auth_repo_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider(this.repository);

  User? user;
  bool isLoading = false;
  bool userRegistered = false;
  String? error;
 
  Future<void> login(String email, String password) async {
    isLoading = true;
    error = null;
    print("login page");
    notifyListeners();
    print("login page is loaded");
    try {
      user = await repository.login(email, password);
    } catch (e) {
      error = e.toString();
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> register(String email, String password, String role) async {
    isLoading = true;
    error = null;
    userRegistered = false;
    notifyListeners();

    try {
      user = await repository.register(email, password, role);
      userRegistered = true;
    } catch (e) {
      error = e.toString();
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }
}
