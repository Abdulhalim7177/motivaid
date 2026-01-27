import 'package:flutter/material.dart';
import 'package:motivaid/core/auth/widgets/auth_gate.dart';
import 'package:motivaid/features/auth/screens/login_screen.dart';
import 'package:motivaid/features/auth/screens/signup_screen.dart';
import 'package:motivaid/features/home/screens/home_screen.dart';
import 'core/theme/app_theme.dart';

/// Main App Widget
class MotivAidApp extends StatelessWidget {
  const MotivAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotivAid',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // AuthGate wrapper - routes to login or dashboard based on auth state
      home: const AuthGate(
        authenticatedChild: DashboardScreen(),
      ),
      
      // Routes for authentication screens
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
