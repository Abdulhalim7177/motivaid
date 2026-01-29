import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/theme/app_theme.dart';
import 'package:motivaid/core/widgets/gradient_card.dart';
import 'package:motivaid/core/widgets/stat_card.dart';
import 'package:motivaid/core/widgets/risk_badge.dart';
import 'package:motivaid/core/widgets/gradient_button.dart';
import 'package:motivaid/core/profile/providers/profile_provider.dart';
import 'package:motivaid/core/profile/models/user_profile.dart';
import 'package:motivaid/features/patients/providers/patient_provider.dart';
import 'package:motivaid/core/navigation/app_router.dart';

/// Midwife Dashboard Screen
class MidwifeDashboard extends ConsumerWidget {
  const MidwifeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) => _buildDashboard(context, ref, profile),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, UserProfile? profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(profile),
          const SizedBox(height: 24),
          
          // Active Cases Card
          _buildActiveCasesCard(ref),
          const SizedBox(height: 20),
          
          // Action Buttons
          _buildActionButtons(context),
          const SizedBox(height: 24),
          
          // Recent Cases
          _buildRecentCases(ref),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfile? profile) {
    final userName = profile?.fullName ?? 'Midwife';
    final facility = profile?.primaryFacilityId ?? 'City Hospital'; // TODO: Fetch facility name
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Midwife',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const Text(' • ', style: TextStyle(color: AppColors.textLight)),
                  Expanded(
                    child: Text(
                      facility,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
          child: const Icon(
            Icons.person,
            color: AppColors.primaryPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCasesCard(WidgetRef ref) {
    final activeCountAsync = ref.watch(activePatientCountProvider);
    final riskStatsAsync = ref.watch(riskStatsProvider);

    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder_open,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Active Cases',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          activeCountAsync.when(
            data: (count) => Text(
              '$count',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            loading: () => const Text('...', style: TextStyle(fontSize: 48, color: Colors.white54)),
            error: (error, stack) => const Text('0', style: TextStyle(fontSize: 48, color: Colors.white)),
          ),
          const SizedBox(height: 20),
          
          // Stats Row
          riskStatsAsync.when(
            data: (stats) => Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: '${stats[RiskLevel.high] ?? 0}',
                    label: 'High Risk',
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    value: '${stats[RiskLevel.low] ?? 0}',
                    label: 'Low Risk',
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(color: Colors.white))),
            error: (error, stack) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            text: 'New Case',
            icon: Icons.add,
            onPressed: () {
              // TODO: Navigate to new case screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New Case - Coming soon')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryPurple, width: 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to training
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Training - Coming soon')),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Training',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCases(WidgetRef ref) {
    final recentPatientsAsync = ref.watch(recentPatientsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Cases', style: AppTextStyles.heading3),
            TextButton(
              onPressed: () {
                ref.read(routerProvider).push('/patients');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        recentPatientsAsync.when(
          data: (patients) {
            if (patients.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No recent cases found.',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
              );
            }
            return Column(
              children: patients.map((patient) => _buildCaseCard(
                name: patient.fullName,
                age: patient.age ?? 0,
                gravida: 0, // Not in model yet
                para: 0, // Not in model yet
                risk: patient.riskLevel,
                timeAgo: 'Updated recently', // Could format updatedAt
                status: patient.status.label,
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error loading cases: $e'),
        ),
      ],
    );
  }

  Widget _buildCaseCard({
    required String name,
    required int age,
    required int gravida,
    required int para,
    required RiskLevel risk,
    required String timeAgo,
    required String status,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to case details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.heading3.copyWith(fontSize: 18),
                    ),
                  ),
                  RiskBadge(risk: risk),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$age years${gravida > 0 ? ' • G$gravida P$para' : ''}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: AppTextStyles.caption,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
