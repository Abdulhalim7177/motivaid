/// User role enum
enum UserRole {
  midwife('midwife'),
  supervisor('supervisor'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.midwife,
    );
  }
}

/// Membership status enum  
enum MembershipStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const MembershipStatus(this.value);

  static MembershipStatus fromString(String value) {
    return MembershipStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MembershipStatus.pending,
    );
  }
}

/// Unit membership model - Links users to units with role and approval
class UnitMembership {
  final String id;
  final String profileId;
  final String unitId;
  final UserRole role;
  final MembershipStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnitMembership({
    required this.id,
    required this.profileId,
    required this.unitId,
    required this.role,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory UnitMembership.fromJson(Map<String, dynamic> json) {
    return UnitMembership(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      unitId: json['unit_id'] as String,
      role: UserRole.fromString(json['role'] as String),
      status: MembershipStatus.fromString(json['status'] as String),
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'profile_id': profileId,
      'unit_id': unitId,
      'role': role.value,
      'status': status.value,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }

  /// Copy with
  UnitMembership copyWith({
    String? id,
    String? profileId,
    String? unitId,
    UserRole? role,
    MembershipStatus? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnitMembership(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      unitId: unitId ?? this.unitId,
      role: role ?? this.role,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == MembershipStatus.pending;
  bool get isApproved => status == MembershipStatus.approved;
  bool get isRejected => status == MembershipStatus.rejected;
  bool get isSupervisor => role == UserRole.supervisor;
  bool get isAdmin => role == UserRole.admin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitMembership &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UnitMembership(id: $id, unitId: $unitId, role: ${role.value}, status: ${status.value})';
}
