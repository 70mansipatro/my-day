import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/habits/habits_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/tasks/tasks_screen.dart';

/// Central place for all named routes used across the app.
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String notes = '/notes';
  static const String habits = '/habits';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    tasks: (context) => const TasksScreen(),
    notes: (context) => const NotesScreen(),
    habits: (context) => const HabitsScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
