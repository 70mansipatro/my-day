import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_day/app/app.dart';
import 'package:my_day/core/constants/app_constants.dart';
import 'package:my_day/core/network/api_client.dart';
import 'package:my_day/core/storage/secure_storage_service.dart';
import 'package:my_day/providers/auth_provider.dart';
import 'package:my_day/providers/note_provider.dart';
import 'package:my_day/providers/task_provider.dart';
import 'package:my_day/services/auth_service.dart';
import 'package:my_day/services/note_service.dart';
import 'package:my_day/services/task_service.dart';

void main() {
  testWidgets('App boots and shows the splash screen', (
    WidgetTester tester,
  ) async {
    final apiClient = ApiClient();
    final authProvider = AuthProvider(
      authService: AuthService(apiClient),
      storage: SecureStorageService(),
    );
    final taskProvider = TaskProvider(taskService: TaskService(apiClient));
    final noteProvider = NoteProvider(noteService: NoteService(apiClient));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: taskProvider),
          ChangeNotifierProvider.value(value: noteProvider),
        ],
        child: const MyDayApp(),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
