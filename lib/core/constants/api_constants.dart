/// API endpoint configuration.
///
/// 10.0.2.2 is the special alias the Android emulator uses to reach
/// "localhost" on the host machine. Update [baseUrl] when pointing at a
/// physical device, a LAN IP, or a deployed production server.
class ApiConstants {
  static const String baseUrl = 'http://localhost:5000/api';

  static const String health = '/health';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String tasks = '/tasks';
  static const String notes = '/notes';
  static const String habits = '/habits';
  static const String notifications = '/notifications';
  static const String notificationPreferences = '/notification-preferences';
}
