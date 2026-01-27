import 'package:motivaid/core/profile/models/user_profile.dart';

/// Profile repository interface
abstract class ProfileRepository {
  /// Get profile for a user
  Future<UserProfile?> getProfile(String userId);

  /// Update user profile
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Create a new profile
  Future<UserProfile> createProfile(UserProfile profile);
}
