import 'dart:convert';
import 'package:motivaid/core/data/local/database_helper.dart';

class SyncQueueRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _table = 'sync_queue';

  /// Queues an operation to be synced later.
  Future<void> queueOperation({
    required String tableName,
    required String operation, // 'INSERT', 'UPDATE', 'DELETE'
    required Map<String, dynamic> payload,
  }) async {
    final row = {
      'table_name': tableName,
      'operation': operation,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
    };
    await _dbHelper.insert(_table, row);
  }

  /// Retrieves all pending operations from the queue.
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final db = await _dbHelper.database;
    return await db.query(_table, where: 'synced_at IS NULL', orderBy: 'created_at ASC');
  }

  /// Marks an operation as synced (or deletes it).
  Future<void> markAsSynced(int id) async {
    final db = await _dbHelper.database;
    // Option A: Delete to keep table small
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    
    // Option B: Mark as synced (for audit history)
    // await db.update(_table, {'synced_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }
}
