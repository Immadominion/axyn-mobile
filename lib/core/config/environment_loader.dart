import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axyn_mobile/core/config/app_config.dart';

/// Service to load environment variables from .env file
class EnvironmentLoader {
  /// Load environment variables from .env
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// Create AppConfig from loaded environment variables
  static AppConfig createConfig() {
    final network = dotenv.get('SOLANA_NETWORK', fallback: 'devnet');

    // Default values based on network
    final defaultRpcUrl = network == 'mainnet-beta'
        ? 'https://api.mainnet-beta.solana.com'
        : 'https://api.devnet.solana.com';

    final defaultUsdcMint = network == 'mainnet-beta'
        ? 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v' // Mainnet USDC
        : '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU'; // Devnet USDC

    return AppConfig(
      isDebugMode: kDebugMode,
      apiBaseUrl: dotenv.get('API_BASE_URL', fallback: 'https://api.axyn.ai'),
      privyAppId: dotenv.get('PRIVY_APP_ID', fallback: ''),
      privyClientId: dotenv.get('PRIVY_CLIENT_ID', fallback: ''),
      heliusRpcUrl: dotenv.get('HELIUS_RPC_URL', fallback: defaultRpcUrl),
      solanaNetwork: network,
      usdcMintAddress:
          dotenv.get('USDC_MINT_ADDRESS', fallback: defaultUsdcMint),
      enableLogging: _getBool('ENABLE_DEBUG_LOGS', defaultValue: kDebugMode),
    );
  }

  static bool _getBool(String key, {required bool defaultValue}) {
    final value = dotenv.maybeGet(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }
}
