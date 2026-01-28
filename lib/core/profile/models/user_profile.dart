import 'package:motivaid/core/auth/models/auth_user.dart';
import 'package:motivaid/core/units/models/unit_membership.dart';

/// User profile model with extended information
class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? bio;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final UserRole role;
  final String? primaryFacilityId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.bio,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.role = UserRole.midwife,
    this.primaryFacilityId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserProfile from AuthUser (minimal info)
  factory UserProfile.fromAuthUser(AuthUser user) {
    return UserProfile(
      id: user.id,
      email: user.email,
      createdAt: user.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      role: json['role'] != null 
          ? UserRole.fromString(json['role'] as String)
          : UserRole.midwife,
      primaryFacilityId: json['primary_facility_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'bio': bio,
      'phone': phone,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'role': role.value,
      'primary_facility_id': primaryFacilityId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? bio,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    UserRole? role,
    String? primaryFacilityId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      primaryFacilityId: primaryFacilityId ?? this.primaryFacilityId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get user initials for avatar
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() => 'UserProfile(id: $id, email: $email, fullName: $fullName)';
}
