import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Navigate back to dashboard when back button is pressed
        context.go('/dashboard');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader(context, 'Account'),
            _buildSettingsTile(
              context,
              icon: Icons.person_outline,
              title: 'Account Information',
              subtitle: 'View and edit your account details',
              onTap: () {
                // Navigate to account info
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {
                // Navigate to change password
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password change feature coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Preferences'),
            _buildSettingsTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification settings coming soon!'),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Theme',
              subtitle: 'Light or dark mode',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme settings coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'About'),
            _buildSettingsTile(
              context,
              icon: Icons.info_outline,
              title: 'About MotivAid',
              subtitle: 'Version 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'MotivAid',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 MotivAid',
                );
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy policy coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Danger Zone'),
            _buildSettingsTile(
              context,
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              textColor: Colors.red,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final authNotifier = ref.read(authNotifierProvider.notifier);
                  await authNotifier.signOut();
                }
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.delete_outline,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              textColor: Colors.red,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'Are you sure you want to delete your account? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deletion feature coming soon!'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
