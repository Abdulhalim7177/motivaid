import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/units/providers/unit_membership_provider.dart';
import 'package:motivaid/features/auth/screens/login_screen.dart';
import 'package:motivaid/features/auth/screens/pending_approval_screen.dart';

/// Authentication gate that routes users based on authentication state and approval status
class AuthGate extends ConsumerWidget {
  final Widget authenticatedChild;

  const AuthGate({
    super.key,
    required this.authenticatedChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    
    return switch (authState) {
      AuthStateLoading() => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      AuthStateAuthenticated() => _ApprovalChecker(
          authenticatedChild: authenticatedChild,
        ),
      AuthStateUnauthenticated() => const LoginScreen(),
      AuthStateError(message: final message) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $message'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(authNotifierProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
    };
  }
}

/// Check if user has approved unit membership
class _ApprovalChecker extends ConsumerWidget {
  final Widget authenticatedChild;

  const _ApprovalChecker({required this.authenticatedChild});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(userMembershipsProvider);

    return membershipsAsync.when(
      data: (memberships) {
        // Check if user has any approved memberships
        final hasApproved = memberships.any((m) => m.isApproved);
        
        if (hasApproved) {
          // User has at least one approved membership - proceed to app
          return authenticatedChild;
        } else {
          // User has no approved memberships - show pending screen
          return const PendingApprovalScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        // On error, show the app anyway (fail-open for now)
        // TODO: Could be more strict in production
        return authenticatedChild;
      },
    );
  }
}
