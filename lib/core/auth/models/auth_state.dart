import 'package:motivaid/core/auth/models/auth_user.dart';

/// Represents the authentication state of the application
sealed class AuthState {
  const AuthState();
}

/// Initial/loading state - checking authentication
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// User is authenticated
class AuthStateAuthenticated extends AuthState {
  final AuthUser user;

  const AuthStateAuthenticated(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateAuthenticated &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}

/// User is not authenticated
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// Authentication error occurred
class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
