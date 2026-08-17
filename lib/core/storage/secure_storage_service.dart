import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] for persisting the JWT auth token.
///
/// The token must never be stored with SharedPreferences, printed to the
/// console, or displayed in the UI.
class SecureStorageService {
  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() {
    return _storage.delete(key: _tokenKey);
  }

  Future<void> clearAll() {
    return _storage.deleteAll();
  }
}
