import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motivaid/core/units/models/unit_membership.dart';
import 'package:motivaid/core/units/repositories/unit_membership_repository.dart';

/// Supabase implementation of unit membership repository
class SupabaseUnitMembershipRepository implements UnitMembershipRepository {
  final SupabaseClient _supabase;

  SupabaseUnitMembershipRepository(this._supabase);

  @override
  Future<List<UnitMembership>> getMembershipsByProfile(String profileId) async {
    try {
      final response = await _supabase
          .from('unit_memberships')
          .select()
          .eq('profile_id', profileId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UnitMembership.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch memberships for profile: $e');
    }
  }

  @override
  Future<List<UnitMembership>> getMembershipsByUnit(String unitId) async {
    try {
      final response = await _supabase
          .from('unit_memberships')
          .select()
          .eq('unit_id', unitId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UnitMembership.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch memberships for unit: $e');
    }
  }

  @override
  Future<List<UnitMembership>> getPendingMembershipsByUnit(String unitId) async {
    try {
      final response = await _supabase
          .from('unit_memberships')
          .select()
          .eq('unit_id', unitId)
          .eq('status', 'pending')
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => UnitMembership.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending memberships: $e');
    }
  }

  @override
  Future<UnitMembership?> getMembership(String profileId, String unitId) async {
    try {
      final response = await _supabase
          .from('unit_memberships')
          .select()
          .eq('profile_id', profileId)
          .eq('unit_id', unitId)
          .maybeSingle();

      if (response == null) return null;
      return UnitMembership.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch membership: $e');
    }
  }

  @override
  Future<UnitMembership> createMembership(UnitMembership membership) async {
    try {
      final response = await _supabase
          .from('unit_memberships')
          .insert(membership.toJson())
          .select()
          .single();

      return UnitMembership.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create membership: $e');
    }
  }

  @override
  Future<UnitMembership> approveMembership(
    String membershipId,
    String approvedBy,
  ) async {
    try {
      final response = await _supabase
          .from('unit_memberships')
          .update({
            'status': 'approved',
            'approved_by': approvedBy,
            'approved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', membershipId)
          .select()
          .single();

      return UnitMembership.fromJson(response);
    } catch (e) {
      throw Exception('Failed to approve membership: $e');
    }
  }

  @override
  Future<UnitMembership> rejectMembership(
    String membershipId,
    String rejectionReason,
  ) async {
    try {
      final response = await _supabase
          .from('unit_memberships')
          .update({
            'status': 'rejected',
            'rejection_reason': rejectionReason,
          })
          .eq('id', membershipId)
          .select()
          .single();

      return UnitMembership.fromJson(response);
    } catch (e) {
      throw Exception('Failed to reject membership: $e');
    }
  }

  @override
  Future<UnitMembership> updateMembership(UnitMembership membership) async {
    try {
      final response = await _supabase
          .from('unit_memberships')
          .update(membership.toJson())
          .eq('id', membership.id)
          .select()
          .single();

      return UnitMembership.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update membership: $e');
    }
  }

  @override
  Future<void> deleteMembership(String membershipId) async {
    try {
      await _supabase.from('unit_memberships').delete().eq('id', membershipId);
    } catch (e) {
      throw Exception('Failed to delete membership: $e');
    }
  }
}
