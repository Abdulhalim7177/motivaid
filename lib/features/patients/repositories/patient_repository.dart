import 'package:motivaid/features/patients/models/patient.dart';
import 'package:motivaid/core/widgets/risk_badge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PatientRepository {
  Future<List<Patient>> getPatients({String? midwifeId, String? facilityId});
  Future<Patient?> getPatient(String id);
  Future<Patient> createPatient(Patient patient);
  Future<Patient> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  
  // Stats
  Future<int> getActivePatientCount(String midwifeId);
  Future<Map<RiskLevel, int>> getRiskLevelStats(String midwifeId);
}

class SupabasePatientRepository implements PatientRepository {
  final SupabaseClient _supabase;

  SupabasePatientRepository(this._supabase);

  @override
  Future<List<Patient>> getPatients({String? midwifeId, String? facilityId}) async {
    var query = _supabase.from('patients').select();
    
    if (midwifeId != null) {
      query = query.eq('midwife_id', midwifeId);
    }
    if (facilityId != null) {
      query = query.eq('facility_id', facilityId);
    }
    
    // Order by updated_at descending
    final response = await query.order('updated_at', ascending: false);
    
    return (response as List).map((e) => Patient.fromJson(e)).toList();
  }

  @override
  Future<Patient?> getPatient(String id) async {
    final response = await _supabase.from('patients').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Patient.fromJson(response);
  }

  @override
  Future<Patient> createPatient(Patient patient) async {
    final Map<String, dynamic> data = patient.toJson();
    if (data['id'] == '') {
      data.remove('id');
    }
    // Also remove timestamps to let DB handle defaults if preferred, but they are optional
    // data.remove('created_at'); 
    // data.remove('updated_at');
    
    final response = await _supabase.from('patients').insert(data).select().single();
    return Patient.fromJson(response);
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    final response = await _supabase
        .from('patients')
        .update(patient.toJson())
        .eq('id', patient.id)
        .select()
        .single();
    return Patient.fromJson(response);
  }

  @override
  Future<void> deletePatient(String id) async {
    await _supabase.from('patients').delete().eq('id', id);
  }

  @override
  Future<int> getActivePatientCount(String midwifeId) async {
    final count = await _supabase
        .from('patients')
        .count(CountOption.exact)
        .eq('midwife_id', midwifeId)
        .eq('status', 'Active');
    return count;
  }

  @override
  Future<Map<RiskLevel, int>> getRiskLevelStats(String midwifeId) async {
    final response = await _supabase
        .from('patients')
        .select('risk_level')
        .eq('midwife_id', midwifeId)
        .eq('status', 'Active');
        
    final stats = <RiskLevel, int>{
      RiskLevel.high: 0,
      RiskLevel.medium: 0,
      RiskLevel.low: 0,
    };
    
    for (var item in (response as List)) {
      final levelStr = item['risk_level'] as String?;
      if (levelStr != null) {
        final level = RiskLevelExtension.fromString(levelStr);
        stats[level] = (stats[level] ?? 0) + 1;
      }
    }
    return stats;
  }
}
