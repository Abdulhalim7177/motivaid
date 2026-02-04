import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:motivaid/core/data/sync/sync_queue_repository.dart';
import 'package:motivaid/features/patients/models/patient.dart';
import 'package:motivaid/features/patients/repositories/patient_repository.dart';
import 'package:motivaid/core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:motivaid/core/services/notification_service.dart';

class SyncService {
  final SyncQueueRepository _syncQueue;
  final PatientRepository _patientRepository; // Remote repository
  final NetworkInfo _networkInfo;
  final NotificationService _notificationService;
  
  bool _isSyncing = false;
  StreamSubscription? _subscription;

  SyncService(
    this._syncQueue, 
    this._patientRepository, 
    this._networkInfo,
    this._notificationService,
  ) {
    _initialize();
  }

  void _initialize() {
    _notificationService.initialize();
    
    _subscription = _networkInfo.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        debugPrint('Network connected. Triggering sync...');
        syncPendingOperations();
      }
    });
    // Also trigger immediately on startup if connected
    syncPendingOperations();
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;
    if (!await _networkInfo.isConnected) return;

    _isSyncing = true;
    debugPrint('Starting sync process...');

    try {
      final pendingOps = await _syncQueue.getPendingOperations();
      if (pendingOps.isEmpty) return; // Nothing to sync

      debugPrint('Found ${pendingOps.length} pending operations');
      int successCount = 0;

      for (var op in pendingOps) {
        final id = op['id'] as int;
        final tableName = op['table_name'] as String;
        final operation = op['operation'] as String;
        final payloadJson = op['payload'] as String;
        final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

        try {
          await _processOperation(tableName, operation, payload);
          // On success, mark as synced (delete)
          await _syncQueue.markAsSynced(id);
          successCount++;
          debugPrint('Synced operation $id successfully');
        } catch (e) {
          debugPrint('Failed to sync operation $id: $e');
        }
      }

      if (successCount > 0) {
        await _notificationService.showNotification(
          id: 1, // Simple ID for now
          title: 'Sync Complete',
          body: 'Successfully synced $successCount offline changes.',
        );
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processOperation(String tableName, String operation, Map<String, dynamic> payload) async {
    switch (tableName) {
      case 'patients':
        await _processPatientOperation(operation, payload);
        break;
      default:
        debugPrint('Unknown table name for sync: $tableName');
    }
  }

  Future<void> _processPatientOperation(String operation, Map<String, dynamic> payload) async {
    final patient = Patient.fromJson(payload);
    
    switch (operation) {
      case 'INSERT':
        // We pass the patient (which has the local UUID) to the remote repo.
        // The remote repo (Supabase) will insert it.
        await _patientRepository.createPatient(patient);
        break;
      case 'UPDATE':
        await _patientRepository.updatePatient(patient);
        break;
      case 'DELETE':
        await _patientRepository.deletePatient(patient.id);
        break;
      default:
        debugPrint('Unknown operation: $operation');
    }
  }
}
