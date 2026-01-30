import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/profile/providers/profile_provider.dart';
import 'package:motivaid/features/profile/screens/profile_edit_screen.dart';
import 'package:motivaid/features/profile/widgets/profile_avatar.dart';
import 'package:motivaid/features/profile/widgets/profile_info_card.dart';
import 'package:intl/intl.dart';

class ProfileViewScreen extends ConsumerWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authNotifierProvider.notifier);
    final currentUser = authNotifier.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Not authenticated'));
    }

    final profileAsync = ref.watch(userProfileProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Navigate back to dashboard when back button is pressed
        context.go('/dashboard');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditScreen(),
                  ),
                );

                if (result == true) {
                  // Refresh profile
                  ref.invalidate(userProfileProvider);
                }
              },
              tooltip: 'Edit Profile',
            ),
          ],
        ),
        body: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_outline, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Profile not found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(userProfileProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Avatar
                  ProfileAvatar(
                    avatarUrl: profile.avatarUrl,
                    initials: profile.initials,
                    size: 120,
                  ),
                  const SizedBox(height: 16),

                  // Name or Email
                  Text(
                    profile.fullName ?? profile.email,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile.fullName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Profile Information Cards
                  ProfileInfoCard(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: profile.fullName,
                  ),
                  const SizedBox(height: 12),

                  ProfileInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: profile.email,
                  ),
                  const SizedBox(height: 12),

                  ProfileInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: profile.phone,
                  ),
                  const SizedBox(height: 12),

                  ProfileInfoCard(
                    icon: Icons.cake_outlined,
                    label: 'Date of Birth',
                    value: profile.dateOfBirth != null
                        ? DateFormat('MMMM d, yyyy').format(profile.dateOfBirth!)
                        : null,
                  ),
                  const SizedBox(height: 12),

                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    ProfileInfoCard(
                      icon: Icons.info_outline,
                      label: 'Bio',
                      value: profile.bio,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Account Info
                  const SizedBox(height: 24),
                  Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ProfileInfoCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Member Since',
                    value: DateFormat('MMMM d, yyyy').format(profile.createdAt),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading profile: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(userProfileProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
