import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motivaid/core/facilities/models/facility.dart';
import 'package:motivaid/core/facilities/repositories/facility_repository.dart';

/// Supabase implementation of facility repository
class SupabaseFacilityRepository implements FacilityRepository {
  final SupabaseClient _supabase;

  SupabaseFacilityRepository(this._supabase);

  @override
  Future<List<Facility>> getAllFacilities() async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Facility.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch facilities: $e');
    }
  }

  @override
  Future<Facility?> getFacilityById(String id) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Facility.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch facility: $e');
    }
  }

  @override
  Future<Facility> createFacility(Facility facility) async {
    try {
      final response = await _supabase
          .from('facilities')
          .insert(facility.toJson())
          .select()
          .single();

      return Facility.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create facility: $e');
    }
  }

  @override
  Future<Facility> updateFacility(Facility facility) async {
    try {
      final response = await _supabase
          .from('facilities')
          .update(facility.toJson())
          .eq('id', facility.id)
          .select()
          .single();

      return Facility.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update facility: $e');
    }
  }

  @override
  Future<void> deleteFacility(String id) async {
    try {
      await _supabase.from('facilities').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete facility: $e');
    }
  }
}
