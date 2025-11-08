import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth/login_request.dart';
import '../../domain/auth/login_response.dart';
import '../network/dio_client.dart';

abstract class AuthRemoteDatasource {
  Future<LoginResponse> login(String privyAuthToken, {String? walletAddress});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LoginResponse> login(
    String privyAuthToken, {
    String? walletAddress,
  }) async {
    try {
      print('🌐 [AUTH DATASOURCE] POST /auth/login starting...');
      print('   Wallet: ${walletAddress ?? "null"}');

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: LoginRequest(
          authToken: privyAuthToken,
          walletAddress: walletAddress,
        ).toJson(),
      );

      if (response.data == null) {
        throw Exception('Empty response from login endpoint');
      }

      print('✅ [AUTH DATASOURCE] Login response received');
      print('   Response keys: ${response.data!.keys.toList()}');
      print('   Has accessToken: ${response.data!.containsKey("accessToken")}');

      final loginResponse = LoginResponse.fromJson(response.data!);
      print('✅ [AUTH DATASOURCE] LoginResponse parsed successfully');
      print(
          '   Access token: ${loginResponse.accessToken.substring(0, 30)}...');

      return loginResponse;
    } on DioException catch (e) {
      print('❌ [AUTH DATASOURCE] Login failed');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid Privy authentication token');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }
}

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDatasourceImpl(dio);
});
