import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

/// A friendly, user-facing API error. Never carries stack traces, database
/// errors, or other internal details.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Reusable HTTP client for talking to the MyDay backend.
///
/// Attaches `Authorization: Bearer <token>` to requests marked
/// [requiresAuth]. On a 401 from an authenticated request, invokes
/// [onUnauthorized] so the app can clear the session and return to Login.
class ApiClient {
  final http.Client _client;
  final SecureStorageService _storage;

  /// Called when an authenticated request comes back 401 (expired/invalid
  /// token). Wired up in main.dart to AuthProvider.handleUnauthorized.
  void Function()? onUnauthorized;

  ApiClient({http.Client? client, SecureStorageService? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? SecureStorageService();

  Uri _uri(String endpoint) => Uri.parse('${ApiConstants.baseUrl}$endpoint');

  Future<Map<String, String>> _headers({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
  }) {
    return _send(
      requiresAuth: requiresAuth,
      request: (headers) => _client.get(_uri(endpoint), headers: headers),
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) {
    return _send(
      requiresAuth: requiresAuth,
      request: (headers) => _client.post(
        _uri(endpoint),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) {
    return _send(
      requiresAuth: requiresAuth,
      request: (headers) =>
          _client.put(_uri(endpoint), headers: headers, body: jsonEncode(body)),
    );
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) {
    return _send(
      requiresAuth: requiresAuth,
      request: (headers) => _client.patch(
        _uri(endpoint),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) {
    return _send(
      requiresAuth: requiresAuth,
      request: (headers) => _client.delete(_uri(endpoint), headers: headers),
    );
  }

  Future<Map<String, dynamic>> _send({
    required bool requiresAuth,
    required Future<http.Response> Function(Map<String, String> headers)
    request,
  }) async {
    http.Response response;
    try {
      final headers = await _headers(requiresAuth: requiresAuth);
      response = await request(headers).timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const ApiException(
        'Unable to connect to server. Please check your internet connection.',
      );
    } on HttpException {
      throw const ApiException(
        'Unable to connect to server. Please check your internet connection.',
      );
    } catch (_) {
      throw const ApiException(
        'Unable to connect to server. Please check your internet connection.',
      );
    }

    return _handleResponse(response, requiresAuth: requiresAuth);
  }

  Map<String, dynamic> _handleResponse(
    http.Response response, {
    required bool requiresAuth,
  }) {
    Map<String, dynamic> body = const {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      } catch (_) {
        // Non-JSON body (e.g. an upstream proxy error page) — fall through
        // to the generic status-code message below.
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401 && requiresAuth) {
      onUnauthorized?.call();
    }

    final message =
        body['message'] as String? ?? _fallbackMessage(response.statusCode);
    throw ApiException(message, statusCode: response.statusCode);
  }

  String _fallbackMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Invalid email or password.';
      case 409:
        return 'This email is already registered.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
