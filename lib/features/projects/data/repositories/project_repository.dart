import '../../../../core/networks/api_client.dart';
import '../../../../core/networks/token_manager.dart';
import '../../../../core/networks/api_exception.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final ApiClient apiClient;

  ProjectRepository({required this.apiClient});
  // Add this method to get projects by manager ID
Future<List<ProjectModel>> getProjectsByManager(String managerId) async {
  try {
    final token = await TokenManager.getToken();
    
    print('=== GET PROJECTS BY MANAGER ===');
    print('Manager ID: $managerId');
    print('Token exists: ${token != null}');
    
    if (token == null) {
      throw UnauthorizedException('No authentication token found');
    }
    
    final response = await apiClient.get(
      'projects/manager/$managerId',  // Use manager-specific endpoint
      headers: {'Authorization': 'Bearer $token'},
    );
    
    print('Response status: Success');
    print('Response keys: ${response.keys}');
    
    List<ProjectModel> projects = [];
    
    if (response.containsKey('data')) {
      final data = response['data'];
      if (data is List) {
        projects = data.map((json) => ProjectModel.fromJson(json)).toList();
        print('Found ${projects.length} projects for manager');
        for (var project in projects) {
          print('  - ${project.name} (Status: ${project.status})');
        }
      }
    }
    
    return projects;
  } on ApiException catch (e) {
    print('API Error in getProjectsByManager: $e');
    rethrow;
  } catch (e) {
    print('Error in getProjectsByManager: $e');
    throw ApiException('Failed to fetch manager projects: ${e.toString()}');
  }
}

  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final token = await TokenManager.getToken();
       print('=== DEBUG PROJECTS REQUEST ===');
    print('Token exists: ${token != null}');
    if (token != null) {
      print('Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    }
    
   
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

    //  print('Fetching projects with token: $token');
      
      final response = await apiClient.get(
        'projects',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response status: Success');
    print('Response keys: ${response.keys}');
      // Handle different response structures from ApiClient
      List<ProjectModel> projects = [];
        if (response.containsKey('data')) {
      final data = response['data'];
      if (data is List) {
        projects = data.map((json) => ProjectModel.fromJson(json)).toList();
        print('Found ${projects.length} projects');
        for (var project in projects) {
          print('  - ${project.name} (Manager: ${project.manager.name}, ID: ${project.manager.id})');
        }
      }
    } 
     

      // Case 1: Response has 'data' field (most common with your ApiClient)
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          projects = data.map((json) => ProjectModel.fromJson(json)).toList();
        } else if (data is Map<String, dynamic>) {
          projects = [ProjectModel.fromJson(data)];
        }
      }
      // Case 2: Response itself is a list wrapped in a Map
      else if (response.containsKey('projects') && response['projects'] is List) {
        final projectsData = response['projects'];
        projects = projectsData.map((json) => ProjectModel.fromJson(json)).toList();
      }
      // Case 3: Response has 'items' field (pagination)
      else if (response.containsKey('items') && response['items'] is List) {
        final items = response['items'];
        projects = items.map((json) => ProjectModel.fromJson(json)).toList();
      }
      // Case 4: Response values contain lists
      else {
        // Check each value in the response map for a list
        bool foundList = false;
        response.forEach((key, value) {
          if (!foundList && value is List) {
            print("Found list in key: $key");
            projects = value.map((json) => ProjectModel.fromJson(json)).toList();
            foundList = true;
          }
        });
      }

      print('Parsed ${projects.length} projects');
      return projects;
      
    } on UnauthorizedException {
      rethrow;
    } on ServerException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in getAllProjects: $e');
      throw ApiException('Failed to fetch projects: ${e.toString()}');
    }
  }

  // Optional: Get single project by ID
  Future<ProjectModel> getProjectById(String projectId) async {
    try {
      final token = await TokenManager.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.get(
        'projects/$projectId',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Project by ID response: $response');

      // Handle different response structures
      if (response.containsKey('data')) {
        return ProjectModel.fromJson(response['data']);
      } else if (response.containsKey('project')) {
        return ProjectModel.fromJson(response['project']);
      } else {
        return ProjectModel.fromJson(response);
      }
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in getProjectById: $e');
      throw ApiException('Failed to fetch project: ${e.toString()}');
    }
  }

  // Optional: Create new project
  Future<ProjectModel> createProject(Map<String, dynamic> projectData) async {
    try {
      final token = await TokenManager.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.post(
        'projects',
        body: projectData,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Create project response: $response');

      // Handle different response structures
      if (response.containsKey('data')) {
        return ProjectModel.fromJson(response['data']);
      } else if (response.containsKey('project')) {
        return ProjectModel.fromJson(response['project']);
      } else {
        return ProjectModel.fromJson(response);
      }
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in createProject: $e');
      throw ApiException('Failed to create project: ${e.toString()}');
    }
  }

  // Optional: Update project
  Future<ProjectModel> updateProject(String projectId, Map<String, dynamic> updateData) async {
    try {
      final token = await TokenManager.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.patch(
        'projects/$projectId',
        body: updateData,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Update project response: $response');

      // Handle different response structures
      if (response.containsKey('data')) {
        return ProjectModel.fromJson(response['data']);
      } else if (response.containsKey('project')) {
        return ProjectModel.fromJson(response['project']);
      } else {
        return ProjectModel.fromJson(response);
      }
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in updateProject: $e');
      throw ApiException('Failed to update project: ${e.toString()}');
    }
  }

  // Optional: Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      final token = await TokenManager.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.delete(
        'projects/$projectId',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Delete project response: $response');
      
      // Check if deletion was successful
      if (response['success'] == true || response['statusCode'] == 200) {
        return;
      }
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in deleteProject: $e');
      throw ApiException('Failed to delete project: ${e.toString()}');
    }
  }
}