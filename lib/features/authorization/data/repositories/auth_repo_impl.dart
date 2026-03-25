import '../../../../core/networks/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../../core/networks/token_manager.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl(this.apiClient);

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        "auth/login",
        body: {"email": email, "password": password},
      );

      final token = response["data"]["accessToken"];
      await TokenManager.saveToken(token);

      final userJson = response["data"]["user"];
      
      // Convert UserModel to User entity
      final userModel = UserModel.fromJson(userJson);
      return User(
        id: userModel.id,
        name: userModel.name,
        email: userModel.email,
        role: userModel.role,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> register(String email, String password, String role) async {
    try {
      final response = await apiClient.post(
        "auth/register",
        body: {"email": email, "password": password, "role": role},
      );

      final userJson = response["data"]["user"];
      
      // Convert UserModel to User entity
      final userModel = UserModel.fromJson(userJson);
      return User(
        id: userModel.id,
        name: userModel.name,
        email: userModel.email,
        role: userModel.role,
      );
    } catch (e) {
      rethrow;
    }
  }
}