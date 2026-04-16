import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../../../core/networks/api_exception.dart';

class UserProvider with ChangeNotifier {
  final UserRepository repository;

  UserProvider({required this.repository});

  List<UserModel> _users = [];
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentUserRole = 'member';
  String _currentUserId = '';

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentUserRole => _currentUserRole;

  // Set user info when logging in
  void setUserInfo(String userId, String role) {
    _currentUserId = userId;
    _currentUserRole = role.toLowerCase();
    notifyListeners();
  }

  // Fetch users based on user role
  Future<void> fetchUsers() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Always fetch all users from API
      _allUsers = await repository.getUsers();
      print('Fetched ${_allUsers.length} total users');
      
      // Filter based on user role
      _filterUsersByRole();
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
      _errorMessage = 'Failed to load users. Please try again.';
      print('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filter users based on user role
  void _filterUsersByRole() {
    switch (_currentUserRole) {
      case 'admin':
        // Admin sees all users
        _users = List.from(_allUsers);
        print('Admin sees ${_users.length} users');
        break;
      case 'manager':
        // Manager sees only users with 'member' role
        _users = _allUsers.where((user) 
          => user.role.toLowerCase() == 'member'
        ).toList();
        print('Manager sees ${_users.length} users (members only)');
        break;
      case 'member':
        // Member sees no users (or could see themselves)
        _users = [];
        print('Member sees no users');
        break;
      default:
        _users = [];
    }
    notifyListeners();
  }

  // Check if user can create new users
  bool get canCreateUser {
    return _currentUserRole == 'admin';
  }

  // Check if user can edit a specific user
  bool canEditUser(UserModel user) {
    return _currentUserRole == 'admin';
  }

  // Check if user can delete a specific user
  bool canDeleteUser(UserModel user) {
    return _currentUserRole == 'admin';
  }

  // Check if user can view the users page
  bool get canViewUsers {
    return _currentUserRole == 'admin' || _currentUserRole == 'manager';
  }

  Future<bool> deleteUser(String userId) async {
    if (!canDeleteUser(UserModel(id: userId, name: '', email: '', role: ''))) {
      _errorMessage = 'You do not have permission to delete users';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.deleteUser(userId);
      
      // Remove user from local lists
      _allUsers.removeWhere((user) => user.id == userId);
      _filterUsersByRole();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Failed to delete user: $e";
      debugPrint("Delete User Error: $e");
      _setLoading(false);
      return false;
    }
  }

  Future<UserModel?> updateUser(String userId, Map<String, dynamic> updateData) async {
    if (!canEditUser(UserModel(id: userId, name: '', email: '', role: ''))) {
      _errorMessage = 'You do not have permission to edit users';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedUser = await repository.updateUser(userId, updateData);
      
      // Update user in local lists
      final index = _allUsers.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _allUsers[index] = updatedUser;
      }
      
      _filterUsersByRole();
      
      _setLoading(false);
      return updatedUser;
    } catch (e) {
      _errorMessage = "Failed to update user: $e";
      debugPrint("Update User Error: $e");
      _setLoading(false);
      return null;
    }
  }

  Future<UserModel?> createUser(Map<String, dynamic> userData) async {
    if (!canCreateUser) {
      _errorMessage = 'You do not have permission to create users';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final newUser = await repository.createUser(userData);
      
      // Add new user to local lists
      _allUsers.add(newUser);
      _filterUsersByRole();
      
      _setLoading(false);
      return newUser;
    } catch (e) {
      _errorMessage = "Failed to create user: $e";
      debugPrint("Create User Error: $e");
      _setLoading(false);
      return null;
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