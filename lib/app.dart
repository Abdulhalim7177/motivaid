import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

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
      
      // Splash Screen as Home
      home: const SplashScreen(),
      
      // TODO: Add routing configuration when implementing navigation
    );
  }
}
