import 'package:motivaid/core/units/models/unit_membership.dart';

/// Unit membership repository interface
abstract class UnitMembershipRepository {
  /// Get all memberships for a profile
  Future<List<UnitMembership>> getMembershipsByProfile(String profileId);

  /// Get all memberships for a unit
  Future<List<UnitMembership>> getMembershipsByUnit(String unitId);

  /// Get pending memberships for a unit (for supervisor approval)
  Future<List<UnitMembership>> getPendingMembershipsByUnit(String unitId);

  /// Get a specific membership
  Future<UnitMembership?> getMembership(String profileId, String unitId);

  /// Create membership request
  Future<UnitMembership> createMembership(UnitMembership membership);

  /// Approve membership
  Future<UnitMembership> approveMembership(
    String membershipId,
    String approvedBy,
  );

  /// Reject membership
  Future<UnitMembership> rejectMembership(
    String membershipId,
    String rejectionReason,
  );

  /// Update membership
  Future<UnitMembership> updateMembership(UnitMembership membership);

  /// Delete membership
  Future<void> deleteMembership(String membershipId);
}
