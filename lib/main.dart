import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';

void main() {
  final apiClient = ApiClient();
  final authProvider = AuthProvider(
    authService: AuthService(apiClient),
    storage: SecureStorageService(),
  );
  final taskProvider = TaskProvider(taskService: TaskService(apiClient));
  apiClient.onUnauthorized = authProvider.handleUnauthorized;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: taskProvider),
      ],
      child: const MyDayApp(),
    ),
  );
}
