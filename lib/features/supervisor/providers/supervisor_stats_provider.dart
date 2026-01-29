import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';

class SupervisorStatsRepository {
  final SupabaseClient _supabase;

  SupervisorStatsRepository(this._supabase);

  Future<int> getPendingApprovalsCount(String userId) async {
    // 1. Get units where user is supervisor
    final memberships = await _supabase
        .from('unit_memberships')
        .select('unit_id')
        .eq('profile_id', userId)
        .eq('role', 'supervisor')
        .eq('status', 'approved');
        
    final unitIds = memberships
        .map((e) => e['unit_id'] as String)
        .toSet()
        .toList();
        
    if (unitIds.isEmpty) return 0;
    
    // 2. Count pending memberships in those units
    final count = await _supabase
        .from('unit_memberships')
        .count(CountOption.exact)
        .eq('status', 'pending')
        .inFilter('unit_id', unitIds);
        
    return count;
  }

  Future<Map<String, int>> getFacilityOverview(String userId) async {
    // 1. Get units and facilities where user is supervisor
    final memberships = await _supabase
        .from('unit_memberships')
        .select('unit_id, units(facility_id)')
        .eq('profile_id', userId)
        .eq('role', 'supervisor')
        .eq('status', 'approved');
        
    final unitIds = memberships
        .map((e) => e['unit_id'] as String)
        .toSet()
        .toList();

    final facilityIds = memberships
        .map((e) => (e['units'] as Map<String, dynamic>)['facility_id'] as String)
        .toSet()
        .toList();

    if (unitIds.isEmpty) return {'midwives': 0, 'cases': 0};

    // 2. Count midwives in my units
    final midWivesCount = await _supabase
        .from('unit_memberships')
        .count(CountOption.exact)
        .eq('role', 'midwife')
        .eq('status', 'approved')
        .inFilter('unit_id', unitIds);

    // 3. Count active cases in my facilities
    // Patients table has facility_id directly
    final casesCount = await _supabase
        .from('patients')
        .count(CountOption.exact)
        .inFilter('facility_id', facilityIds)
        .eq('status', 'Active');
        
    return {
      'midwives': midWivesCount,
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
