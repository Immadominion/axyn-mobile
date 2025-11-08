import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privy_flutter/privy_flutter.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';

/// Enum representing different login methods available
enum LoginMethod {
  google,
  twitter,
  discord,
  email;

  /// Convert to Privy's OAuth provider type
  OAuthProvider toPrivyOAuth() {
    switch (this) {
      case LoginMethod.google:
        return OAuthProvider.google;
      case LoginMethod.twitter:
        return OAuthProvider.twitter;
      case LoginMethod.discord:
        return OAuthProvider.discord;
      case LoginMethod.email:
        throw UnsupportedError('Email login does not use OAuth');
    }
  }
}

/// Result of Privy authentication
class PrivyAuthResult {
  const PrivyAuthResult({
    required this.success,
    this.userId,
    this.walletAddress,
    this.error,
  });

  final bool success;
  final String? userId;
  final String? walletAddress;
  final String? error;

  factory PrivyAuthResult.success({
    required String userId,
    String? walletAddress,
  }) {
    return PrivyAuthResult(
      success: true,
      userId: userId,
      walletAddress: walletAddress,
    );
  }

  factory PrivyAuthResult.failure(String error) {
    return PrivyAuthResult(
      success: false,
      error: error,
    );
  }

  factory PrivyAuthResult.cancelled() {
    return const PrivyAuthResult(
      success: false,
      error: 'Login cancelled by user',
    );
  }
}

/// Generic success/failure result for non-auth Privy operations
class PrivyOperationResult {
  const PrivyOperationResult._({required this.success, this.error});

  final bool success;
  final String? error;

  factory PrivyOperationResult.success() {
    return const PrivyOperationResult._(success: true);
  }

  factory PrivyOperationResult.failure(String error) {
    return PrivyOperationResult._(success: false, error: error);
  }
}

/// Service for handling Privy authentication
class PrivyAuthService {
  PrivyAuthService(this._config) {
    _initializePrivy();
  }

  final AppConfig _config;
  late final Privy _privy;
  bool _isInitialized = false;

  /// Initialize Privy SDK
  void _initializePrivy() {
    try {
      final privyConfig = PrivyConfig(
        appId: _config.privyAppId,
        appClientId: _config.privyClientId,
        logLevel:
            _config.enableLogging ? PrivyLogLevel.verbose : PrivyLogLevel.none,
      );

      _privy = Privy.init(config: privyConfig);
      _isInitialized = true;

      AppLogger.d('Privy SDK initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to initialize Privy SDK', e, stackTrace);
      _isInitialized = false;
    }
  }

  /// Wait for Privy to be ready
  Future<void> waitForReady() async {
    if (!_isInitialized) {
      throw StateError('Privy SDK not initialized');
    }

    try {
      await _privy.awaitReady();
      AppLogger.d('Privy SDK is ready');
    } catch (e, stackTrace) {
      AppLogger.e('Error waiting for Privy to be ready', e, stackTrace);
      rethrow;
    }
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    if (!_isInitialized) return false;

    try {
      final authState = await refreshAuthState();
      final isAuth = authState?.isAuthenticated ?? false;
      AppLogger.d('User authentication status: $isAuth');
      return isAuth;
    } catch (e, stackTrace) {
      AppLogger.e('Error checking authentication status', e, stackTrace);
      return false;
    }
  }

  /// Refresh and return the latest Privy authentication state.
  Future<AuthState?> refreshAuthState() async {
    if (!_isInitialized) return null;

    try {
      await waitForReady();
      final authState = await _privy.getAuthState();
      AppLogger.d('Fetched Privy auth state: ${authState.runtimeType}');
      return authState;
    } catch (e, stackTrace) {
      AppLogger.e('Error refreshing Privy auth state', e, stackTrace);
      return null;
    }
  }

  /// Get current user
  Future<PrivyUser?> getCurrentUser() async {
    if (!_isInitialized) return null;

    try {
      await waitForReady();
      final user = await _privy.getUser();
      AppLogger.d('Current user: ${user?.id}');
      return user;
    } catch (e, stackTrace) {
      AppLogger.e('Error getting current user', e, stackTrace);
      return null;
    }
  }

