import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({
    required this.isDebugMode,
    required this.apiBaseUrl,
    required this.privyAppId,
    required this.privyClientId,
    required this.heliusRpcUrl,
    required this.solanaNetwork,
    required this.usdcMintAddress,
    this.enableLogging = true,
  });

  final bool isDebugMode;
  final String apiBaseUrl;
  final String privyAppId;
  final String privyClientId;
  final String heliusRpcUrl;
  final String solanaNetwork; // 'mainnet-beta' or 'devnet'
  final String usdcMintAddress; // Network-specific USDC mint
  final bool enableLogging;

  bool get isMainnet => solanaNetwork == 'mainnet-beta';
  bool get isDevnet => solanaNetwork == 'devnet';

  @override
  int get hashCode => Object.hash(
        isDebugMode,
        apiBaseUrl,
        privyAppId,
        privyClientId,
        heliusRpcUrl,
        solanaNetwork,
        usdcMintAddress,
        enableLogging,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppConfig &&
        other.isDebugMode == isDebugMode &&
        other.apiBaseUrl == apiBaseUrl &&
        other.privyAppId == privyAppId &&
        other.privyClientId == privyClientId &&
        other.heliusRpcUrl == heliusRpcUrl &&
        other.solanaNetwork == solanaNetwork &&
        other.usdcMintAddress == usdcMintAddress &&
        other.enableLogging == enableLogging;
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  throw StateError('AppConfig provider not overridden');
});
