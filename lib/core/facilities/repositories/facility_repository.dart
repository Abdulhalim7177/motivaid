import 'package:motivaid/core/facilities/models/facility.dart';

/// Facility repository interface
abstract class FacilityRepository {
  /// Get all facilities
  Future<List<Facility>> getAllFacilities();

  /// Get facility by ID
  Future<Facility?> getFacilityById(String id);

  /// Create new facility
  Future<Facility> createFacility(Facility facility);

  /// Update facility
  Future<Facility> updateFacility(Facility facility);

  /// Delete facility
  Future<void> deleteFacility(String id);
}
