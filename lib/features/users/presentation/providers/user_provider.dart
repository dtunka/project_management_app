import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository repository;

  UserProvider({required this.repository});

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await repository.getUsers();
      print("Fetched ${_users.length} users");
    } catch (e) {
      _errorMessage = "Failed to fetch users: $e";
      debugPrint("Fetch Users Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
 Future<UserModel?> createUser(Map<String, dynamic> userData) async {
  _isLoading = true;
  notifyListeners();

  try {
    final newUser = await repository.createUser(userData);

    // Add new user to local list
    _users.add(newUser);

    _isLoading = false;
    notifyListeners();
    return newUser;
  } catch (e) {
    _errorMessage = "Failed to create user: $e";
    debugPrint("Create User Error: $e");
    _isLoading = false;
    notifyListeners();
    return null;
  }
}
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.deleteUser(userId);

      // Remove user from local list
      _users.removeWhere((user) => user.id == userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to delete user: $e";
      debugPrint("Delete User Error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<UserModel?> updateUser(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await repository.updateUser(userId, updateData);

      // Update user in local list
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      _isLoading = false;
      notifyListeners();
      return updatedUser;
    } catch (e) {
      _errorMessage = "Failed to update user: $e";
      debugPrint("Update User Error: $e");
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
