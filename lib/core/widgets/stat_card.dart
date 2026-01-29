import 'package:flutter/material.dart';
import 'package:motivaid/core/theme/app_theme.dart';

/// Small stat card for displaying metrics
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? AppColors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor ?? AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: (textColor ?? AppColors.white).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
