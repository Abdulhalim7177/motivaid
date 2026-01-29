import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/profile/models/user_profile.dart';
import 'package:motivaid/core/profile/providers/profile_provider.dart';
import 'package:motivaid/core/facilities/providers/facility_provider.dart';
import 'package:motivaid/core/units/models/unit_membership.dart';
import 'package:motivaid/core/units/providers/unit_provider.dart';
import 'package:motivaid/core/units/providers/unit_membership_provider.dart';

/// Provider to get supervisor's facility IDs
final supervisorFacilityIdsProvider = FutureProvider<List<String>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (authState is! AuthStateAuthenticated) return [];
  
  final supabase = ref.watch(supabaseClientProvider);
  
  final memberships = await supabase
      .from('unit_memberships')
      .select('units(facility_id)')
      .eq('profile_id', authState.user.id)
      .eq('role', 'supervisor')
      .eq('status', 'approved');
      
  return memberships
      .map((e) => (e['units'] as Map<String, dynamic>)['facility_id'] as String)
      .toSet()
      .toList();
});

/// Provider to get all profiles without approved memberships (pending users) IN supervisor's facilities
final pendingUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  final profileRepo = ref.watch(profileRepositoryProvider);
  final membershipRepo = ref.watch(unitMembershipRepositoryProvider);
  final facilityIds = await ref.watch(supervisorFacilityIdsProvider.future);
  
  if (facilityIds.isEmpty) return [];
  
  // Get all profiles
  // Optimization: If RLS is set correctly, getAllProfiles might only return visible ones.
  // But we filter explicitly by facility_id to be sure.
  final allProfiles = await profileRepo.getAllProfiles();
  
  // Filter to only users in my facilities without approved memberships
  final pendingUsers = <UserProfile>[];
  for (final profile in allProfiles) {
    if (profile.primaryFacilityId == null || !facilityIds.contains(profile.primaryFacilityId)) {
      continue;
    }

    final memberships = await membershipRepo.getMembershipsByProfile(profile.id);
    final hasApproved = memberships.any((m) => m.isApproved);
    if (!hasApproved) {
      pendingUsers.add(profile);
    }
  }
  
  return pendingUsers;
});

/// Supervisor approval screen
class SupervisorApprovalScreen extends ConsumerWidget {
  const SupervisorApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingUsersAsync = ref.watch(pendingUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending User Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(pendingUsersProvider),
          ),
        ],
      ),
      body: pendingUsersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No pending users',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No new users in your facilities',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserCard(user: user);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(pendingUsersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card widget for each pending user
class _UserCard extends ConsumerWidget {
  final UserProfile user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          child: Text(
            user.initials,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.fullName ?? user.email,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: const TextStyle(fontSize: 13)),
            if (user.phone != null && user.phone!.isNotEmpty)
              Text('📞 ${user.phone}', style: const TextStyle(fontSize: 13)),
          ],
        ),
        children: [
          _AssignmentForm(user: user),
        ],
      ),
    );
  }
}

/// Assignment form for assigning facility, unit, and role
class _AssignmentForm extends ConsumerStatefulWidget {
  final UserProfile user;

  const _AssignmentForm({required this.user});

  @override
  ConsumerState<_AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends ConsumerState<_AssignmentForm> {
  String? _selectedFacilityId;
  String? _selectedUnitId;
  UserRole _selectedRole = UserRole.midwife;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-select the user's facility preference if available
    _selectedFacilityId = widget.user.primaryFacilityId;
  }

  Future<void> _handleAssign() async {
    if (_selectedFacilityId == null || _selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select facility and unit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final membershipRepo = ref.read(unitMembershipRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      
      // Update user profile with facility and role
      await profileRepo.updateProfile(
        widget.user.copyWith(
          primaryFacilityId: _selectedFacilityId,
          role: _selectedRole,
        ),
      );

      // Get the current supervisor's ID
      final authState = ref.read(authNotifierProvider);
      final supervisorId = authState is AuthStateAuthenticated ? authState.user.id : null;

      // Create approved unit membership
      final membership = UnitMembership(
        id: '',
        profileId: widget.user.id,
        unitId: _selectedUnitId!,
        role: _selectedRole,
        status: MembershipStatus.approved,
        approvedBy: supervisorId,
        approvedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await membershipRepo.createMembership(membership);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${widget.user.fullName ?? "User"} assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the pending users list
        ref.invalidate(pendingUsersProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show facilities the supervisor manages
    final supervisorFacilityIdsAsync = ref.watch(supervisorFacilityIdsProvider);
    final allFacilitiesAsync = ref.watch(facilitiesProvider);
    
    final unitsAsync = _selectedFacilityId != null
        ? ref.watch(unitsByFacilityProvider(_selectedFacilityId!))
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Assign to Facility & Unit',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Role selector
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: UserRole.midwife, child: Text('Midwife')),
              DropdownMenuItem(value: UserRole.supervisor, child: Text('Supervisor')),
              DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedRole = value);
              }
            },
          ),
          const SizedBox(height: 12),

          // Facility selector (filtered)
          supervisorFacilityIdsAsync.when(
            data: (myFacilityIds) => allFacilitiesAsync.when(
              data: (facilities) {
                final myFacilities = facilities.where((f) => myFacilityIds.contains(f.id)).toList();
                
                // If selected facility (from user pref) is not in my list, reset or show warning
                // But for now, we just show dropdown.
                
                return DropdownButtonFormField<String>(
                  value: _selectedFacilityId != null && myFacilityIds.contains(_selectedFacilityId) 
                      ? _selectedFacilityId 
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Facility',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select facility'),
                  items: myFacilities.map((f) {
                    return DropdownMenuItem(value: f.id, child: Text(f.name));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFacilityId = value;
                      _selectedUnitId = null;
                    });
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading facilities: $e', style: const TextStyle(color: Colors.red)),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error checking permissions: $e', style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 12),

          // Unit selector
          if (_selectedFacilityId != null && unitsAsync != null)
            unitsAsync.when(
              data: (units) => DropdownButtonFormField<String>(
                value: _selectedUnitId,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select unit'),
                items: units.map((u) {
                  return DropdownMenuItem(value: u.id, child: Text(u.name));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedUnitId = value);
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey),
              ),
              child: const Text('Select a facility first'),
            ),
          const SizedBox(height: 16),

          // Assign button
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _handleAssign,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
            label: Text(_isSubmitting ? 'Assigning...' : 'Assign User'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
