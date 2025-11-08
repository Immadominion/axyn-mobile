import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privy_flutter/privy_flutter.dart';

import '../../core/logging/app_logger.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/services/privy_auth_service.dart';
import '../../core/services/session_persistence_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/auth/login_response.dart';

class SessionState {
  const SessionState._({
    required this.isAuthenticated,
    this.snapshot,
    this.errorMessage,
  });

  const SessionState.authenticated(SessionSnapshot snapshot)
      : this._(isAuthenticated: true, snapshot: snapshot);

  const SessionState.unauthenticated({String? errorMessage})
      : this._(isAuthenticated: false, errorMessage: errorMessage);

  final bool isAuthenticated;
  final SessionSnapshot? snapshot;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
}

class SessionController extends AsyncNotifier<SessionState> {
  SessionPersistenceService get _sessionStorage =>
      ref.read(sessionPersistenceServiceProvider);
  PrivyAuthService get _authService => ref.read(privyAuthServiceProvider);
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  JwtStorageService get _jwtStorage => ref.read(jwtStorageServiceProvider);
  bool _isBootstrapping = false;

  @override
  Future<SessionState> build() async {
    _isBootstrapping = true;
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (_isBootstrapping) {
          return;
        }

        if (authState.isAuthenticated) {
          unawaited(_syncSnapshotFromAuthState(authState));
        } else {
          unawaited(_confirmUnauthenticatedSignal());
        }
      });
    });

    try {
      return await _restoreSession();
    } finally {
      _isBootstrapping = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading<SessionState>();
    state = await AsyncValue.guard(_restoreSession);
  }

  Future<bool> onLoginSuccess(LoginMethod method) async {
    final currentSnapshot = state.asData?.value.snapshot;

    final result = await AsyncValue.guard(() async {
      await _authService.waitForReady();
      final authState = await _authService.refreshAuthState();
      final user = await _authService.getCurrentUser();

      if (authState != null && authState.isAuthenticated && user != null) {
        // Ensure the embedded wallet exists before contacting the backend.
        EmbeddedSolanaWallet? walletForBackend;
        try {
          AppLogger.d(
              '🔒 Ensuring embedded Solana wallet before backend login');
          walletForBackend = await _authService.ensureEmbeddedSolanaWallet();
          if (walletForBackend == null) {
            AppLogger.w(
              '⚠️  Embedded wallet not available yet; backend login may fail. '
              'Will attempt to proceed and retry if needed.',
            );
          } else {
            AppLogger.d('✅ Embedded wallet ready: ${walletForBackend.address}');
          }
        } catch (walletError, walletStack) {
          AppLogger.e(
            '❌ Failed to ensure embedded wallet before backend login',
            walletError,
            walletStack,
          );
        }

        // Get Privy access token
        var privyToken = await _authService.getAccessToken();
        if (privyToken == null) {
          AppLogger.e('Failed to get Privy access token after login');
          await _sessionStorage.clear();
          return const SessionState.unauthenticated(
            errorMessage: 'Failed to retrieve authentication token.',
          );
        }

        // Login to backend with Privy token
        print('🎯 [SESSION] Starting backend login flow...');
        LoginResponse? loginResponse;
        String? walletAddressForAttempt = walletForBackend?.address;
        var attempt = 0;
        while (loginResponse == null && attempt < 2) {
          attempt++;
          print('🔄 [SESSION] Backend login attempt $attempt starting...');
          try {
            AppLogger.d(
                '🔄 Calling backend login endpoint (attempt $attempt)...');
            final tokenForAttempt = privyToken!;
            print(
                '📝 [SESSION] Privy token ready: ${tokenForAttempt.substring(0, 20)}...');

            AppLogger.d('📞 Calling _authRepository.loginWithPrivy...');
            loginResponse = await _authRepository.loginWithPrivy(
              tokenForAttempt,
              walletAddress: walletAddressForAttempt,
            );
            AppLogger.d('📥 Backend response received, extracting JWT...');

            AppLogger.d('💾 Saving JWT token to secure storage...');
            await _jwtStorage.saveToken(loginResponse.accessToken);
            AppLogger.d('✅ JWT token saved successfully');

            // Verify token was saved
            final savedToken = await _jwtStorage.getToken();
            if (savedToken == null || savedToken.isEmpty) {
              AppLogger.e('❌ CRITICAL: JWT token was NOT saved properly!');
            } else {
              AppLogger.d(
                  '🔐 JWT Token verified in storage: ${savedToken.substring(0, 30)}...');
            }

            AppLogger.d('✅ Backend login successful!');
            AppLogger.d('📝 User ID: ${loginResponse.user.id}');
            AppLogger.d(
              '💼 Wallet: ${loginResponse.user.walletAddress.substring(0, 8)}...',
            );
            AppLogger.d('🎟️  JWT stored securely (expires in 30 days)');
          } catch (error, stackTrace) {
            print('❌❌❌ [SESSION] Backend login FAILED (attempt $attempt) ❌❌❌');
            print('Error type: ${error.runtimeType}');
            print('Error: $error');
            print('Stack trace:');
            print(stackTrace);
            AppLogger.e(
              '❌ Backend login failed (attempt $attempt) - continuing in Privy-only mode',
              error,
              stackTrace,
            );

            if (attempt >= 2) {
              break;
            }

            AppLogger.d(
                '🔁 Retrying backend login after re-validating wallet...');
            try {
              walletForBackend =
                  await _authService.ensureEmbeddedSolanaWallet();
              if (walletForBackend == null) {
                AppLogger.w(
                  '⚠️  Embedded wallet still unavailable; aborting retry.',
                );
                break;
              }
              walletAddressForAttempt = walletForBackend.address;
              final refreshedToken = await _authService.getAccessToken();
              if (refreshedToken == null) {
                AppLogger.e(
                  '❌ Unable to refresh Privy access token for retry; aborting.',
                );
                break;
              }
              privyToken = refreshedToken;
            } catch (retryError, retryStack) {
              AppLogger.e(
                '❌ Failed to prepare retry for backend login',
                retryError,
                retryStack,
              );
              break;
            }
          }
        }

        final snapshot = _buildSnapshot(
          user,
          previous: currentSnapshot,
          overrideLoginMethod: method.name,
        );

        await _sessionStorage.save(snapshot);
        return SessionState.authenticated(snapshot);
      }

      await _sessionStorage.clear();
      await _jwtStorage.clearToken();
      return const SessionState.unauthenticated(
        errorMessage:
            'We couldn\'t confirm your session. Please sign in again.',
      );
    });

    state = result;
    return result.when(
      data: (value) => value.isAuthenticated,
      error: (_, __) => false,
      loading: () => false,
    );
  }

  Future<void> clearPersistedSession({bool shouldLogout = false}) async {
    if (shouldLogout) {
      unawaited(_authService.logout());
    }

    await _sessionStorage.clear();
    await _jwtStorage.clearToken();
    state = const AsyncData<SessionState>(SessionState.unauthenticated());
  }

  Future<SessionState> _restoreSession() async {
    final storedSnapshot = await _sessionStorage.read();

    try {
      await _authService.waitForReady();
      final authState = await _authService.refreshAuthState();

      if (authState != null && authState.isAuthenticated) {
        final user = await _authService.getCurrentUser();
        if (user == null) {
          await _sessionStorage.clear();
          await _jwtStorage.clearToken();
          return const SessionState.unauthenticated(
            errorMessage:
                'We couldn\'t load your profile. Please sign in again.',
          );
        }

        // Check if we have a stored JWT token
        final storedJwt = await _jwtStorage.getToken();

        // If no JWT but user is authenticated with Privy, get a new JWT from backend
        if (storedJwt == null) {
          AppLogger.d('⚠️  No JWT found during session restore');
          AppLogger.d('🔄 Fetching fresh JWT from backend...');
          try {
            final privyToken = await _authService.getAccessToken();
            if (privyToken != null) {
              final loginResponse =
                  await _authRepository.loginWithPrivy(privyToken);
              await _jwtStorage.saveToken(loginResponse.accessToken);
              AppLogger.d('✅ Backend JWT restored successfully!');
              AppLogger.d('🎟️  New JWT stored (expires in 30 days)');
            }
          } catch (e, stackTrace) {
            AppLogger.e('❌ Failed to restore backend JWT', e, stackTrace);
            // Continue with Privy-only session
          }
        } else {
          AppLogger.d('✅ JWT found in storage - session fully restored');
        }

        final snapshot = _buildSnapshot(
          user,
          previous: storedSnapshot,
        );

        await _sessionStorage.save(snapshot);
        return SessionState.authenticated(snapshot);
      }
    } catch (error, stackTrace) {
      AppLogger.e('Failed to restore user session', error, stackTrace);
      await _sessionStorage.clear();
      await _jwtStorage.clearToken();
      return const SessionState.unauthenticated(
        errorMessage:
            'We couldn\'t restore your session. Please sign in again.',
      );
    }

    if (storedSnapshot != null) {
      await _sessionStorage.clear();
      await _jwtStorage.clearToken();
    }

    return const SessionState.unauthenticated();
  }

  SessionSnapshot _buildSnapshot(
    PrivyUser user, {
    SessionSnapshot? previous,
    String? overrideLoginMethod,
  }) {
    final providers = <String>{};
    String? email = previous?.primaryEmail;
    String? phone = previous?.primaryPhone;

    for (final account in user.linkedAccounts) {
      providers.add(_normalizeAccount(account));

      if (email == null && account is EmailAccount) {
        email = account.emailAddress;
      }

      if (phone == null && account is PhoneNumberAccount) {
        phone = account.phoneNumber;
      }
    }

    final orderedProviders = providers.toList()..sort();

    return SessionSnapshot(
      userId: user.id,
      loginProviders: orderedProviders,
      lastAuthenticatedAt: DateTime.now().toUtc(),
      primaryEmail: email,
      primaryPhone: phone,
      lastLoginMethod: overrideLoginMethod ??
          previous?.lastLoginMethod ??
          _pickDefaultLoginMethod(orderedProviders),
    );
  }

  String _normalizeAccount(LinkedAccounts account) {
    if (account is EmailAccount) return 'email';
    if (account is PhoneNumberAccount) return 'phone';
    if (account is GoogleOAuthAccount) return 'google';
    if (account is TwitterOAuthAccount) return 'twitter';
    if (account is DiscordOAuthAccount) return 'discord';
    if (account is AppleOAuthAccount) return 'apple';
    if (account is CustomAuthAccount) return 'custom';
    return account.type;
  }

  String? _pickDefaultLoginMethod(List<String> providers) {
    const preferenceOrder = <String>[
      'email',
      'google',
      'twitter',
      'discord',
      'apple',
      'phone',
      'custom',
    ];

    for (final candidate in preferenceOrder) {
      if (providers.contains(candidate)) {
        return candidate;
      }
    }

    return providers.isNotEmpty ? providers.first : null;
  }

  Future<void> _syncSnapshotFromAuthState(AuthState authState) async {
    final user = authState.user ?? await _authService.getCurrentUser();
    if (user == null) {
      return;
    }

    final snapshot = _buildSnapshot(
      user,
      previous: state.asData?.value.snapshot,
    );

    await _sessionStorage.save(snapshot);
    state = AsyncValue.data(SessionState.authenticated(snapshot));
  }

  Future<void> _handleUnauthenticatedState() async {
    await _sessionStorage.clear();
    await _jwtStorage.clearToken();
    state = const AsyncValue.data(SessionState.unauthenticated());
  }

  Future<void> _confirmUnauthenticatedSignal() async {
    try {
      await _authService.waitForReady();
      final refreshed = await _authService.refreshAuthState();

      if (refreshed != null && refreshed.isAuthenticated) {
        await _syncSnapshotFromAuthState(refreshed);
        return;
      }
    } catch (error, stackTrace) {
      AppLogger.e('Failed to confirm unauthenticated state', error, stackTrace);
    }

    await _handleUnauthenticatedState();
  }
}

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, SessionState>(
  SessionController.new,
);
