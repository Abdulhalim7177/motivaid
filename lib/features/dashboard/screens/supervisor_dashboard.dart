import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motivaid/core/theme/app_theme.dart';
import 'package:motivaid/core/widgets/gradient_card.dart';
import 'package:motivaid/core/widgets/gradient_button.dart';
import 'package:motivaid/core/profile/providers/profile_provider.dart';
import 'package:motivaid/core/profile/models/user_profile.dart';
import 'package:motivaid/features/supervisor/providers/supervisor_stats_provider.dart';

/// Supervisor Dashboard Screen
class SupervisorDashboard extends ConsumerWidget {
  const SupervisorDashboard({super.key});

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
          
          // Pending Approvals Card
          _buildPendingApprovalsCard(context, ref),
          const SizedBox(height: 16),
          
          // Facility Overview Card
          _buildFacilityOverviewCard(ref),
          const SizedBox(height: 20),
          
          // Action Buttons
          _buildActionButtons(context),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfile? profile) {
    final userName = profile?.fullName ?? 'Supervisor';
    final facility = profile?.primaryFacilityId ?? 'City Hospital';
    
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
                    'Supervisor',
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
            Icons.admin_panel_settings,
            color: AppColors.primaryPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingApprovalsCard(BuildContext context, WidgetRef ref) {
    final pendingCountAsync = ref.watch(pendingApprovalsCountProvider);

    return GradientCard(
      child: InkWell(
        onTap: () {
            // context.go('/supervisor/approvals'); 
            // Temporarily showing snackbar if route not ready or just go
            context.go('/supervisor/approvals');
        },
        borderRadius: BorderRadius.circular(20),
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
                    Icons.people_outline,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pending Approvals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white.withValues(alpha: 0.7),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            pendingCountAsync.when(
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
            const SizedBox(height: 8),
            
            Text(
              'New user requests awaiting approval',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityOverviewCard(WidgetRef ref) {
    final statsAsync = ref.watch(facilityOverviewProvider);
    
    final midwives = statsAsync.value?['midwives'] ?? 0;
    final cases = statsAsync.value?['cases'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Facility Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOverviewItem(
              icon: Icons.people,
              label: 'Total Midwives',
              value: '$midwives',
            ),
            const SizedBox(height: 12),
            _buildOverviewItem(
              icon: Icons.folder_open,
              label: 'Active Cases',
              value: '$cases',
            ),
            const SizedBox(height: 12),
            _buildOverviewItem(
              icon: Icons.trending_up,
              label: 'This Month',
              value: '156 deliveries', // Mock for now (needs events table)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryPurple,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            text: 'Approvals',
            icon: Icons.how_to_reg,
            onPressed: () => context.go('/supervisor/approvals'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reports - Coming soon')),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reports',
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

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Activity', style: AppTextStyles.heading3),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all activity
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Activity Items (mock data)
        // TODO: Real Activity Logs
        _buildActivityItem(
          icon: Icons.person_add,
          title: 'New user: Sarah Jones',
          subtitle: 'Pending approval',
          time: '2h ago',
        ),
        const SizedBox(height: 12),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Real activity logs coming soon...", style: TextStyle(color: Colors.grey))
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
