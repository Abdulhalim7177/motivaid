import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';

class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String type; // 'patient' or 'membership'

  ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });
}

final supervisorActivityProvider = FutureProvider.autoDispose<List<ActivityItem>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final authState = ref.watch(authNotifierProvider);
  
  // Reuse logic to get supervisor's units/facilities
  // Or fetch fresh.
  // Getting facility IDs is safer for "Recent Activity" if it includes patient data.
  
  if (authState is! AuthStateAuthenticated) return [];
  final userId = authState.user.id;

  // 1. Get supervisor's units and facilities
  final memberships = await supabase
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
      
  if (unitIds.isEmpty && facilityIds.isEmpty) return [];

  final activities = <ActivityItem>[];

  // 2. Fetch Recent Patients (Admissions) in my facilities
  if (facilityIds.isNotEmpty) {
    // We select basic info
    final patientsResponse = await supabase
        .from('patients')
        .select('id, full_name, status, updated_at, created_at')
        .inFilter('facility_id', facilityIds)
        .order('updated_at', ascending: false)
        .limit(5);
        
    for (final p in patientsResponse as List) {
      final isNew = p['created_at'] == p['updated_at'];
      activities.add(ActivityItem(
        id: p['id'],
        title: isNew ? 'New Patient: ${p['full_name']}' : 'Patient Updated: ${p['full_name']}',
        subtitle: 'Status: ${p['status']}',
        timestamp: DateTime.parse(p['updated_at']),
        type: 'patient',
      ));
    }
  }

  // 3. Fetch Recent Membership Requests in my units
  if (unitIds.isNotEmpty) {
    // We need profile info too
    final membershipsResponse = await supabase
        .from('unit_memberships')
        .select('id, status, created_at, updated_at, profiles(email, full_name)')
        .inFilter('unit_id', unitIds)
        .order('updated_at', ascending: false)
        .limit(5);

    for (final m in membershipsResponse as List) {
      final profile = m['profiles'] as Map<String, dynamic>;
      final name = profile['full_name'] ?? profile['email'];
      final status = m['status'];
      
      activities.add(ActivityItem(
        id: m['id'],
        title: 'Staff Update: $name',
        subtitle: 'Membership is $status',
        timestamp: DateTime.parse(m['updated_at']),
        type: 'membership',
      ));
    }
  }

  // 4. Sort and limit
  activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return activities.take(10).toList();
});
