import 'package:motivaid/core/auth/models/auth_user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Get the current authenticated user
  Future<AuthUser?> getCurrentUser();

  /// Sign up with email and password
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  });

  /// Sign in with email and password
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Stream of authentication state changes
  Stream<AuthUser?> get authStateChanges;
}
