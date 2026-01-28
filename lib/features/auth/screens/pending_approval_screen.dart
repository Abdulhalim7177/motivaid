import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/units/providers/unit_membership_provider.dart';

/// Screen showing user's pending approval status
class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(userMembershipsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Status'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 80,
                color: Colors.orange[700],
              ),
              const SizedBox(height: 24),
              Text(
                'Awaiting Approval',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'A supervisor will review your registration and assign you to a facility and unit.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Show membership status (will be empty for new users)
              membershipsAsync.when(
                data: (memberships) {
                  if (memberships.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.pending_actions, size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 12),
                          Text(
                            'No facility assignment yet',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Waiting for supervisor to assign you',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  // If they have memberships, show them
                  final pending = memberships.where((m) => m.isPending).toList();
                  final approved = memberships.where((m) => m.isApproved).toList();
                  final rejected = memberships.where((m) => m.isRejected).toList();

                  return Column(
                    children: [
                      if (approved.isNotEmpty) ...[
                        const Text(
                          'Approved assignments:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 8),
                        ...approved.map((m) => Card(
                              color: Colors.green[50],
                              child: ListTile(
                                leading: const Icon(Icons.check_circle, color: Colors.green),
                                title: const Text('Unit membership'),
                                subtitle: Text('Role: ${m.role.value}'),
                              ),
                            )),
                      ],
                      if (pending.isNotEmpty) ...[
                        const Text(
                          'Pending assignments:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...pending.map((m) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.pending, color: Colors.orange),
                                title: const Text('Unit membership'),
                                subtitle: Text('Role: ${m.role.value}'),
                                trailing: const Icon(Icons.access_time),
                              ),
                            )),
                      ],
                      if (rejected.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Rejected assignments:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ...rejected.map((m) => Card(
                              color: Colors.red[50],
                              child: ListTile(
                                leading: const Icon(Icons.cancel, color: Colors.red),
                                title: const Text('Unit membership'),
                                subtitle: Text(
                                  m.rejectionReason ?? 'No reason provided',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            )),
                      ],
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),

              const SizedBox(height: 32),
              Text(
                'You will be notified once your account is approved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Logout button
              ElevatedButton.icon(
                onPressed: () async {
                  // Sign out using auth provider
                  await ref.read(authNotifierProvider.notifier).signOut();
                  // Navigation will happen automatically via AuthGate
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
