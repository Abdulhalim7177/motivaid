import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyUserId = 'last_user_id';
  static const _keyUserEmail = 'last_user_email';

  /// Save the last logged-in user credentials
  Future<void> saveLastUser({required String id, required String email}) async {
    await _storage.write(key: _keyUserId, value: id);
    await _storage.write(key: _keyUserEmail, value: email);
  }

  /// Get the last logged-in user credentials
  Future<Map<String, String>?> getLastUser() async {
    final id = await _storage.read(key: _keyUserId);
    final email = await _storage.read(key: _keyUserEmail);

    if (id != null && email != null) {
      return {'id': id, 'email': email};
    }
    return null;
  }

  /// Clear the last user (optional, e.g. if user specifically wants to forget)
  Future<void> clearLastUser() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserEmail);
  }
}
