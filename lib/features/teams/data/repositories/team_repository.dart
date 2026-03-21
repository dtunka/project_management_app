import '../../../../core/networks/api_client.dart';
import '../../../../core/networks/token_manager.dart';
import '../../../../core/networks/api_exception.dart';
import '../models/team_model.dart';
import '../models/team_member_model.dart';

class TeamRepository {
  final ApiClient apiClient;

  TeamRepository({required this.apiClient});

  // Get all teams
  Future<List<TeamModel>> getAllTeams() async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      // Make API call
      final response = await apiClient.get(
        'teams',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Teams response: $response');

      // Extract the data array from response
      // API returns: { "success": true, "data": [...] }
      final List<dynamic> teamsData = response['data'] ?? [];

      // Convert each item to TeamModel
      return teamsData.map((json) => TeamModel.fromJson(json)).toList();
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in getAllTeams: $e');
      throw ApiException('Failed to fetch teams: ${e.toString()}');
    }
  }

  // Get team by ID
  Future<TeamModel> getTeamById(String teamId) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.get(
        'teams/$teamId',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Extract the data from response
      final Map<String, dynamic> teamData = response['data'] ?? response;
      
      return TeamModel.fromJson(teamData);
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in getTeamById: $e');
      throw ApiException('Failed to fetch team: ${e.toString()}');
    }
  }

  // Create new team
  Future<TeamModel> createTeam(Map<String, dynamic> teamData) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.post(
        'teams/create',
        body: teamData,
        headers: {'Authorization': 'Bearer $token'},
      );

      // Extract the created team from response
      final Map<String, dynamic> createdTeam = response['data'] ?? response;
      
      return TeamModel.fromJson(createdTeam);
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in createTeam: $e');
      throw ApiException('Failed to create team: ${e.toString()}');
    }
  }

  // Update team
  Future<TeamModel> updateTeam(String teamId, Map<String, dynamic> updateData) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.patch(
        'teams/$teamId',
        body: updateData,
        headers: {'Authorization': 'Bearer $token'},
      );

      // Extract the updated team from response
      final Map<String, dynamic> updatedTeam = response['data'] ?? response;
      
      return TeamModel.fromJson(updatedTeam);
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in updateTeam: $e');
      throw ApiException('Failed to update team: ${e.toString()}');
    }
  }

  // Delete team
  Future<void> deleteTeam(String teamId) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.delete(
        'teams/$teamId',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Delete team response: $response');
      
      // Check if deletion was successful
      if (response['success'] == true) {
        return;
      }
      
      throw ApiException('Failed to delete team');
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in deleteTeam: $e');
      throw ApiException('Failed to delete team: ${e.toString()}');
    }
  }

  // Add member to team
  Future<TeamModel> addMember(String teamId, String userId) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.post(
        'teams/$teamId/members/$userId',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Extract the updated team from response
      final Map<String, dynamic> updatedTeam = response['data'] ?? response;
      
      return TeamModel.fromJson(updatedTeam);
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in addMember: $e');
      throw ApiException('Failed to add member: ${e.toString()}');
    }
  }

  // Remove member from team
  Future<TeamModel> removeMember(String teamId, String userId) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.delete(
        'teams/$teamId/members/$userId',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Extract the updated team from response
      final Map<String, dynamic> updatedTeam = response['data'] ?? response;
      
      return TeamModel.fromJson(updatedTeam);
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in removeMember: $e');
      throw ApiException('Failed to remove member: ${e.toString()}');
    }
  }

  // Get all members (users with role 'member')
  Future<List<SimpleUser>> getAllMembers() async {
    try {
      final token = await TokenManager.getToken();

      final response = await apiClient.get(
        'users/role/member',
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      print('Members response: $response');

      // Extract the data array from response
      // API returns: { "success": true, "data": [...] }
      final List<dynamic> membersData = response['data'] ?? [];

      // Convert each item to SimpleUser
      return membersData.map((json) => SimpleUser.fromJson(json)).toList();
      
    } catch (e) {
      print('Error in getAllMembers: $e');
      throw ApiException('Failed to fetch members: ${e.toString()}');
    }
  }
}