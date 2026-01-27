import 'package:motivaid/core/profile/models/user_profile.dart';
import 'package:motivaid/core/profile/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase implementation of the profile repository
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabase;

  SupabaseProfileRepository(this._supabase);

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final data = {
        'full_name': profile.fullName,
        'bio': profile.bio,
        'phone': profile.phone,
        'avatar_url': profile.avatarUrl,
        'date_of_birth': profile.dateOfBirth?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('profiles')
          .update(data)
          .eq('id', profile.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<UserProfile> createProfile(UserProfile profile) async {
    try {
      final data = profile.toJson();
      
      final response = await _supabase
          .from('profiles')
          .insert(data)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }
}
