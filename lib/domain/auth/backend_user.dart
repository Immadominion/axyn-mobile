/// User model from backend API
/// Represents comprehensive user profile including identity, statistics, and preferences
class BackendUser {
  const BackendUser({
    required this.id,
    required this.privyUserId,
    required this.walletAddress,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.name,
    this.bio,
    this.avatarUrl,
    this.loginMethod,
    this.phoneNumber,
    this.twitterUsername,
    this.discordUsername,
    this.googleEmail,
    this.totalAgentsHired = 0,
    this.totalSpent = 0.0,
    this.totalAgentsListed = 0,
    this.totalEarned = 0.0,
  });

  // Core identity
  final int id;
  final String privyUserId;
  final String walletAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Profile info
  final String? name;
  final String? email;
  final String? bio;
  final String? avatarUrl;

  // Login method tracking
  final String? loginMethod; // google, twitter, discord, email, phone

  // Additional identity fields from various login methods
  final String? phoneNumber;
  final String? twitterUsername;
  final String? discordUsername;
  final String? googleEmail;

  // User statistics - Agent hiring side
  final int totalAgentsHired;
  final double totalSpent;

  // User statistics - Agent listing side
  final int totalAgentsListed;
  final double totalEarned;

  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      id: json['id'] as int,
      privyUserId: json['privyUserId'] as String,
      walletAddress: json['walletAddress'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      email: json['email'] as String?,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      loginMethod: json['loginMethod'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      twitterUsername: json['twitterUsername'] as String?,
      discordUsername: json['discordUsername'] as String?,
      googleEmail: json['googleEmail'] as String?,
      totalAgentsHired: json['totalAgentsHired'] as int? ?? 0,
      totalSpent: _parseDouble(json['totalSpent']) ?? 0.0,
      totalAgentsListed: json['totalAgentsListed'] as int? ?? 0,
      totalEarned: _parseDouble(json['totalEarned']) ?? 0.0,
    );
  }

  // Helper to parse decimal values that may come as strings from PostgreSQL
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'privyUserId': privyUserId,
        'walletAddress': walletAddress,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (loginMethod != null) 'loginMethod': loginMethod,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (twitterUsername != null) 'twitterUsername': twitterUsername,
        if (discordUsername != null) 'discordUsername': discordUsername,
        if (googleEmail != null) 'googleEmail': googleEmail,
        'totalAgentsHired': totalAgentsHired,
        'totalSpent': totalSpent,
        'totalAgentsListed': totalAgentsListed,
        'totalEarned': totalEarned,
      };

  /// Get the best available display identifier
  /// Priority: name > twitterUsername > email localPart > phone > wallet snippet
  String get bestDisplayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (twitterUsername != null && twitterUsername!.isNotEmpty) {
      return '@$twitterUsername';
    }
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) return phoneNumber!;
    return '${walletAddress.substring(0, 4)}...${walletAddress.substring(walletAddress.length - 4)}';
  }

  /// Get primary identity string for display
  /// Shows the most relevant contact method
  String? get primaryIdentity {
    if (email != null && email!.isNotEmpty) return email;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) return phoneNumber;
    if (twitterUsername != null && twitterUsername!.isNotEmpty) {
      return '@$twitterUsername';
    }
    if (discordUsername != null && discordUsername!.isNotEmpty) {
      return discordUsername;
    }
    return null;
  }

  /// Check if user has multiple identity methods linked
  bool get hasMultipleIdentities {
    int count = 0;
    if (email != null && email!.isNotEmpty) count++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) count++;
    if (twitterUsername != null && twitterUsername!.isNotEmpty) count++;
    if (discordUsername != null && discordUsername!.isNotEmpty) count++;
    return count > 1;
  }

  /// Check if user is an agent provider
  bool get isAgentProvider => totalAgentsListed > 0;
}
