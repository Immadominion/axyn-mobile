import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth/login_response.dart';
import '../datasources/auth_remote_datasource.dart';

abstract class AuthRepository {
  Future<LoginResponse> loginWithPrivy(
    String privyAuthToken, {
    String? walletAddress,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDatasource);

  final AuthRemoteDatasource _remoteDatasource;

  @override
  Future<LoginResponse> loginWithPrivy(
    String privyAuthToken, {
    String? walletAddress,
  }) async {
    return _remoteDatasource.login(
      privyAuthToken,
      walletAddress: walletAddress,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(datasource);
});
