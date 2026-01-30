import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motivaid/core/theme/app_theme.dart';
import 'package:motivaid/core/widgets/risk_badge.dart';
import 'package:motivaid/features/patients/models/patient.dart';
import 'package:motivaid/features/patients/providers/patient_provider.dart';

class PatientDetailScreen extends ConsumerWidget {
  final String patientId;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientDetailProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.pushNamed('edit-patient', pathParameters: {'id': patientId});
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Patient'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: patientAsync.when(
        data: (patient) {
          if (patient == null) {
            return const Center(child: Text('Patient not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            patient.fullName.isNotEmpty
                                ? patient.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        patient.fullName,
                        style: AppTextStyles.heading2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      RiskBadge(risk: patient.riskLevel),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildInfoCard(
                  context,
                  'Personal Information',
                  [
                    _buildInfoRow(Icons.person_outline, 'Age', '${patient.age ?? 'N/A'} years'),
                    _buildInfoRow(Icons.child_care_outlined, 'Gestational Age', '${patient.gestationalAgeWeeks ?? 'N/A'} weeks'),
                    _buildInfoRow(Icons.verified_user_outlined, 'Status', patient.status.label),
                  ],
                ),
                const SizedBox(height: 16),

                _buildInfoCard(
                  context,
                  'Risk Assessment',
                  [
                    _buildInfoRow(Icons.warning_outlined, 'Risk Level', patient.riskLevel.label),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Last Assessment',
                        patient.lastAssessmentDate != null
                            ? DateFormat('MMM dd, yyyy').format(patient.lastAssessmentDate!)
                            : 'No assessment yet'),
                  ],
                ),
                const SizedBox(height: 16),

                _buildInfoCard(
                  context,
                  'Timeline',
                  [
                    _buildInfoRow(Icons.add_circle_outline, 'Registered',
                        DateFormat('MMM dd, yyyy').format(patient.createdAt)),
                    _buildInfoRow(Icons.update_outlined, 'Last Updated',
                        DateFormat('MMM dd, yyyy').format(patient.updatedAt)),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/patients/$patientId/edit');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Patient'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading patient: $e'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: const Text('Are you sure you want to delete this patient? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final notifier = ref.read(patientNotifierProvider);
                await notifier.deletePatient(patientId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Patient deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  ref.invalidate(allPatientsProvider);
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete patient: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
