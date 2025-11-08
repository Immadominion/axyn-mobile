import 'package:flutter/foundation.dart';

/// Immutable snapshot of the authenticated user's identity surfaced in the app.
/// Merged from Privy (authentication) + Backend API (profile & statistics)
@immutable
class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.walletAddress,
    required this.memberSince,
    this.backendUserId,
    this.privyUserId,
    this.email,
    this.balance = 0.0,
    this.bio,
    this.avatarUrl,
    this.loginMethod,
    this.phoneNumber,
    this.twitterUsername,
    this.discordUsername,
    this.totalAgentsHired = 0,
    this.totalSpent = 0.0,
    this.totalAgentsListed = 0,
    this.totalEarned = 0.0,
  });

  // Core identity
  final int? backendUserId; // null if backend unavailable
  final String? privyUserId;
  final String walletAddress;
  final DateTime memberSince;

  // Display info
  final String displayName;
  final String? email;
  final String? bio;
  final String? avatarUrl;

  // Wallet balance (from blockchain)
  final double balance;

  // Login method & additional identities
  final String? loginMethod; // google, twitter, discord, email, phone
  final String? phoneNumber;
  final String? twitterUsername;
  final String? discordUsername;

  // Statistics - Agent hiring
  final int totalAgentsHired;
  final double totalSpent;

  // Statistics - Agent listing
  final int totalAgentsListed;
  final double totalEarned;

  // Computed properties
  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  bool get isAgentProvider => totalAgentsListed > 0;

  /// Get the best available contact identifier for display
  String get primaryIdentity {
    if (email != null && email!.isNotEmpty) return email!;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) return phoneNumber!;
    if (twitterUsername != null && twitterUsername!.isNotEmpty) {
      return '@$twitterUsername';
    }
    if (discordUsername != null && discordUsername!.isNotEmpty) {
      return discordUsername!;
    }
    return '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}';
  }

  /// Check if user has multiple verified identities
  bool get hasMultipleIdentities {
    int count = 0;
    if (hasEmail) count++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) count++;
    if (twitterUsername != null && twitterUsername!.isNotEmpty) count++;
    if (discordUsername != null && discordUsername!.isNotEmpty) count++;
    return count > 1;
  }

  /// Get formatted member duration (e.g., "Member for 2 months")
  String get memberDuration {
    final now = DateTime.now();
    final difference = now.difference(memberSince);

    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week' : '$weeks weeks';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month' : '$months months';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year' : '$years years';
    }
  }

  /// Copy with method for immutable updates
  UserProfile copyWith({
    int? backendUserId,
    String? privyUserId,
    String? displayName,
    String? walletAddress,
    String? email,
    double? balance,
    String? bio,
    String? avatarUrl,
    String? loginMethod,
    String? phoneNumber,
    String? twitterUsername,
    String? discordUsername,
    int? totalAgentsHired,
    double? totalSpent,
    int? totalAgentsListed,
    double? totalEarned,
    DateTime? memberSince,
  }) {
    return UserProfile(
      backendUserId: backendUserId ?? this.backendUserId,
      privyUserId: privyUserId ?? this.privyUserId,
      displayName: displayName ?? this.displayName,
      walletAddress: walletAddress ?? this.walletAddress,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      loginMethod: loginMethod ?? this.loginMethod,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      twitterUsername: twitterUsername ?? this.twitterUsername,
      discordUsername: discordUsername ?? this.discordUsername,
      totalAgentsHired: totalAgentsHired ?? this.totalAgentsHired,
      totalSpent: totalSpent ?? this.totalSpent,
      totalAgentsListed: totalAgentsListed ?? this.totalAgentsListed,
      totalEarned: totalEarned ?? this.totalEarned,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