  /// Ensure the authenticated user has an embedded Solana wallet.
  /// Returns the wallet instance ready for signing, creating it if needed.
  Future<EmbeddedSolanaWallet?> ensureEmbeddedSolanaWallet() async {
    if (!_isInitialized) {
      AppLogger.e('Cannot ensure wallet: Privy SDK not initialized');
      return null;
    }

    try {
      await waitForReady();

      var user = await _privy.getUser();
      if (user == null) {
        AppLogger.e('Cannot ensure wallet: no authenticated user');
        return null;
      }

      if (user.embeddedSolanaWallets.isNotEmpty) {
        final wallet = user.embeddedSolanaWallets.first;
        AppLogger.d('Found existing embedded wallet: ${wallet.address}');
        return wallet;
      }

      AppLogger.d('No embedded wallet found. Creating a new one...');
      final creationResult = await user.createSolanaWallet();

      if (creationResult is Success<EmbeddedSolanaWallet>) {
        final wallet = creationResult.value;
        AppLogger.d('Created new embedded wallet: ${wallet.address}');
        return wallet;
      }

      if (creationResult is Failure) {
        AppLogger.e('Failed to create embedded wallet', creationResult);
      }

      // Refresh user in case the wallet was created but response not returned.
      user = await _privy.getUser();
      if (user?.embeddedSolanaWallets.isNotEmpty ?? false) {
        final wallet = user!.embeddedSolanaWallets.first;
        AppLogger.d(
            'Embedded wallet available after refresh: ${wallet.address}');
        return wallet;
      }

      AppLogger.e('Unable to provision embedded Solana wallet');
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('Error ensuring embedded wallet', e, stackTrace);
      return null;
    }
  }

  /// Authenticate user with specified login method
  Future<PrivyAuthResult> authenticate(LoginMethod method) async {
    if (!_isInitialized) {
      return PrivyAuthResult.failure('Privy SDK not initialized');
    }

    try {
      AppLogger.d('Starting authentication with method: $method');

      // Handle email separately
      if (method == LoginMethod.email) {
        AppLogger.w(
          'Email login attempted via authenticate(); use loginWithEmailCode instead.',
        );
        return PrivyAuthResult.failure(
            'Email login requires a verification code.');
      }

      // Handle OAuth methods
      // TODO: Get the app URL scheme from configuration or package_info
      final result = await _privy.oAuth.login(
        provider: method.toPrivyOAuth(),
        appUrlScheme: 'axyn', // AxyN URL scheme for OAuth redirects
      );

      late PrivyAuthResult authResult;

      result.fold(
        onSuccess: (PrivyUser user) {
          authResult = _mapUserToAuthResult(user);
        },
        onFailure: (PrivyException error) {
          final errorMsg = error.message;
          AppLogger.e('Login failed: $errorMsg');
          authResult = PrivyAuthResult.failure(errorMsg);
        },
      );

      return authResult;
    } catch (e, stackTrace) {
      AppLogger.e('Authentication error', e, stackTrace);
      return PrivyAuthResult.failure(e.toString());
    }
  }

  /// Send an email OTP via Privy
  Future<PrivyOperationResult> sendEmailCode(String email) async {
    if (!_isInitialized) {
      return PrivyOperationResult.failure('Privy SDK not initialized');
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return PrivyOperationResult.failure('Email is required');
    }

    try {
      await waitForReady();
      final result = await _privy.email.sendCode(trimmedEmail);

      late PrivyOperationResult operationResult;

      result.fold(
        onSuccess: (_) {
          AppLogger.d('OTP sent to email $trimmedEmail');
          operationResult = PrivyOperationResult.success();
        },
        onFailure: (PrivyException error) {
          final errorMsg = error.message;
          AppLogger.e('Failed to send email OTP: $errorMsg');
          operationResult = PrivyOperationResult.failure(errorMsg);
        },
      );

      return operationResult;
    } catch (e, stackTrace) {
      AppLogger.e('Error sending email OTP', e, stackTrace);
      return PrivyOperationResult.failure(e.toString());
    }
  }

  /// Verify an email OTP and authenticate the user
  Future<PrivyAuthResult> loginWithEmailCode({
    required String email,
    required String code,
  }) async {
    if (!_isInitialized) {
      return PrivyAuthResult.failure('Privy SDK not initialized');
    }

    final trimmedEmail = email.trim();
    final trimmedCode = code.trim();

    if (trimmedEmail.isEmpty || trimmedCode.isEmpty) {
      return PrivyAuthResult.failure('Email and code are required');
    }

    try {
      await waitForReady();
      final result = await _privy.email.loginWithCode(
        email: trimmedEmail,
        code: trimmedCode,
      );

      late PrivyAuthResult authResult;

      result.fold(
        onSuccess: (PrivyUser user) {
          authResult = _mapUserToAuthResult(user);
        },
        onFailure: (PrivyException error) {
          final errorMsg = error.message;
          AppLogger.e('Email OTP verification failed: $errorMsg');
          authResult = PrivyAuthResult.failure(errorMsg);
        },
      );

      return authResult;
    } catch (e, stackTrace) {
      AppLogger.e('Email OTP verification error', e, stackTrace);
      return PrivyAuthResult.failure(e.toString());
    }
  }

