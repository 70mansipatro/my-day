import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

/// Owns the app's authentication state: current user, session status, and
/// the register/login/logout/checkAuthStatus actions.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SecureStorageService _storage;

  AuthProvider({
    required AuthService authService,
    required SecureStorageService storage,
  })  : _authService = authService,
        _storage = storage;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  /// Checks secure storage for a token and, if present, validates it against
  /// GET /auth/me. Called once on app startup from the splash screen.
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final token = await _storage.getToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _storage.deleteToken();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);
      await _storage.saveToken(result.token);
      _currentUser = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(name: name, email: email, password: password);
      await _storage.saveToken(result.token);
      _currentUser = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email: email, newPassword: newPassword);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Best-effort: the token is deleted locally regardless, since JWT
      // logout is stateless and the client is the source of truth.
    }
    await _storage.clearAll();
    _currentUser = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Invoked by ApiClient when an authenticated request comes back 401
  /// (expired/invalid token) — clears the session so the UI returns to Login.
  void handleUnauthorized() {
    _storage.deleteToken();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
