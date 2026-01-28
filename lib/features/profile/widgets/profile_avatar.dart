import 'package:flutter/material.dart';

/// Reusable avatar widget for displaying user profile pictures or initials
class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.initials,
    this.size = 80,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.2),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      child: avatarUrl != null
          ? ClipOval(
              child: Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials(context);
                },
              ),
            )
          : _buildInitials(context),
    );
  }

  Widget _buildInitials(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: textColor ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
