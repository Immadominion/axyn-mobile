import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/jwt_storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('\n========================================');
    print('🔵 [AUTH INTERCEPTOR] INTERCEPTOR CALLED!');
    print('🔵 [AUTH INTERCEPTOR] ${options.method} ${options.path}');
    print('========================================\n');

    // Skip adding JWT to auth endpoints (login already has its own token)
    if (options.path.contains('/auth/login')) {
      print('⏭️  [AUTH INTERCEPTOR] Skipping /auth/login endpoint');
      return super.onRequest(options, handler);
    }

    // Get JWT token from secure storage
    final jwtStorage = _ref.read(jwtStorageServiceProvider);
    final token = await jwtStorage.getToken();

    if (token == null || token.isEmpty) {
      print('❌ [AUTH INTERCEPTOR] No JWT token found in storage!');
      return super.onRequest(options, handler);
    }

    print('✅ [AUTH INTERCEPTOR] JWT token found: ${token}...');
    final method = options.method.toUpperCase();

    if (method == 'GET' || method == 'DELETE') {
      final params = Map<String, dynamic>.from(options.queryParameters);
      params['token'] = token;
      options.queryParameters = params;
      print('🔗 [AUTH INTERCEPTOR] Added token to query params for $method');
      return super.onRequest(options, handler);
    }

    final data = options.data;

    if (data == null) {
      options.data = <String, dynamic>{'token': token};
      print('📦 [AUTH INTERCEPTOR] Created new body with token');
    } else if (data is Map<String, dynamic>) {
      options.data = <String, dynamic>{...data, 'token': token};
      print('📦 [AUTH INTERCEPTOR] Added token to existing body map');
    } else if (data is FormData) {
      data.fields.removeWhere((entry) => entry.key == 'token');
      data.fields.add(MapEntry('token', token));
      options.data = data;
      print('📦 [AUTH INTERCEPTOR] Added token to FormData');
    } else {
      final params = Map<String, dynamic>.from(options.queryParameters);
      params['token'] = token;
      options.queryParameters = params;
      print(
          '🔗 [AUTH INTERCEPTOR] Fallback: Added token to query params for unsupported data type');
    }

    super.onRequest(options, handler);
  }
}
