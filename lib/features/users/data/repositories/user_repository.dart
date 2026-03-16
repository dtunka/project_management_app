import '../../../../core/networks/api_client.dart';
import '../../../../core/networks/token_manager.dart';
import '../models/user_model.dart';
import '../../../../core/networks/api_exception.dart';

class UserRepository {
  final ApiClient apiClient;
  
  UserRepository({required this.apiClient});

  Future<List<UserModel>> getUsers() async {
    try {
      final token = await TokenManager.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }
      
      final response = await apiClient.get(
        "users",
        headers: {"Authorization": "Bearer $token"},
      );
      
      print("Get Users Response Type: ${response.runtimeType}");
      print("Get Users Response: $response");
      
      List<UserModel> users = [];
      
      // Handle different response structures
      if (response.containsKey('data')) {
        // Case 1: Response has 'data' field
        final data = response['data'];
        print("Data type: ${data.runtimeType}");
        
        if (data is List) {
          // If data is a List, map it directly
          users = data.map((user) => UserModel.fromJson(user)).toList();
        } else if (data is Map<String, dynamic>) {
          // If data is a single object, wrap in list
          users = [UserModel.fromJson(data)];
        }
      } else if (response.containsKey('users')) {
        // Case 2: Response has 'users' field
        final usersData = response['users'];
        print("Users data type: ${usersData.runtimeType}");
        
        if (usersData is List) {
          users = usersData.map((user) => UserModel.fromJson(user)).toList();
        }
      } else if (response.containsKey('items')) {
        // Case 3: Response has 'items' field (pagination)
        final items = response['items'];
        if (items is List) {
          users = items.map((user) => UserModel.fromJson(user)).toList();
        }
      } else {
        // Case 4: Try to check if response itself is a list
        // Since response is Map<String, dynamic>, it can't be a List
        // So we need to look for array values in the response
        
        bool foundList = false;
        
        // Check each value in the response map
        response.forEach((key, value) {
          if (!foundList && value is List) {
            print("Found list in key: $key");
            users = value.map((user) => UserModel.fromJson(user)).toList();
            foundList = true;
          }
        });
        
        // If no list found, maybe the response values contain user objects
        if (!foundList) {
          // Check if the response values are user objects
          final values = response.values.whereType<Map<String, dynamic>>().toList();
          if (values.isNotEmpty) {
            users = values.map((user) => UserModel.fromJson(user)).toList();
          }
        }
      }
      
      print("Parsed ${users.length} users");
      return users;
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print("Error in getUsers: $e");
      print("Stack trace: ${StackTrace.current}");
      throw ApiException('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final token = await TokenManager.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }
      
      final response = await apiClient.delete(
        "users/$userId",
        headers: {"Authorization": "Bearer $token"},
      );
      
      print("Delete User Response: $response");
      
      // Check if deletion was successful
      if (response["success"] == true || response["statusCode"] == 200) {
        return;
      }
      
      // If response indicates failure
      throw ApiException('Failed to delete user');
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print("Error in deleteUser: $e");
      throw ApiException('Failed to delete user: ${e.toString()}');
    }
  }

 Future<UserModel> updateUser(String userId, Map<String, dynamic> updateData) async {
  try {
    final token = await TokenManager.getToken();
    
    if (token == null) {
      throw UnauthorizedException('No authentication token found');
    }
    
    final response = await apiClient.patch(
      "users/$userId",
      body: updateData,
      headers: {"Authorization": "Bearer $token"},
    );
    
    print("Update User Response Type: ${response.runtimeType}");
   // print("Update User Response: $response");
    
    // Handle different response structures
    UserModel? updatedUser;
    
    // Case 1: Response is a List (your API might be returning an array)
    if (response is List) {
      print("Response is a List with ${response.length} items");
      if (response.isNotEmpty) {
        final firstItem = response[0]; // Use index instead of .first
        print("First item type: ${firstItem.runtimeType}");
        
        if (firstItem is Map<String, dynamic>) {
          updatedUser = UserModel.fromJson(firstItem);
        } else if (firstItem is Map) {
          // Convert Map to Map<String, dynamic>
          Map<String, dynamic> castedMap = Map<String, dynamic>.from(firstItem);
          updatedUser = UserModel.fromJson(castedMap);
        }
      }
    }
    // Case 2: Response has 'data' field that might be a List or Map
    else if (response.containsKey('data')) {
      final data = response['data'];
      print("Data type: ${data.runtimeType}");
      
      if (data is List) {
        if (data.isNotEmpty) {
          updatedUser = UserModel.fromJson(data.first);
        }
      } else if (data is Map<String, dynamic>) {
        updatedUser = UserModel.fromJson(data);
      }
    }
    // Case 3: Response has 'user' field
    else if (response.containsKey('user')) {
      final user = response['user'];
      if (user is Map<String, dynamic>) {
        updatedUser = UserModel.fromJson(user);
      }
    }
    // Case 4: Response itself is a Map (standard case)
    else if (response is Map<String, dynamic>) {
      updatedUser = UserModel.fromJson(response);
    }
    
    if (updatedUser != null) {
      print("User updated successfully: ${updatedUser.name}");
      return updatedUser;
    }
    
    throw ApiException('Failed to parse updated user data from response: $response');
    
  } on ApiException {
    rethrow;
  } catch (e) {
    print("Error in updateUser: $e");
    print("Stack trace: ${StackTrace.current}");
    throw ApiException('Failed to update user: ${e.toString()}');
  }
}

  Future<UserModel> getUserById(String userId) async {
    try {
      final token = await TokenManager.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }
      
      final response = await apiClient.get(
        "users/$userId",
        headers: {"Authorization": "Bearer $token"},
      );
      
      print("Get User By ID Response: $response");
      
      // Handle different response structures
      if (response.containsKey("data")) {
        return UserModel.fromJson(response["data"]);
      } else if (response.containsKey("user")) {
        return UserModel.fromJson(response["user"]);
      } else {
        return UserModel.fromJson(response);
      }
      
    } on ApiException {
      rethrow;
    } catch (e) {
      print("Error in getUserById: $e");
      throw ApiException('Failed to fetch user: ${e.toString()}');
    }
  }
}