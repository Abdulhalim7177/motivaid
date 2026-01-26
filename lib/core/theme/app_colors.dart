import 'package:flutter/material.dart';

/// MotivAid App Color Palette
/// Primary theme: Rose Pink for maternal care warmth and professionalism
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors - Rose Pink Theme
  static const Color primaryRose = Color(0xFFE91E63); // Deep rose pink
  static const Color primaryRoseLight = Color(0xFFF8BBD0); // Light rose pink
  static const Color primaryRoseDark = Color(0xFFC2185B); // Dark rose pink
  
  // Accent Colors
  static const Color accentPink = Color(0xFFFF4081); // Vibrant pink accent
  static const Color accentPinkLight = Color(0xFFFF80AB); // Light pink accent
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFBFE); // Soft white with pink tint
  static const Color backgroundDark = Color(0xFF1A1A1A); // Dark background
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceDark = Color(0xFF2C2C2C); // Dark surface
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green for resolved cases
  static const Color warning = Color(0xFFFF9800); // Orange for alerts
  static const Color error = Color(0xFFF44336); // Red for critical alerts
  static const Color info = Color(0xFF2196F3); // Blue for information
  
  // Risk Level Colors
  static const Color riskLow = Color(0xFF4CAF50); // Green
  static const Color riskMedium = Color(0xFFFF9800); // Orange
  static const Color riskHigh = Color(0xFFFF5722); // Deep Orange
  static const Color riskCritical = Color(0xFFD32F2F); // Dark Red
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Almost black
  static const Color textSecondary = Color(0xFF757575); // Gray
  static const Color textHint = Color(0xFFBDBDBD); // Light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on rose pink
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0); // Light gray border
  static const Color borderMedium = Color(0xFFBDBDBD); // Medium gray border
  static const Color borderDark = Color(0xFF757575); // Dark gray border
  
  // Gradient Colors for Splash/Premium UI
  static const List<Color> roseGradient = [
    Color(0xFFE91E63), // Primary rose
    Color(0xFFFF4081), // Accent pink
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFFFFF0F5), // Lavender blush
    Color(0xFFFFE4E1), // Misty rose
  ];
  
  // Shimmer Colors (for loading states)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  
  // Card/Elevation Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF424242);
  
  // Divider Colors
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF616161);
}
