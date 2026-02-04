import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/data/sync/sync_queue_repository.dart';
import 'package:motivaid/core/data/sync/sync_service.dart';
import 'package:motivaid/core/network/network_info.dart';
import 'package:motivaid/features/patients/repositories/patient_repository.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/services/notification_service.dart';

// We need the REMOTE repository specifically for the SyncService,
// but `patientRepositoryProvider` returns the Offline one.
// We should expose the remote repository separately or cast it?
// Or better, define a `remotePatientRepositoryProvider`.

final remotePatientRepositoryProvider = Provider<PatientRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabasePatientRepository(supabase);
});

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final syncQueue = ref.watch(syncQueueRepositoryProvider);
  final remotePatientRepo = ref.watch(remotePatientRepositoryProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  
  return SyncService(syncQueue, remotePatientRepo, networkInfo, notificationService);
});
