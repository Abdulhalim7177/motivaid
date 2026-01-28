import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/units/models/unit.dart';
import 'package:motivaid/core/units/repositories/unit_repository.dart';
import 'package:motivaid/core/units/repositories/supabase_unit_repository.dart';

/// Unit repository provider
final unitRepositoryProvider = Provider<UnitRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseUnitRepository(supabase);
});

/// All units provider
final unitsProvider = FutureProvider<List<Unit>>((ref) async {
  final repository = ref.watch(unitRepositoryProvider);
  return repository.getAllUnits();
});

/// Units by facility provider
final unitsByFacilityProvider = FutureProvider.family<List<Unit>, String>((ref, facilityId) async {
  final repository = ref.watch(unitRepositoryProvider);
  return repository.getUnitsByFacility(facilityId);
});

/// Unit by ID provider
final unitByIdProvider = FutureProvider.family<Unit?, String>((ref, id) async {
  final repository = ref.watch(unitRepositoryProvider);
  return repository.getUnitById(id);
});
