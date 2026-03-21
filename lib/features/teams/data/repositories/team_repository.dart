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

      final response = await apiClient.get(
        'teams',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('=== TEAMS API RESPONSE DEBUG ===');
      print('Response type: ${response.runtimeType}');
      print('Response keys: ${response.keys}');
      
      List<TeamModel> teams = [];

      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          for (var teamJson in data) {
            try {
              // Convert manager from Map to String if needed
              final processedTeamJson = _processTeamJson(teamJson);
              teams.add(TeamModel.fromJson(processedTeamJson));
            } catch (e) {
              print('Error parsing team: $e');
              print('Team JSON: $teamJson');
            }
          }
        }
      }

      print('Parsed ${teams.length} teams');
      return teams;
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in getAllTeams: $e');
      throw ApiException('Failed to fetch teams: ${e.toString()}');
    }
  }

  // Helper method to process team JSON and convert manager from Map to String
  Map<String, dynamic> _processTeamJson(Map<String, dynamic> json) {
    Map<String, dynamic> processed = Map.from(json);
    
    // If manager is a Map, extract the ID
    if (processed['manager'] is Map) {
      final managerMap = processed['manager'] as Map;
      processed['manager'] = managerMap['_id'] ?? managerMap['id']?.toString();
    }
    
    return processed;
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

      print('Team by ID response: $response');

      Map<String, dynamic> teamData = {};
      
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          teamData = data;
        } else if (data is List && data.isNotEmpty) {
          teamData = data.first;
        } else {
          teamData = response;
        }
      } else {
        teamData = response;
      }
      
      // Process the team JSON to convert manager from Map to String
      final processedTeamData = _processTeamJson(teamData);
      return TeamModel.fromJson(processedTeamData);
      
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

      print('Create team response: $response');

      Map<String, dynamic> createdTeam = {};
      
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          createdTeam = data;
        } else if (data is List && data.isNotEmpty) {
          createdTeam = data.first;
        } else {
          createdTeam = response;
        }
      } else {
        createdTeam = response;
      }
      
      // Process the team JSON to convert manager from Map to String
      final processedTeamData = _processTeamJson(createdTeam);
      return TeamModel.fromJson(processedTeamData);
      
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

      print('Update team response: $response');

      Map<String, dynamic> updatedTeam = {};
      
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          updatedTeam = data;
        } else if (data is List && data.isNotEmpty) {
          updatedTeam = data.first;
        } else {
          updatedTeam = response;
        }
      } else {
        updatedTeam = response;
      }
      
      // Process the team JSON to convert manager from Map to String
      final processedTeamData = _processTeamJson(updatedTeam);
      return TeamModel.fromJson(processedTeamData);
      
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
      
      if (response['success'] == true || response['statusCode'] == 200) {
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

    print('Adding member - Team: $teamId, User: $userId');
    
    // CORRECT ENDPOINT: teams/{teamId}/members with userId in body
    final response = await apiClient.post(
      'teams/$teamId/members/$userId',  // Note: no userId in URL
      body: {'userId': userId},   // userId goes in the body
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Add member response: $response');

    // Check if response is empty (some APIs return empty on success)
    if (response.isEmpty) {
      // If empty response, fetch the updated team
      print('Empty response, fetching updated team...');
      return await getTeamById(teamId);
    }

    // Extract the updated team from response
    Map<String, dynamic> updatedTeam = {};
    
    if (response.containsKey('data')) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        updatedTeam = data;
      } else if (data is List && data.isNotEmpty) {
        updatedTeam = data.first;
      } else {
        updatedTeam = response;
      }
    } else {
      updatedTeam = response;
    }
    
    // Process the team JSON to convert manager from Map to String
    final processedTeamData = _processTeamJson(updatedTeam);
    return TeamModel.fromJson(processedTeamData);
    
  } on ApiException {
    rethrow;
  } catch (e) {
    print('Error in addMember: $e');
    throw ApiException('Failed to add member: ${e.toString()}');
  }
}
 // Remove member from team
// Remove member from team
Future<TeamModel> removeMember(String teamId, String userId) async {
  try {
    final token = await TokenManager.getToken();

    if (token == null) {
      throw UnauthorizedException('No authentication token found');
    }

    print('Removing member - Team: $teamId, User: $userId');
    
    // For removal, userId goes in the URL
    final response = await apiClient.delete(
      'teams/$teamId/members/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Remove member response: $response');

    // Check if response is empty
    if (response.isEmpty) {
      // If empty response, fetch the updated team
      print('Empty response, fetching updated team...');
      return await getTeamById(teamId);
    }

    // Extract the updated team from response
    Map<String, dynamic> updatedTeam = {};
    
    if (response.containsKey('data')) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        updatedTeam = data;
      } else if (data is List && data.isNotEmpty) {
        updatedTeam = data.first;
      } else {
        updatedTeam = response;
      }
    } else {
      updatedTeam = response;
    }
    
    // Process the team JSON to convert manager from Map to String
    final processedTeamData = _processTeamJson(updatedTeam);
    return TeamModel.fromJson(processedTeamData);
    
  } on ApiException {
    rethrow;
  } catch (e) {
    print('Error in removeMember: $e');
    throw ApiException('Failed to remove member: ${e.toString()}');
  }
}

  // Get all members (users with role 'member')
 // Get all members (users with role 'member')
Future<List<SimpleUser>> getAllMembers() async {
  try {
    final token = await TokenManager.getToken();

    final response = await apiClient.get(
      'users/role/member',
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    List<SimpleUser> members = [];

    if (response.containsKey('data')) {
      final data = response['data'];
      if (data is List) {
        members = data.map((json) => SimpleUser.fromJson(json)).toList();
      }
    }

    return members;
    
  } catch (e) {
    print('Error in getting All Members: $e');
    throw ApiException('Failed to fetch members: ${e.toString()}');
  }
}
}