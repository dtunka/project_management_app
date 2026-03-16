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

    // Extract token from API response
    final token = response["data"]["accessToken"];

    // Save token
    await TokenManager.saveToken(token);

    print("Saved Token: $token");

    final userJson = response["data"]["user"];

    return UserModel.fromJson(userJson);
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

      return UserModel.fromJson(userJson);
    } catch (e) {
      rethrow;
    }
  }
}
