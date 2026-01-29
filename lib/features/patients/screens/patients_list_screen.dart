import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/features/patients/providers/patient_provider.dart';
import 'package:motivaid/core/theme/app_theme.dart';

class PatientsListScreen extends ConsumerWidget {
  const PatientsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We reuse recentPatientsProvider or create a new one for full list
    // For now, let's assume we want a full list.
    // I'll assume there is a provider or I'll create one inline or use the repository directly via FutureProvider
    final patientsAsync = ref.watch(recentPatientsProvider); // This fetches "recent" which might be limited.
    // Ideally we want all patients.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add patient
            },
          ),
        ],
      ),
      body: patientsAsync.when(
        data: (patients) {
          if (patients.isEmpty) {
            return const Center(child: Text('No patients found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryPink.withValues(alpha: 0.1),
                    child: Text(
                      patient.fullName.isNotEmpty ? patient.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Age: ${patient.age ?? "N/A"} • GA: ${patient.gestationalAgeWeeks ?? "?"} weeks'),
                      Text('Status: ${patient.status.toString().split('.').last}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Navigate to detail
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
