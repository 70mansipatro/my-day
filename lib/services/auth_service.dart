import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

/// Result of a successful register/login call: the user plus their JWT.
class AuthResult {
  final UserModel user;
  final String token;

  const AuthResult({required this.user, required this.token});
}

/// Talks to the backend `/api/auth` endpoints. Contains no UI code.
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final body = await _apiClient.post('${ApiConstants.auth}/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    return _parseAuthResult(body);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final body = await _apiClient.post('${ApiConstants.auth}/login', {
      'email': email,
      'password': password,
    });
    return _parseAuthResult(body);
  }

  Future<UserModel> getCurrentUser() async {
    final body = await _apiClient.get('${ApiConstants.auth}/me', requiresAuth: true);
    final data = body['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _apiClient.post('${ApiConstants.auth}/logout', const {}, requiresAuth: true);
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await _apiClient.post('${ApiConstants.auth}/reset-password', {
      'email': email,
      'newPassword': newPassword,
    });
  }

  AuthResult _parseAuthResult(Map<String, dynamic> body) {
    final data = body['data'] as Map<String, dynamic>;
    return AuthResult(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }
}
