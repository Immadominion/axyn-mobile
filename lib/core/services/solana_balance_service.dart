import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axyn_mobile/core/config/app_config.dart';
import 'package:axyn_mobile/core/logging/app_logger.dart';

/// Service for fetching Solana wallet balances via Helius RPC.
class SolanaBalanceService {
  SolanaBalanceService(this._config);

  final AppConfig _config;
  final _dio = Dio();

  /// Fetch USDC balance for a given Solana wallet address.
  ///
  /// Uses Helius RPC to query SPL token accounts filtered by USDC mint.
  /// Returns balance in USDC (e.g., 10.50 for 10.50 USDC).
  Future<double> fetchUsdcBalance(String walletAddress) async {
    try {
      // Use network-specific USDC mint from config
      final usdcMint = _config.usdcMintAddress;

      final rpcUrl = _config.heliusRpcUrl;

      AppLogger.d('Fetching USDC balance for $walletAddress from $rpcUrl');

      final response = await _dio.post<Map<String, dynamic>>(
        rpcUrl,
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getTokenAccountsByOwner',
          'params': [
            walletAddress,
            {
              'mint': usdcMint,
            },
            {
              'encoding': 'jsonParsed',
            },
          ],
        },
      );

      final result = response.data?['result'] as Map<String, dynamic>?;
      final accounts = result?['value'] as List<dynamic>?;

      if (accounts == null || accounts.isEmpty) {
        AppLogger.d('No USDC token accounts found for $walletAddress');
        return 0.0;
      }

      // Sum up all USDC token accounts (usually just one)
      double totalBalance = 0.0;
      for (final account in accounts) {
        final parsed =
            account['account']?['data']?['parsed'] as Map<String, dynamic>?;
        final info = parsed?['info'] as Map<String, dynamic>?;
        final tokenAmount = info?['tokenAmount'] as Map<String, dynamic>?;

        if (tokenAmount != null) {
          final uiAmount = tokenAmount['uiAmount'] as num?;
          if (uiAmount != null) {
            totalBalance += uiAmount.toDouble();
          }
        }
      }

      AppLogger.d('USDC balance for $walletAddress: $totalBalance');
      return totalBalance;
    } catch (error, stackTrace) {
      AppLogger.e('Failed to fetch USDC balance', error, stackTrace);
      return 0.0; // Return 0 on error rather than throwing
    }
  }

  /// Fetch SOL balance for a given wallet address.
  ///
  /// Returns balance in SOL (e.g., 1.5 for 1.5 SOL).
  Future<double> fetchSolBalance(String walletAddress) async {
    try {
      final rpcUrl = _config.heliusRpcUrl;

      AppLogger.d('Fetching SOL balance for $walletAddress from $rpcUrl');

      final response = await _dio.post<Map<String, dynamic>>(
        rpcUrl,
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getBalance',
          'params': [walletAddress],
        },
      );

      final result = response.data?['result'] as Map<String, dynamic>?;
      final lamports = result?['value'] as num?;

      if (lamports == null) {
        AppLogger.d('Could not fetch SOL balance for $walletAddress');
        return 0.0;
      }

      // Convert lamports to SOL (1 SOL = 1,000,000,000 lamports)
      final solBalance = lamports / 1000000000;
      AppLogger.d('SOL balance for $walletAddress: $solBalance');
      return solBalance.toDouble();
    } catch (error, stackTrace) {
      AppLogger.e('Failed to fetch SOL balance', error, stackTrace);
      return 0.0;
    }
  }
}

final solanaBalanceServiceProvider = Provider<SolanaBalanceService>((ref) {
  final config = ref.watch(appConfigProvider);
  return SolanaBalanceService(config);
});
