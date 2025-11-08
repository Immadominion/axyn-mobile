import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privy_flutter/privy_flutter.dart';

import 'package:axyn_mobile/application/auth/session_controller.dart';
import 'package:axyn_mobile/core/logging/app_logger.dart';
import 'package:axyn_mobile/core/services/privy_auth_service.dart';
import 'package:axyn_mobile/core/services/solana_balance_service.dart';
import 'package:axyn_mobile/data/repositories/user_repository.dart';
import 'package:axyn_mobile/domain/auth/backend_user.dart';
import 'package:axyn_mobile/domain/entities/user_profile.dart';

/// Provides an up-to-date view of the authenticated user's profile.
/// Merges data from three sources:
/// 1. Privy SDK (authentication, wallet)
/// 2. Backend API (profile, stats, identity)
/// 3. Solana blockchain (balance)
class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final sessionState = await ref.watch(sessionControllerProvider.future);
    if (!sessionState.isAuthenticated || sessionState.snapshot == null) {
      throw StateError(
          'Cannot build user profile without an authenticated session');
    }

    final snapshot = sessionState.snapshot!;
    final authService = ref.watch(privyAuthServiceProvider);
    final balanceService = ref.watch(solanaBalanceServiceProvider);
    final userRepo = ref.watch(userRepositoryProvider);

    PrivyUser? user;
    EmbeddedSolanaWallet? embeddedWallet;

    try {
      user = await authService.getCurrentUser();

      // Ensure embedded wallet exists, creating it if necessary
      AppLogger.d('Ensuring embedded Solana wallet for user...');
      embeddedWallet = await authService.ensureEmbeddedSolanaWallet();

      if (embeddedWallet == null) {
        // Retry once after a short delay in case of timing issues
        AppLogger.d('First attempt returned null, retrying after delay...');
        await Future<void>.delayed(const Duration(seconds: 2));
        embeddedWallet = await authService.ensureEmbeddedSolanaWallet();
      }
    } catch (error, stackTrace) {
      AppLogger.e('Failed to load Privy user context', error, stackTrace);
    }

    final walletAddress = embeddedWallet?.address ?? _findFirstWallet(user);
    if (walletAddress == null || walletAddress.isEmpty) {
      AppLogger.e('Unable to get wallet address after all attempts');
      throw StateError(
        'Could not create embedded wallet. Please try logging in again.',
      );
    }

    // Fetch backend user profile (with graceful fallback)
    BackendUser? backendUser;
    try {
      AppLogger.d('📡 Fetching user profile from backend...');
      backendUser = await userRepo.getCurrentUser();
      AppLogger.d('✅ Backend profile fetched successfully');
      AppLogger.d('   User ID: ${backendUser.id}');
      AppLogger.d('   Login method: ${backendUser.loginMethod}');
      AppLogger.d('   Agents hired: ${backendUser.totalAgentsHired}');
      AppLogger.d('   Agents listed: ${backendUser.totalAgentsListed}');
    } catch (error, stackTrace) {
      AppLogger.w(
        '⚠️  Failed to fetch backend profile, using Privy data only',
        error,
        stackTrace,
      );
      // Continue without backend data - app still works with Privy auth
    }

    // Derive identity data from Privy if backend unavailable
    final privyEmail = snapshot.primaryEmail ?? _extractEmailFromUser(user);

    // Prioritize backend data, fallback to Privy
    final email = backendUser?.email ?? privyEmail;
    final displayName = backendUser?.bestDisplayName ??
        _deriveDisplayName(email, walletAddress);

    // Fetch USDC balance from Solana blockchain via Helius
    AppLogger.d('Fetching USDC balance for wallet: $walletAddress');
    final balance = await balanceService.fetchUsdcBalance(walletAddress);

    return UserProfile(
      backendUserId: backendUser?.id,
      privyUserId: user?.id,
      displayName: displayName,
      walletAddress: walletAddress,
      email: email,
      balance: balance,
      bio: backendUser?.bio,
      avatarUrl: backendUser?.avatarUrl,
      loginMethod: backendUser?.loginMethod,
      phoneNumber: backendUser?.phoneNumber,
      twitterUsername: backendUser?.twitterUsername,
      discordUsername: backendUser?.discordUsername,
      totalAgentsHired: backendUser?.totalAgentsHired ?? 0,
      totalSpent: backendUser?.totalSpent ?? 0.0,
      totalAgentsListed: backendUser?.totalAgentsListed ?? 0,
      totalEarned: backendUser?.totalEarned ?? 0.0,
      memberSince: backendUser?.createdAt ?? DateTime.now(),
    );
  }

  /// Update user profile on backend
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userRepo = ref.read(userRepositoryProvider);

      AppLogger.d('✏️  Updating user profile on backend...');
      await userRepo.updateProfile(
        name: name,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      AppLogger.d('✅ Profile updated successfully');

      // Rebuild profile with updated data
      return build();
    });
  }

  String? _findFirstWallet(PrivyUser? user) {
    if (user == null) return null;
    if (user.embeddedSolanaWallets.isNotEmpty) {
      return user.embeddedSolanaWallets.first.address;
    }

    // Fallback: attempt to discover any linked account exposing an address.
    for (final account in user.linkedAccounts) {
      // Some linked account implementations expose an `address` getter via `toJson`.
      try {
        final dynamic dynamicAccount = account;
        final address = dynamicAccount.address as String?;
        if (address != null && address.isNotEmpty) {
          return address;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  String? _extractEmailFromUser(PrivyUser? user) {
    if (user == null) return null;
    for (final account in user.linkedAccounts) {
      if (account is EmailAccount) {
        return account.emailAddress;
      }
    }
    return null;
  }

  String _deriveDisplayName(
    String? email,
    String walletAddress,
  ) {
    if (email != null && email.isNotEmpty) {
      final localPart = email.split('@').first;
      if (localPart.isNotEmpty) {
        return localPart;
      }
    }

    if (walletAddress.length <= 8) {
      return walletAddress;
    }

    final prefix = walletAddress.substring(0, 4);
    final suffix = walletAddress.substring(walletAddress.length - 4);
    return '$prefix…$suffix';
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);
