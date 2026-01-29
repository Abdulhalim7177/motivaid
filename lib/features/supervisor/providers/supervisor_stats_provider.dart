import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';

class SupervisorStatsRepository {
  final SupabaseClient _supabase;

  SupervisorStatsRepository(this._supabase);

  Future<int> getPendingApprovalsCount(String userId) async {
    // 1. Get facilities where user is supervisor
    final memberships = await _supabase
        .from('unit_memberships')
        .select('units(facility_id)')
        .eq('profile_id', userId)
        .eq('role', 'supervisor')
        .eq('status', 'approved');
        
    final facilityIds = memberships
        .map((e) => (e['units'] as Map<String, dynamic>)['facility_id'] as String)
        .toSet() // Use Set to remove duplicates
        .toList();
        
    if (facilityIds.isEmpty) return 0;
    
    // 2. Count pending memberships in those facilities
    // We filter by joining with units table
    final response = await _supabase
        .from('unit_memberships')
        .select('*, units!inner(facility_id)')
        .eq('status', 'pending')
        .filter('units.facility_id', 'in', '(${facilityIds.join(',')})')
        .count(CountOption.exact);
        
    return response.count;
  }

  Future<Map<String, int>> getFacilityOverview(String userId) async {
    // 1. Get facilities
    final memberships = await _supabase
        .from('unit_memberships')
        .select('units(facility_id)')
        .eq('profile_id', userId)
        .eq('role', 'supervisor')
        .eq('status', 'approved');
        
    final facilityIds = memberships
        .map((e) => (e['units'] as Map<String, dynamic>)['facility_id'] as String)
        .toSet()
        .toList();

    if (facilityIds.isEmpty) return {'midwives': 0, 'cases': 0};

    // 2. Count midwives
    final midWivesResponse = await _supabase
        .from('unit_memberships')
        .select('*, units!inner(facility_id)')
        .eq('role', 'midwife')
        .eq('status', 'approved')
        .filter('units.facility_id', 'in', '(${facilityIds.join(',')})')
        .count(CountOption.exact);

    // 3. Count active cases
    // Patients table has facility_id directly
    final casesCount = await _supabase
        .from('patients')
        .count(CountOption.exact)
        .inFilter('facility_id', facilityIds)
        .eq('status', 'Active');
        
    return {
      'midwives': midWivesResponse.count,
      'cases': casesCount,
    };
  }
}

final supervisorStatsRepositoryProvider = Provider<SupervisorStatsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupervisorStatsRepository(supabase);
});

final pendingApprovalsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final user = authState is AuthStateAuthenticated ? authState.user : null;
  if (user == null) return 0;
  return ref.watch(supervisorStatsRepositoryProvider).getPendingApprovalsCount(user.id);
});

final facilityOverviewProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final user = authState is AuthStateAuthenticated ? authState.user : null;
  if (user == null) return {'midwives': 0, 'cases': 0};
  return ref.watch(supervisorStatsRepositoryProvider).getFacilityOverview(user.id);
});
