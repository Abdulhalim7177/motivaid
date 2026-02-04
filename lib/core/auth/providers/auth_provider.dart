import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/models/auth_user.dart';
import 'package:motivaid/core/auth/repositories/auth_repository.dart';
import 'package:motivaid/core/auth/repositories/supabase_auth_repository.dart';
import 'package:motivaid/core/auth/services/biometric_auth_service.dart';
import 'package:motivaid/core/auth/services/secure_storage_service.dart';
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

/// Provider for the Biometric Auth Service
final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

/// Provider for the Secure Storage Service
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
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
  final SecureStorageService _storageService;

  AuthNotifier(this._repository, this._storageService) : super(const AuthStateLoading()) {
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
      // Persist user for offline access
      await _storageService.saveLastUser(id: user.id, email: user.email);
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
      
      // Persist user for offline access
      await _storageService.saveLastUser(id: user.id, email: user.email);
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
      // Note: We DO NOT clear the last user from secure storage here.
      // This allows the user to re-login with biometrics later even if offline.
      state = const AuthStateUnauthenticated();
    } catch (e) {
      state = AuthStateError(e.toString());
      rethrow;
    }
  }

  /// Login with Biometrics (Offline Support)
  /// Note: This relies on a previously active session OR securely stored last user.
  Future<void> loginWithBiometrics(BiometricAuthService biometricService) async {
    try {
      state = const AuthStateLoading();
      
      final isSupported = await biometricService.isDeviceSupported();
      if (!isSupported) {
        throw Exception('Biometrics not supported on this device');
      }

      final authenticated = await biometricService.authenticate();
      if (!authenticated) {
        state = const AuthStateUnauthenticated();
        return;
      }

      // 1. Try active session
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthStateAuthenticated(user);
        return;
      }

      // 2. Try restoring last user from secure storage (Offline Mode)
      final lastUser = await _storageService.getLastUser();
      if (lastUser != null) {
        // Create an AuthUser instance manually
        final restoredUser = AuthUser(
          id: lastUser['id']!,
          email: lastUser['email']!,
          createdAt: DateTime.now(), // Fallback
        );
        state = AuthStateAuthenticated(restoredUser);
      } else {
        state = const AuthStateError('No saved session found. Please login online first.');
      }
    } catch (e) {
      state = AuthStateError(e.toString());
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
  final storageService = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(repository, storageService);
});