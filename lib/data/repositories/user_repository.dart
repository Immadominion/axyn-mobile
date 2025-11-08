import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth/backend_user.dart';
import '../datasources/user_remote_datasource.dart';
import '../network/dio_client.dart';

/// Repository for user profile operations
/// Follows repository pattern - abstracts data source implementation
class UserRepository {
  const UserRepository(this._datasource);

  final UserRemoteDatasource _datasource;

  /// Get current authenticated user's profile from backend
  Future<BackendUser> getCurrentUser() => _datasource.getCurrentUser();

  /// Update current user's profile
  Future<BackendUser> updateProfile({
    String? name,
    String? bio,
    String? avatarUrl,
  }) =>
      _datasource.updateProfile(
        name: name,
        bio: bio,
        avatarUrl: avatarUrl,
      );
}

// Provider for UserRemoteDatasource
final userRemoteDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRemoteDatasource(dio);
});

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(userRemoteDatasourceProvider);
  return UserRepository(datasource);
});
