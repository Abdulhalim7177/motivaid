import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/features/auth/screens/login_screen.dart';

/// Authentication gate that routes users based on authentication state
class AuthGate extends ConsumerWidget {
  final Widget authenticatedChild;

  const AuthGate({
    super.key,
    required this.authenticatedChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    
    // Debug logging
    print('🔐 AuthGate build - State: ${authState.runtimeType}');
    if (authState is AuthStateAuthenticated) {
      print('   ✅ User authenticated: ${authState.user.email}');
    }

    return switch (authState) {
      AuthStateLoading() => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      AuthStateAuthenticated() => authenticatedChild,
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
