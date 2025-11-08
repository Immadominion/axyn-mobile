import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

import 'package:axyn_mobile/core/config/app_config.dart';
import 'package:axyn_mobile/core/constants/solana_tokens.dart';
import 'package:axyn_mobile/core/logging/app_logger.dart';

/// Provider for Solana RPC client
final solanaClientProvider = Provider<SolanaClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return SolanaClient(
    rpcUrl: Uri.parse(config.heliusRpcUrl),
    websocketUrl: Uri.parse(config.heliusRpcUrl.replaceFirst('https', 'wss')),
  );
});

/// Fetches the USDC token balance for a given wallet/owner address.
///
/// The address can be a regular wallet or a PDA. When an
/// associated token account does not yet exist, the provider resolves to 0
/// without treating it as an error.
final usdcBalanceProvider = FutureProvider.autoDispose
    .family<double, String>((ref, ownerAddress) async {
  if (ownerAddress.isEmpty) {
    return 0;
  }

  final client = ref.watch(solanaClientProvider);

  try {
    final owner = Ed25519HDPublicKey.fromBase58(ownerAddress);
    final mint = Ed25519HDPublicKey.fromBase58(SolanaTokenMints.usdc);

    final tokenAmount = await client.getTokenBalance(
      owner: owner,
      mint: mint,
    );

    return _tokenAmountToDouble(tokenAmount);
  } on FormatException catch (error, stackTrace) {
    AppLogger.e(
      'Invalid owner address provided for USDC balance lookup: $ownerAddress',
      error,
      stackTrace,
    );
    return 0;
  } on JsonRpcException catch (error) {
    final message = error.message.toLowerCase();
    final hasNoAccount = message.contains('could not find account') ||
        message.contains('does not exist');

    if (hasNoAccount) {
      AppLogger.d(
        'No USDC associated token account found for $ownerAddress; returning 0.',
      );
      return 0;
    }

    AppLogger.e(
      'RPC error while fetching USDC balance for $ownerAddress',
      error,
    );
    return 0;
  } catch (error, stackTrace) {
    AppLogger.e(
      'Unexpected error fetching USDC balance for $ownerAddress',
      error,
      stackTrace,
    );
    return 0;
  }
});

double _tokenAmountToDouble(TokenAmount amount) {
  final uiAmount = amount.uiAmountString;
  if (uiAmount != null) {
    final parsed = double.tryParse(uiAmount);
    if (parsed != null) {
      return parsed;
    }
  }

  final raw = BigInt.tryParse(amount.amount);
  if (raw == null) {
    return 0;
  }

  final divisor = math.pow(10, amount.decimals);
  if (divisor == 0) {
    return 0;
  }

  return raw.toDouble() / divisor.toDouble();
}
