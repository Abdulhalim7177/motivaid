import 'package:motivaid/core/units/models/unit.dart';

/// Unit repository interface
abstract class UnitRepository {
  /// Get all units
  Future<List<Unit>> getAllUnits();

  /// Get units by facility ID
  Future<List<Unit>> getUnitsByFacility(String facilityId);

  /// Get unit by ID
  Future<Unit?> getUnitById(String id);

  /// Create new unit
  Future<Unit> createUnit(Unit unit);

  /// Update unit
  Future<Unit> updateUnit(Unit unit);

  /// Delete unit
  Future<void> deleteUnit(String id);
}
