import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/profile/models/user_profile.dart';
import 'package:motivaid/core/profile/repositories/profile_repository.dart';
import 'package:motivaid/core/profile/repositories/supabase_profile_repository.dart';
import 'package:motivaid/core/profile/repositories/offline_profile_repository.dart';
import 'package:motivaid/core/data/local/database_helper.dart';
import 'package:motivaid/core/network/network_info.dart';

/// Provider for the profile repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteRepo = SupabaseProfileRepository(supabase);
  final localDb = DatabaseHelper.instance;
  final networkInfo = NetworkInfoImpl();
  
  return OfflineProfileRepository(remoteRepo, localDb, networkInfo);
});

/// Provider for fetching a user's profile
final userProfileProvider = FutureProvider.autoDispose<UserProfile?>((ref) async {
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  final currentUser = authNotifier.currentUser;

  if (currentUser == null) {
    return null;
  }

  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile(currentUser.id);
});

/// Profile notifier for managing profile updates
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final ProfileRepository _repository;
  final String _userId;

  ProfileNotifier(this._repository, this._userId) 
      : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile(_userId);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update the user's profile
  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      final updatedProfile = await _repository.updateProfile(profile);
      state = AsyncValue.data(updatedProfile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Reload the profile
  Future<void> reload() async {
    await _loadProfile();
  }
}

/// Provider for the profile notifier
final profileNotifierProvider = StateNotifierProvider
    .family<ProfileNotifier, AsyncValue<UserProfile?>, String>(
  (ref, userId) {
    final repository = ref.watch(profileRepositoryProvider);
    return ProfileNotifier(repository, userId);
  },
);