  /// Create an embedded Solana wallet for the authenticated user
  /// TODO: Implement wallet creation using Privy SDK
  Future<String?> createSolanaWallet() async {
    if (!_isInitialized) {
      AppLogger.e('Cannot create wallet: Privy SDK not initialized');
      return null;
    }

    try {
      final authState = await _privy.getAuthState();

      if (!authState.isAuthenticated) {
        AppLogger.e('Cannot create wallet: User not authenticated');
        return null;
      }

      AppLogger.d('Creating Solana wallet for user');

      // TODO: Implement wallet creation when Privy SDK exposes the API
      // For now, check if user already has a wallet
      final user = await _privy.getUser();
      if (user != null) {
        final solanaWallet = user.linkedAccounts.firstWhere(
          (LinkedAccounts account) => account is EmbeddedSolanaWalletAccount,
          orElse: () => user.linkedAccounts.first,
        );

        if (solanaWallet is EmbeddedSolanaWalletAccount) {
          AppLogger.d(
              'User already has Solana wallet: ${solanaWallet.address}');
          return solanaWallet.address;
        }
      }

      AppLogger.w('Wallet creation API not yet implemented in service');
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('Error creating wallet', e, stackTrace);
      return null;
    }
  }

  ///Get the user's JWT access token for backend authentication
  Future<String?> getAccessToken() async {
    if (!_isInitialized) {
      AppLogger.e('Cannot get access token: Privy SDK not initialized');
      return null;
    }

    try {
      await waitForReady();

      // Check if user is authenticated first
      final authState = await _privy.getAuthState();
      if (!authState.isAuthenticated) {
        AppLogger.e('Cannot get access token: User not authenticated');
        return null;
      }

      // Get the authenticated user
      final user = await _privy.getUser();
      if (user == null) {
        AppLogger.e('Cannot get access token: User not found');
        return null;
      }

      // Get the JWT access token from the user
      final result = await user.getAccessToken();

      String? token;
      result.fold(
        onSuccess: (String accessToken) {
          AppLogger.d('Access token retrieved successfully');
          token = accessToken;
        },
        onFailure: (PrivyException error) {
          AppLogger.e('Failed to get access token: ${error.message}');
        },
      );

      return token;
    } catch (e, stackTrace) {
      AppLogger.e('Error getting access token', e, stackTrace);
      return null;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    if (!_isInitialized) return;

    try {
      await waitForReady();
      await _privy.logout();
      AppLogger.d('User logged out successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Logout error', e, stackTrace);
      rethrow;
    }
  }

  /// Get the Privy instance (for advanced use cases)
  Privy get instance {
    if (!_isInitialized) {
      throw StateError('Privy SDK not initialized');
    }
    return _privy;
  }

  PrivyAuthResult _mapUserToAuthResult(PrivyUser user) {
    String? walletAddress;
    if (user.linkedAccounts.isNotEmpty) {
      final solanaWallet = user.linkedAccounts.firstWhere(
        (LinkedAccounts account) => account is EmbeddedSolanaWalletAccount,
        orElse: () => user.linkedAccounts.first,
      );

      if (solanaWallet is EmbeddedSolanaWalletAccount) {
        walletAddress = solanaWallet.address;
      }
    }

    AppLogger.d('Login successful: userId=${user.id}, wallet=$walletAddress');

    return PrivyAuthResult.success(
      userId: user.id,
      walletAddress: walletAddress,
    );
  }
}

/// Provider for PrivyAuthService
final privyAuthServiceProvider = Provider<PrivyAuthService>((ref) {
  final config = ref.watch(appConfigProvider);
  return PrivyAuthService(config);
});

/// Provider for current authentication state
final authStateProvider = StreamProvider<AuthState>((ref) async* {
  final service = ref.watch(privyAuthServiceProvider);

  try {
    // Use the auth state stream from Privy SDK
    await for (final state in service.instance.authStateStream) {
      yield state;
    }
  } catch (e, stackTrace) {
    AppLogger.e('Error in auth state stream', e, stackTrace);
    rethrow;
  }
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(privyAuthServiceProvider);
  return service.isAuthenticated();
});

/// Provider for current user
final currentUserProvider = FutureProvider<PrivyUser?>((ref) async {
  final service = ref.watch(privyAuthServiceProvider);
  return service.getCurrentUser();
});
