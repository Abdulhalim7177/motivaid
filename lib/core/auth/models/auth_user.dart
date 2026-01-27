import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents an authenticated user in the application
class AuthUser {
  final String id;
  final String email;
  final DateTime? createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.createdAt,
  });

  /// Create AuthUser from Supabase User
  factory AuthUser.fromSupabaseUser(User user) {
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() => 'AuthUser(id: $id, email: $email)';
}
