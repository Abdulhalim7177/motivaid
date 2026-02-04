import 'package:motivaid/features/patients/models/patient.dart';
import 'package:motivaid/features/patients/repositories/patient_repository.dart';
import 'package:motivaid/core/data/local/database_helper.dart';
import 'package:motivaid/core/data/sync/sync_queue_repository.dart';
import 'package:motivaid/core/network/network_info.dart';
import 'package:uuid/uuid.dart';
import 'package:motivaid/core/widgets/risk_badge.dart';
import 'package:sqflite/sqflite.dart';

class OfflinePatientRepository implements PatientRepository {
  final PatientRepository _remoteRepository;
  final DatabaseHelper _localDb;
  final SyncQueueRepository _syncQueue;
  final NetworkInfo _networkInfo;
  final _uuid = const Uuid();

  OfflinePatientRepository(
    this._remoteRepository,
    this._localDb,
    this._syncQueue,
    this._networkInfo,
  );

  @override
  Future<List<Patient>> getPatients({String? midwifeId, String? facilityId}) async {
    if (await _networkInfo.isConnected) {
      try {
        final patients = await _remoteRepository.getPatients(midwifeId: midwifeId, facilityId: facilityId);
        // Cache remotely fetched patients locally
        for (var patient in patients) {
          await _saveToLocal(patient, isSynced: true);
        }
        return patients;
      } catch (e) {
        // Fallback to local if remote fails
        return _getLocalPatients(midwifeId);
      }
    } else {
      return _getLocalPatients(midwifeId);
    }
  }

  Future<List<Patient>> _getLocalPatients(String? midwifeId) async {
    final db = await _localDb.database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (midwifeId != null) {
      whereClause = 'midwife_id = ?';
      whereArgs = [midwifeId];
    }

    final maps = await db.query('patients', where: whereClause, whereArgs: whereArgs, orderBy: 'created_at DESC');
    
    return maps.map((map) {
      // Need to handle boolean conversion from SQLite (0/1) back to bool
      final Map<String, dynamic> convertedMap = Map<String, dynamic>.from(map);
      convertedMap['prior_pph_history'] = map['prior_pph_history'] == 1;
      convertedMap['known_coagulopathy'] = map['known_coagulopathy'] == 1;
      // ... convert other booleans ...
      // Actually, my Patient.fromJson handles bools from JSON.
      // If sqflite returns 1/0, dart might treat it as int.
      // Let's rely on a mapper helper.
      return _mapLocalToPatient(map);
    }).toList();
  }

  Patient _mapLocalToPatient(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      fullName: map['full_name'],
      age: map['age'],
      gestationalAgeWeeks: map['gestational_age_weeks'],
      riskLevel: RiskLevelExtension.fromString(map['risk_level'] ?? 'Low'),
      status: PatientStatus.fromString(map['status'] ?? 'Active'),
      midwifeId: map['midwife_id'],
      facilityId: map['facility_id'],
      lastAssessmentDate: map['last_assessment_date'] != null ? DateTime.parse(map['last_assessment_date']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      // Bools (SQLite stores as 0/1)
      priorPphHistory: map['prior_pph_history'] == 1,
      knownCoagulopathy: map['known_coagulopathy'] == 1,
      hasFibroids: map['has_fibroids'] == 1,
      hasPolyhydramnios: map['has_polyhydramnios'] == 1,
      laborInduced: map['labor_induced'] == 1,
      prolongedLabor: map['prolonged_labor'] == 1,
      historyCesareanSection: map['history_cesarean_section'] == 1,
      hasAntenatalCare: map['has_antenatal_care'] == 1,
      // Others
      gravida: map['gravida'],
      parity: map['parity'],
      placentalStatus: map['placental_status'],
      estimatedFetalWeight: map['estimated_fetal_weight'],
      numberOfFetuses: map['number_of_fetuses'] ?? 1,
      baselineHemoglobin: map['baseline_hemoglobin'],
    );
  }

