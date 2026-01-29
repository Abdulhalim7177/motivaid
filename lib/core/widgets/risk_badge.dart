import 'package:flutter/material.dart';
import 'package:motivaid/core/theme/app_theme.dart';

enum RiskLevel { high, medium, low }

/// Risk badge component for displaying patient risk status
class RiskBadge extends StatelessWidget {
  final RiskLevel risk;
  final bool small;

  const RiskBadge({
    super.key,
    required this.risk,
    this.small = false,
  });

  Color get _backgroundColor {
    switch (risk) {
      case RiskLevel.high:
        return AppColors.highRisk;
      case RiskLevel.medium:
        return AppColors.mediumRisk;
      case RiskLevel.low:
        return AppColors.lowRisk;
    }
  }

  String get _label {
    switch (risk) {
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.medium:
        return 'Monitor';
      case RiskLevel.low:
        return 'Low Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _backgroundColor,
          width: 1,
        ),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: _backgroundColor,
        ),
      ),
    );
  }
}
