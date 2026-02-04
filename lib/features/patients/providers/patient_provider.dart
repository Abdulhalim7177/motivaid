import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/widgets/risk_badge.dart';
import 'package:motivaid/features/patients/models/patient.dart';
import 'package:motivaid/features/patients/repositories/patient_repository.dart';
import 'package:motivaid/features/patients/repositories/offline_patient_repository.dart';
import 'package:motivaid/core/data/local/database_helper.dart';
import 'package:motivaid/core/data/sync/sync_queue_repository.dart';
import 'package:motivaid/core/network/network_info.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteRepo = SupabasePatientRepository(supabase);
  final localDb = DatabaseHelper.instance;
  final syncQueue = SyncQueueRepository();
  final networkInfo = NetworkInfoImpl();
  
  return OfflinePatientRepository(remoteRepo, localDb, syncQueue, networkInfo);
});

// Stats Providers for Dashboard

final activePatientCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final user = authState is AuthStateAuthenticated ? authState.user : null;
  if (user == null) return 0;
  
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getActivePatientCount(user.id);
});

final riskStatsProvider = FutureProvider.autoDispose<Map<RiskLevel, int>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final user = authState is AuthStateAuthenticated ? authState.user : null;
  if (user == null) return {RiskLevel.high: 0, RiskLevel.medium: 0, RiskLevel.low: 0};
  
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getRiskLevelStats(user.id);
});

final recentPatientsProvider = FutureProvider.autoDispose<List<Patient>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final user = authState is AuthStateAuthenticated ? authState.user : null;
  if (user == null) return [];
  
  final repository = ref.watch(patientRepositoryProvider);
  final patients = await repository.getPatients(midwifeId: user.id);
  return patients.take(5).toList();
});

final allPatientsProvider = FutureProvider.autoDispose<List<Patient>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final user = authState is AuthStateAuthenticated ? authState.user : null;
  if (user == null) return [];
  
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getPatients(midwifeId: user.id);
});

final patientDetailProvider = FutureProvider.autoDispose.family<Patient?, String>((ref, patientId) async {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getPatient(patientId);
});

final patientNotifierProvider = Provider<PatientNotifier>((ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return PatientNotifier(repository);
});

class PatientNotifier extends StateNotifier<AsyncValue<void>> {
  final PatientRepository _repository;
  
  PatientNotifier(this._repository) : super(const AsyncValue.data(null));
  
  Future<Patient> createPatient(Patient patient) async {
    state = const AsyncValue.loading();
    final result = await _repository.createPatient(patient);
    state = const AsyncValue.data(null);
    return result;
  }
  
  Future<Patient> updatePatient(Patient patient) async {
    state = const AsyncValue.loading();
    final result = await _repository.updatePatient(patient);
    state = const AsyncValue.data(null);
    return result;
  }
  
  Future<void> deletePatient(String id) async {
    state = const AsyncValue.loading();
    await _repository.deletePatient(id);
    state = const AsyncValue.data(null);
  }
}
