import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/widgets/risk_badge.dart';
import 'package:motivaid/features/patients/models/patient.dart';
import 'package:motivaid/features/patients/repositories/patient_repository.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabasePatientRepository(supabase);
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
  // Get all patients for this midwife
  final patients = await repository.getPatients(midwifeId: user.id);
  // Take top 5 recent
  return patients.take(5).toList();
});
