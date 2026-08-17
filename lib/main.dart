import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

void main() {
  final apiClient = ApiClient();
  final authProvider = AuthProvider(
    authService: AuthService(apiClient),
    storage: SecureStorageService(),
  );
  apiClient.onUnauthorized = authProvider.handleUnauthorized;

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const MyDayApp(),
    ),
  );
}
