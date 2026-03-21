import 'package:flutter/material.dart';
import '../../data/models/team_model.dart';
import '../../data/models/team_member_model.dart';
import '../../data/repositories/team_repository.dart';
import '../../../../core/networks/api_exception.dart';

class TeamProvider with ChangeNotifier {
  final TeamRepository repository;

  TeamProvider({required this.repository});

  List<TeamModel> _teams = [];
  List<SimpleUser> _availableMembers = [];
  bool _isLoading = false;
  bool _isMembersLoading = false;
  String? _errorMessage;
  int? _expandedIndex;

  List<TeamModel> get teams => _teams;
  List<SimpleUser> get availableMembers => _availableMembers;
  bool get isLoading => _isLoading;
  bool get isMembersLoading => _isMembersLoading;
  String? get errorMessage => _errorMessage;
  int? get expandedIndex => _expandedIndex;

  // Fetch all teams
  Future<void> fetchTeams() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _teams = await repository.getAllTeams();
      print('Fetched ${_teams.length} teams');
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
      _errorMessage = 'Failed to load teams. Please try again.';
      print('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch available members (users with role 'member')
  Future<void> fetchAvailableMembers() async {
    _isMembersLoading = true;
    notifyListeners();

    try {
      _availableMembers = await repository.getAllMembers();
      print('Fetched ${_availableMembers.length} available members');
    } catch (e) {
      print('Error fetching members: $e');
    } finally {
      _isMembersLoading = false;
      notifyListeners();
    }
  }

  // Create new team
  Future<TeamModel?> createTeam({
    required String name,
    required String description,
    required List<String> memberIds,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final teamData = {
        'name': name,
        'description': description,
        'members': memberIds,
      };

      final newTeam = await repository.createTeam(teamData);
      _teams.add(newTeam);
      _setLoading(false);
      return newTeam;
    } catch (e) {
      _errorMessage = 'Failed to create team: ${e.toString()}';
      _setLoading(false);
      return null;
    }
  }

  // Update team
  Future<TeamModel?> updateTeam({
    required String teamId,
    required String name,
    required String description,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updateData = {
        'name': name,
        'description': description,
      };

      final updatedTeam = await repository.updateTeam(teamId, updateData);
      
      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams[index] = updatedTeam;
      }
      
      _setLoading(false);
      return updatedTeam;
    } catch (e) {
      _errorMessage = 'Failed to update team: ${e.toString()}';
      _setLoading(false);
      return null;
    }
  }

  // Delete team
  Future<bool> deleteTeam(String teamId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.deleteTeam(teamId);
      _teams.removeWhere((t) => t.id == teamId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete team: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  // Add member to team
  Future<TeamModel?> addMemberToTeam(String teamId, String userId) async {
    try {
      final updatedTeam = await repository.addMember(teamId, userId);
      
      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams[index] = updatedTeam;
      }
      
      notifyListeners();
      return updatedTeam;
    } catch (e) {
      _errorMessage = 'Failed to add member: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Remove member from team
  Future<TeamModel?> removeMemberFromTeam(String teamId, String userId) async {
    try {
      final updatedTeam = await repository.removeMember(teamId, userId);
      
      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams[index] = updatedTeam;
      }
      
      notifyListeners();
      return updatedTeam;
    } catch (e) {
      _errorMessage = 'Failed to remove member: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Search teams
  List<TeamModel> searchTeams(String query) {
    if (query.isEmpty) return _teams;
    return _teams.where((team) =>
      team.name.toLowerCase().contains(query.toLowerCase()) ||
      team.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  void toggleExpand(int index) {
    if (_expandedIndex == index) {
      _expandedIndex = null;
    } else {
      _expandedIndex = index;
    }
    notifyListeners();
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