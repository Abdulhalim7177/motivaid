import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motivaid/core/units/models/unit.dart';
import 'package:motivaid/core/units/repositories/unit_repository.dart';

/// Supabase implementation of unit repository
class SupabaseUnitRepository implements UnitRepository {
  final SupabaseClient _supabase;

  SupabaseUnitRepository(this._supabase);

  @override
  Future<List<Unit>> getAllUnits() async {
    try {
      final response = await _supabase
          .from('units')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Unit.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch units: $e');
    }
  }

  @override
  Future<List<Unit>> getUnitsByFacility(String facilityId) async {
    try {
      final response = await _supabase
          .from('units')
          .select()
          .eq('facility_id', facilityId)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Unit.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch units for facility: $e');
    }
  }

  @override
  Future<Unit?> getUnitById(String id) async {
    try {
      final response = await _supabase
          .from('units')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Unit.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch unit: $e');
    }
  }

  @override
  Future<Unit> createUnit(Unit unit) async {
    try {
      final response = await _supabase
          .from('units')
          .insert(unit.toJson())
          .select()
          .single();

      return Unit.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create unit: $e');
    }
  }

  @override
  Future<Unit> updateUnit(Unit unit) async {
    try {
      final response = await _supabase
          .from('units')
          .update(unit.toJson())
          .eq('id', unit.id)
          .select()
          .single();

      return Unit.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update unit: $e');
    }
  }

  @override
  Future<void> deleteUnit(String id) async {
    try {
      await _supabase.from('units').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete unit: $e');
    }
  }
}
