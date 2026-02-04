import 'package:motivaid/core/profile/models/user_profile.dart';
import 'package:motivaid/core/profile/repositories/profile_repository.dart';
import 'package:motivaid/core/data/local/database_helper.dart';
import 'package:motivaid/core/network/network_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:motivaid/core/units/models/unit_membership.dart';

class OfflineProfileRepository implements ProfileRepository {
  final ProfileRepository _remoteRepository;
  final DatabaseHelper _localDb;
  final NetworkInfo _networkInfo;

  OfflineProfileRepository(this._remoteRepository, this._localDb, this._networkInfo);

  @override
  Future<UserProfile?> getProfile(String userId) async {
    // 1. Try Remote if connected
    if (await _networkInfo.isConnected) {
      try {
        final profile = await _remoteRepository.getProfile(userId);
        if (profile != null) {
          await _saveToLocal(profile);
        }
        return profile;
      } catch (e) {
        // Fallback to local on error
        return _getLocalProfile(userId);
      }
    } else {
      // 2. Offline Mode
      return _getLocalProfile(userId);
    }
  }

  Future<UserProfile?> _getLocalProfile(String userId) async {
    final db = await _localDb.database;
    final result = await db.query('profiles', where: 'id = ?', whereArgs: [userId]);
    
    if (result.isNotEmpty) {
      return _mapLocalToProfile(result.first);
    }
    return null;
  }

  UserProfile _mapLocalToProfile(Map<String, dynamic> map) {
    // Need to convert is_active (int) to bool manually if not using standard mapper
    // But since UserProfile.fromJson expects 'is_active' as bool (from Supabase JSON), 
    // and SQLite stores int (0/1), we need to adapt map before passing to fromJson
    // OR create a dedicated local factory.
    // Let's manually reconstruct.
    
    return UserProfile(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'],
      bio: map['bio'],
      phone: map['phone'],
      avatarUrl: map['avatar_url'],
      dateOfBirth: map['date_of_birth'] != null ? DateTime.parse(map['date_of_birth']) : null,
      role: map['role'] != null ? UserRole.fromString(map['role']) : UserRole.midwife,
      primaryFacilityId: map['primary_facility_id'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Future<void> _saveToLocal(UserProfile profile) async {
    final Map<String, dynamic> data = profile.toJson();
    // Convert bool to int for SQLite
    data['is_active'] = profile.isActive ? 1 : 0;
    
    final db = await _localDb.database;
    await db.insert(
      'profiles', 
      data, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    // Optimistic update locally
    await _saveToLocal(profile);

    if (await _networkInfo.isConnected) {
      final updated = await _remoteRepository.updateProfile(profile);
      await _saveToLocal(updated); // Sync back latest
      return updated;
    } else {
      // TODO: Queue update
      return profile;
    }
  }

  @override
  Future<UserProfile> createProfile(UserProfile profile) async {
    if (await _networkInfo.isConnected) {
      final created = await _remoteRepository.createProfile(profile);
      await _saveToLocal(created);
      return created;
    } else {
      throw Exception('Cannot create profile offline');
    }
  }

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    // Only remote for listing all? Or local cache?
    // Usually admin feature.
    if (await _networkInfo.isConnected) {
      return _remoteRepository.getAllProfiles();
    }
    return [];
  }
}
