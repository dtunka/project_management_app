import '../../../../core/networks/api_client.dart';
import '../../../../core/networks/token_manager.dart';
import '../../../../core/networks/api_exception.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';

class TaskRepository {
  final ApiClient apiClient;

  TaskRepository({required this.apiClient});

  // Get all tasks (for manager - all tasks from their projects)
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.get(
        'tasks',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Tasks response: $response');

      List<TaskModel> tasks = [];

      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          tasks = data.map((json) => TaskModel.fromJson(json)).toList();
        }
      }

      print('Fetched ${tasks.length} tasks');
      return tasks;
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in getAllTasks: $e');
      throw ApiException('Failed to fetch tasks: ${e.toString()}');
    }
  }

  // Get tasks by project
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.get(
        'tasks/project/$projectId',
        headers: {'Authorization': 'Bearer $token'},
      );

      List<TaskModel> tasks = [];

      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          tasks = data.map((json) => TaskModel.fromJson(json)).toList();
        }
      }

      return tasks;
    } catch (e) {
      print('Error in getTasksByProject: $e');
      throw ApiException('Failed to fetch project tasks: ${e.toString()}');
    }
  }

  // Create new task
  Future<TaskModel> createTask(Map<String, dynamic> taskData) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.post(
        'tasks',
        body: taskData,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Create task response: $response');

      if (response.containsKey('data')) {
        return TaskModel.fromJson(response['data']);
      }
      return TaskModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in createTask: $e');
      throw ApiException('Failed to create task: ${e.toString()}');
    }
  }

  // Update task
  Future<TaskModel> updateTask(String taskId, Map<String, dynamic> updateData) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.patch(
        'tasks/$taskId',
        body: updateData,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Update task response: $response');

      if (response.containsKey('data')) {
        return TaskModel.fromJson(response['data']);
      }
      return TaskModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in updateTask: $e');
      throw ApiException('Failed to update task: ${e.toString()}');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.delete(
        'tasks/$taskId',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Delete task response: $response');

      if (response['success'] == true || response['statusCode'] == 200) {
        return;
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Error in deleteTask: $e');
      throw ApiException('Failed to delete task: ${e.toString()}');
    }
  }

  // Add comment to task
  Future<Comment> addComment(String taskId, String text, {List<String>? attachments}) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final Map<String, dynamic> body = {
        'text': text,
      };
      if (attachments != null && attachments.isNotEmpty) {
        body['attachments'] = attachments;
      }

      final response = await apiClient.post(
        'tasks/$taskId/comments',
        body: body,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Add comment response: $response');

      if (response.containsKey('data')) {
        return Comment.fromJson(response['data']);
      }
      return Comment.fromJson(response);
    } catch (e) {
      print('Error in addComment: $e');
      throw ApiException('Failed to add comment: ${e.toString()}');
    }
  }

  // Get comments for task
  Future<List<Comment>> getComments(String taskId) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await apiClient.get(
        'tasks/$taskId/comments',
        headers: {'Authorization': 'Bearer $token'},
      );

      List<Comment> comments = [];

      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          comments = data.map((json) => Comment.fromJson(json)).toList();
        }
      }

      return comments;
    } catch (e) {
      print('Error in getComments: $e');
      throw ApiException('Failed to fetch comments: ${e.toString()}');
    }
  }
}