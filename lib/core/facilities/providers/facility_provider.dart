import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/facilities/models/facility.dart';
import 'package:motivaid/core/facilities/repositories/facility_repository.dart';
import 'package:motivaid/core/facilities/repositories/supabase_facility_repository.dart';

/// Facility repository provider
final facilityRepositoryProvider = Provider<FacilityRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseFacilityRepository(supabase);
});

/// All facilities provider
final facilitiesProvider = FutureProvider<List<Facility>>((ref) async {
  final repository = ref.watch(facilityRepositoryProvider);
  return repository.getAllFacilities();
});

/// Facility by ID provider
final facilityByIdProvider = FutureProvider.family<Facility?, String>((ref, id) async {
  final repository = ref.watch(facilityRepositoryProvider);
  return repository.getFacilityById(id);
});
