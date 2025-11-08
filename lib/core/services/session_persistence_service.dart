import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Key used to persist session snapshots securely on device storage.
const String _sessionStorageKey = 'axyn_session_snapshot_v1';

/// Immutable snapshot describing the currently authenticated Privy user.
@immutable
class SessionSnapshot {
  SessionSnapshot({
    required this.userId,
    required List<String> loginProviders,
    required this.lastAuthenticatedAt,
    this.primaryEmail,
    this.primaryPhone,
    this.lastLoginMethod,
  }) : loginProviders = List.unmodifiable(loginProviders);

  final String userId;
  final List<String> loginProviders;
  final DateTime lastAuthenticatedAt;
  final String? primaryEmail;
  final String? primaryPhone;
  final String? lastLoginMethod;

  bool get hasEmail => primaryEmail != null && primaryEmail!.isNotEmpty;
  bool get hasPhone => primaryPhone != null && primaryPhone!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'loginProviders': loginProviders,
      'lastAuthenticatedAt': lastAuthenticatedAt.toIso8601String(),
      'primaryEmail': primaryEmail,
      'primaryPhone': primaryPhone,
      'lastLoginMethod': lastLoginMethod,
    };
  }

  factory SessionSnapshot.fromJson(Map<String, dynamic> json) {
    return SessionSnapshot(
      userId: json['userId'] as String,
      loginProviders:
          List<String>.from(json['loginProviders'] as List<dynamic>),
      lastAuthenticatedAt:
          DateTime.parse(json['lastAuthenticatedAt'] as String),
      primaryEmail: json['primaryEmail'] as String?,
      primaryPhone: json['primaryPhone'] as String?,
      lastLoginMethod: json['lastLoginMethod'] as String?,
    );
  }

  SessionSnapshot copyWith({
    String? lastLoginMethod,
    DateTime? lastAuthenticatedAt,
  }) {
    return SessionSnapshot(
      userId: userId,
      loginProviders: List<String>.from(loginProviders),
      lastAuthenticatedAt: lastAuthenticatedAt ?? this.lastAuthenticatedAt,
      primaryEmail: primaryEmail,
      primaryPhone: primaryPhone,
      lastLoginMethod: lastLoginMethod ?? this.lastLoginMethod,
    );
  }
}

/// Handles secure persistence and retrieval of the signed-in user snapshot.
class SessionPersistenceService {
  SessionPersistenceService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  Future<void> save(SessionSnapshot snapshot) async {
    final payload = jsonEncode(snapshot.toJson());
    await _storage.write(
      key: _sessionStorageKey,
      value: payload,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  Future<SessionSnapshot?> read() async {
    final payload = await _storage.read(
      key: _sessionStorageKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );

    if (payload == null) {
      return null;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(payload) as Map<String, dynamic>;
      return SessionSnapshot.fromJson(decoded);
    } catch (_) {
      // If decoding fails, clear the corrupted value.
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.delete(
      key: _sessionStorageKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }
}

/// Riverpod provider exposing the session persistence service.
final sessionPersistenceServiceProvider = Provider<SessionPersistenceService>(
  (ref) => SessionPersistenceService(),
);