  @override
  Future<Patient> createPatient(Patient patient) async {
    // Generate ID locally if not present (offline-first approach)
    final patientId = patient.id.isEmpty ? _uuid.v4() : patient.id;
    final newPatient = patient.copyWith(id: patientId);

    // Save locally first (Optimistic UI)
    await _saveToLocal(newPatient, isSynced: false);

    if (await _networkInfo.isConnected) {
      try {
        final remotePatient = await _remoteRepository.createPatient(newPatient);
        // Update local to synced
        await _saveToLocal(remotePatient, isSynced: true);
        return remotePatient;
      } catch (e) {
        // Queue for sync
        await _syncQueue.queueOperation(
          tableName: 'patients',
          operation: 'INSERT',
          payload: newPatient.toJson(),
        );
        return newPatient;
      }
    } else {
      // Offline: Queue
      await _syncQueue.queueOperation(
        tableName: 'patients',
        operation: 'INSERT',
        payload: newPatient.toJson(),
      );
      return newPatient;
    }
  }

  Future<void> _saveToLocal(Patient patient, {required bool isSynced}) async {
    final Map<String, dynamic> data = patient.toJson();
    // Convert bools to int for SQLite
    data['prior_pph_history'] = patient.priorPphHistory ? 1 : 0;
    data['known_coagulopathy'] = patient.knownCoagulopathy ? 1 : 0;
    data['has_fibroids'] = patient.hasFibroids ? 1 : 0;
    data['has_polyhydramnios'] = patient.hasPolyhydramnios ? 1 : 0;
    data['labor_induced'] = patient.laborInduced ? 1 : 0;
    data['prolonged_labor'] = patient.prolongedLabor ? 1 : 0;
    data['history_cesarean_section'] = patient.historyCesareanSection ? 1 : 0;
    data['has_antenatal_care'] = patient.hasAntenatalCare ? 1 : 0;
    
    data['is_synced'] = isSynced ? 1 : 0;

    await _localDb.insert('patients', data); // Uses Insert with conflict replace if configured or simple insert
    // Ideally use insert OR replace
    final db = await _localDb.database;
    await db.insert('patients', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<Patient?> getPatient(String id) async {
    final db = await _localDb.database;
    final result = await db.query('patients', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return _mapLocalToPatient(result.first);
    }
    // If not local, try remote (if connected)
    if (await _networkInfo.isConnected) {
      return await _remoteRepository.getPatient(id);
    }
    return null;
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    await _saveToLocal(patient, isSynced: false);

    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteRepository.updatePatient(patient);
        await _saveToLocal(remote, isSynced: true);
        return remote;
      } catch (e) {
        await _syncQueue.queueOperation(tableName: 'patients', operation: 'UPDATE', payload: patient.toJson());
        return patient;
      }
    } else {
      await _syncQueue.queueOperation(tableName: 'patients', operation: 'UPDATE', payload: patient.toJson());
      return patient;
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    final db = await _localDb.database;
    await db.delete('patients', where: 'id = ?', whereArgs: [id]);

    if (await _networkInfo.isConnected) {
      try {
        await _remoteRepository.deletePatient(id);
      } catch (e) {
        await _syncQueue.queueOperation(tableName: 'patients', operation: 'DELETE', payload: {'id': id});
      }
    } else {
      await _syncQueue.queueOperation(tableName: 'patients', operation: 'DELETE', payload: {'id': id});
    }
  }

  @override
  Future<int> getActivePatientCount(String midwifeId) async {
    final db = await _localDb.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM patients WHERE midwife_id = ? AND status = ?', 
      [midwifeId, 'Active']
    ));
    return count ?? 0;
  }

  @override
  Future<Map<RiskLevel, int>> getRiskLevelStats(String midwifeId) async {
    final db = await _localDb.database;
    final result = await db.rawQuery(
      'SELECT risk_level, COUNT(*) as count FROM patients WHERE midwife_id = ? GROUP BY risk_level',
      [midwifeId]
    );
    
    final stats = <RiskLevel, int>{
      RiskLevel.high: 0,
      RiskLevel.medium: 0,
      RiskLevel.low: 0,
    };

    for (var row in result) {
      final levelStr = row['risk_level'] as String;
      final count = row['count'] as int;
      stats[RiskLevelExtension.fromString(levelStr)] = count;
    }
    return stats;
  }
}
