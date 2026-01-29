import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/facilities/models/facility.dart';
import 'package:motivaid/core/facilities/providers/facility_provider.dart';
import 'package:motivaid/features/supervisor/screens/supervisor_approval_screen.dart'; // Reuse provider
import 'package:motivaid/core/units/providers/unit_provider.dart';
import 'package:motivaid/core/units/providers/unit_membership_provider.dart';

class MyFacilitiesScreen extends ConsumerWidget {
  const MyFacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facilityIdsAsync = ref.watch(supervisorFacilityIdsProvider);
    final allFacilitiesAsync = ref.watch(facilitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Facilities')),
      body: facilityIdsAsync.when(
        data: (ids) {
          if (ids.isEmpty) {
            return const Center(child: Text('No facilities assigned.'));
          }

          return allFacilitiesAsync.when(
            data: (allFacilities) {
              final myFacilities = allFacilities.where((f) => ids.contains(f.id)).toList();
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: myFacilities.length,
                itemBuilder: (context, index) {
                  return _FacilityCard(facility: myFacilities[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _FacilityCard extends ConsumerWidget {
  final Facility facility;

  const _FacilityCard({required this.facility});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can fetch stats here if needed
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const CircleAvatar(child: Icon(Icons.local_hospital)),
        title: Text(facility.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(facility.location ?? facility.address ?? 'Healthcare Facility'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Staff Members', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _StaffList(facilityId: facility.id),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _StaffList extends ConsumerWidget {
  final String facilityId;

  const _StaffList({required this.facilityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic to fetch staff in this facility
    // We need to fetch units in this facility, then memberships in those units.
    final unitsAsync = ref.watch(unitsByFacilityProvider(facilityId));

    return unitsAsync.when(
      data: (units) {
        if (units.isEmpty) return const Text('No units in this facility.');
        
        return Column(
          children: units.map((unit) {
            final membershipsAsync = ref.watch(membershipsByUnitProvider(unit.id));
            
            return membershipsAsync.when(
              data: (memberships) {
                final approved = memberships.where((m) => m.isApproved).toList();
                if (approved.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      color: Colors.grey[100],
                      width: double.infinity,
                      child: Text('${unit.name} (${approved.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...approved.map((m) => ListTile(
                      dense: true,
                      leading: Icon(
                        m.role.value == 'supervisor' ? Icons.security : Icons.person,
                        size: 16,
                      ),
                      title: FutureBuilder(
                        // We need profile info. Usually included or fetch separate.
                        // For MVP, we might show ID or fetch profile name.
                        // Assuming getting profile name requires another fetch if not joined.
                        future: Future.value(m.profileId), // Placeholder
                        builder: (c, s) => Text('Staff ID: ${m.profileId.substring(0, 8)}...'),
                      ),
                      subtitle: Text(m.role.value),
                    )),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading staff: $e'),
            );
          }).toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Error loading units: $e'),
    );
  }
}
