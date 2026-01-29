import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/units/providers/unit_membership_provider.dart';
import 'package:motivaid/features/auth/screens/login_screen.dart';
import 'package:motivaid/features/auth/screens/signup_screen.dart';
import 'package:motivaid/features/auth/screens/pending_approval_screen.dart';
import 'package:motivaid/features/home/screens/home_screen.dart';
import 'package:motivaid/features/profile/screens/profile_view_screen.dart';
import 'package:motivaid/features/settings/screens/settings_screen.dart';
import 'package:motivaid/features/supervisor/screens/supervisor_approval_screen.dart';
import 'package:motivaid/features/splash/screens/splash_screen.dart';

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final currentPath = state.matchedLocation;
      
      // Allow splash screen initially - but check auth and redirect if needed
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState is AuthStateAuthenticated;
      final isLoggingIn = currentPath == '/login';
      final isSigningUp = currentPath == '/signup';
      final isOnSplash = currentPath == '/splash';
      
      // If on splash and authenticated, redirect to appropriate page
      if (isOnSplash && isLoggedIn) {
        // Check membership status
          final user = authState.user;
        final membershipRepo = ref.read(unitMembershipRepositoryProvider);
        final memberships = await membershipRepo.getMembershipsByProfile(user.id);
        final hasApprovedMembership = memberships.any((m) => m.isApproved);
        
        return hasApprovedMembership ? '/dashboard' : '/pending';
      }
      
      // Allow splash for unauthenticated users
      if (isOnSplash) {
        return null;
      }
      
      // Not logged in - redirect to login (except for splash, login, signup)
      if (!isLoggedIn) {
        if (isLoggingIn || isSigningUp) return null;
        return '/login';
      }
      
      // Logged in - check membership status for protected routes
        final user = authState.user;
      final membershipRepo = ref.read(unitMembershipRepositoryProvider);
      final memberships = await membershipRepo.getMembershipsByProfile(user.id);
      final hasApprovedMembership = memberships.any((m) => m.isApproved);
      
      // If no approved membership, show pending screen
      if (!hasApprovedMembership) {
        if (currentPath == '/pending') return null;
        return '/pending';
      }
      
      // Logged in with approved membership - redirect to dashboard if on auth screens
      if (isLoggingIn || isSigningUp || currentPath == '/pending') {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/pending',
        name: 'pending',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'root',
        redirect: (context, state) => '/dashboard',
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileViewScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/supervisor/approvals',
        name: 'supervisor-approvals',
        builder: (context, state) => const SupervisorApprovalScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});
