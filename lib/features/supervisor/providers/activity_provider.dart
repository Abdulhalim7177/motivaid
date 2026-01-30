import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';

class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String type; // 'pending_user', 'approved_user', or 'new_patient'

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

  // 2. Fetch User Creation Waiting for Approval in my units
  if (unitIds.isNotEmpty) {
    final pendingMembershipsResponse = await supabase
        .from('unit_memberships')
        .select('id, created_at, updated_at, profiles!unit_memberships_profile_id_fkey(full_name, email)')
        .inFilter('unit_id', unitIds)
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .limit(5);

    for (final m in pendingMembershipsResponse as List) {
      final profile = m['profiles!unit_memberships_profile_id_fkey'] as Map<String, dynamic>?;
      final name = profile != null
          ? (profile['full_name'] ?? profile['email'] ?? 'Unknown User')
          : 'Unknown User';

      activities.add(ActivityItem(
        id: m['id'],
        title: 'New User Awaiting Approval',
        subtitle: '$name has requested access to your facility',
        timestamp: DateTime.parse(m['created_at']),
        type: 'pending_user',
      ));
    }
  }

  // 3. Fetch User Approvals by the Supervisor in my units
  if (unitIds.isNotEmpty) {
    final approvedMembershipsResponse = await supabase
        .from('unit_memberships')
        .select('id, created_at, updated_at, profiles!unit_memberships_profile_id_fkey(full_name, email), role')
        .inFilter('unit_id', unitIds)
        .eq('status', 'approved')
        .order('updated_at', ascending: false)
        .limit(5);

    for (final m in approvedMembershipsResponse as List) {
      // Filter for records where updated_at > created_at (indicating an update/approval)
      final createdAt = DateTime.parse(m['created_at']);
      final updatedAt = DateTime.parse(m['updated_at']);

      if (updatedAt.isAfter(createdAt)) {
        final profile = m['profiles!unit_memberships_profile_id_fkey'] as Map<String, dynamic>?;
        final name = profile != null
            ? (profile['full_name'] ?? profile['email'] ?? 'Unknown User')
            : 'Unknown User';
        final role = m['role'] ?? 'Unknown Role';

        activities.add(ActivityItem(
          id: m['id'],
          title: 'User Approved',
          subtitle: '$name has been approved as $role',
          timestamp: updatedAt,
          type: 'approved_user',
        ));
      }
    }
  }

  // 4. Fetch Patient Additions by Members of the Same Facility
  if (facilityIds.isNotEmpty) {
    final patientsResponse = await supabase
        .from('patients')
        .select('id, full_name, created_at, updated_at, midwife_id, profiles(full_name )')
        .inFilter('facility_id', facilityIds)
        .order('created_at', ascending: false)
        .limit(5);

    for (final p in patientsResponse as List) {
      final patientName = p['full_name'];
      final profile = p['profiles'] as Map<String, dynamic>?;
      final midwifeName = profile != null ? profile['midwife_name'] : 'Unknown';

      activities.add(ActivityItem(
        id: p['id'],
        title: 'New Patient Added',
        subtitle: '$patientName added by $midwifeName',
        timestamp: DateTime.parse(p['created_at']),
        type: 'new_patient',
      ));
    }
  }

  // 5. Sort and limit
  activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return activities.take(10).toList();
});
