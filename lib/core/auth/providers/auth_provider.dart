import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/models/auth_user.dart';
import 'package:motivaid/core/auth/repositories/auth_repository.dart';
import 'package:motivaid/core/auth/repositories/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState, AuthUser;

/// Provider for the Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for the authentication repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(supabase);
});

/// Provider for the authentication state
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  
  return repository.authStateChanges.map((user) {
    if (user != null) {
      return AuthStateAuthenticated(user);
    } else {
      return const AuthStateUnauthenticated();
    }
  }).handleError((error) {
    return AuthStateError(error.toString());
  });
});

/// Authentication controller/notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthStateLoading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthStateAuthenticated(user);
      } else {
        state = const AuthStateUnauthenticated();
      }
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = const AuthStateLoading();
      final user = await _repository.signUpWithEmail(
        email: email,
        password: password,
        metadata: metadata,
      );
      state = AuthStateAuthenticated(user);
    } catch (e) {
      state = AuthStateError(e.toString());
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthStateLoading();
      
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      
      state = AuthStateAuthenticated(user);
    } catch (e) {
      state = AuthStateError(e.toString());
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _repository.signOut();
      state = const AuthStateUnauthenticated();
    } catch (e) {
      state = AuthStateError(e.toString());
      rethrow;
    }
  }

  /// Get current authenticated user
  AuthUser? get currentUser {
    final currentState = state;
    if (currentState is AuthStateAuthenticated) {
      return currentState.user;
    }
    return null;
  }
}

/// Provider for the authentication notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
