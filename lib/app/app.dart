import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

class MyDayApp extends StatelessWidget {
  const MyDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
