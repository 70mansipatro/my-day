import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

/// Reusable HTTP client for talking to the MyDay backend.
///
/// Authorization headers and token refresh logic will be added in Phase 2
/// once real authentication is implemented.
class ApiClient {
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Uri _uri(String endpoint) => Uri.parse('${ApiConstants.baseUrl}$endpoint');

  Future<http.Response> get(String endpoint) {
    return _client.get(_uri(endpoint), headers: _headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) {
    return _client.post(
      _uri(endpoint),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) {
    return _client.put(
      _uri(endpoint),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) {
    return _client.delete(_uri(endpoint), headers: _headers);
  }
}
