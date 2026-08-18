import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final authProvider = context.read<AuthProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        authProvider.checkAuthStatus(),
        Future.delayed(const Duration(milliseconds: 1200)),
      ]);
      if (!mounted) return;

      final destination = authProvider.isAuthenticated
          ? AppRoutes.home
          : AppRoutes.login;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(destination, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.gray800,
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: const TextStyle(fontSize: 16, color: AppColors.gray600),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.gray800),
          ],
        ),
      ),
    );
  }
}
