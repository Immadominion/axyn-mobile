import 'package:dio/dio.dart';

import '../../domain/auth/backend_user.dart';

/// Remote datasource for user-related API calls
class UserRemoteDatasource {
  const UserRemoteDatasource(this._dio);

  final Dio _dio;

  /// Fetch current user profile from backend
  /// Requires authentication (JWT in body)
  Future<BackendUser> getCurrentUser() async {
    try {
      print('🌐 [USER DATASOURCE] GET /user/me starting...');
      final response = await _dio.get<Map<String, dynamic>>('/user/me');

      if (response.data == null) {
        throw Exception('Empty response from /user/me endpoint');
      }

      print('✅ [USER DATASOURCE] GET /user/me succeeded');
      return BackendUser.fromJson(response.data!);
    } on DioException catch (e) {
      print('❌ [USER DATASOURCE] GET /user/me failed');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Failed to fetch user profile: ${e.message}');
    }
  }

  /// Update user profile
  /// Requires authentication (JWT in body)
  Future<BackendUser> updateProfile({
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      print('🌐 [USER DATASOURCE] PATCH /user/me starting...');
      print('   Data: name=$name, bio=$bio, avatarUrl=$avatarUrl');
      final response = await _dio.patch<Map<String, dynamic>>(
        '/user/me',
        data: {
          if (name != null) 'name': name,
          if (bio != null) 'bio': bio,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        },
      );

      if (response.data == null) {
        throw Exception('Empty response from profile update');
      }

      print('✅ [USER DATASOURCE] PATCH /user/me succeeded');
      return BackendUser.fromJson(response.data!);
    } on DioException catch (e) {
      print('❌ [USER DATASOURCE] PATCH /user/me failed');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Failed to update profile: ${e.message}');
    }
  }
}
