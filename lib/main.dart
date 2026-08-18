import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/note_provider.dart';
import 'providers/task_provider.dart';
import 'services/auth_service.dart';
import 'services/habit_service.dart';
import 'services/note_service.dart';
import 'services/task_service.dart';

void main() {
  final apiClient = ApiClient();
  final authProvider = AuthProvider(
    authService: AuthService(apiClient),
    storage: SecureStorageService(),
  );
  final taskProvider = TaskProvider(taskService: TaskService(apiClient));
  final noteProvider = NoteProvider(noteService: NoteService(apiClient));
  final habitProvider = HabitProvider(habitService: HabitService(apiClient));
  apiClient.onUnauthorized = authProvider.handleUnauthorized;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider.value(value: noteProvider),
        ChangeNotifierProvider.value(value: habitProvider),
      ],
      child: const MyDayApp(),
    ),
  );
}
