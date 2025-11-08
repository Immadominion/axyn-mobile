import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtStorageService {
  JwtStorageService(this._storage);

  final FlutterSecureStorage _storage;
  static const _jwtKey = 'axyn_jwt_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _jwtKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _jwtKey);
  }
}

final jwtStorageServiceProvider = Provider<JwtStorageService>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  return JwtStorageService(storage);
});
