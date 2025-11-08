import 'dart:convert';
import 'dart:typed_data';

import 'package:coral_xyz/coral_xyz.dart';
import 'package:coral_xyz/src/types/transaction.dart' as types;
import 'package:privy_flutter/privy_flutter.dart';

import '../logging/app_logger.dart';

/// A coral_xyz Wallet implementation that uses Privy embedded wallet for signing
///
/// This adapter bridges coral_xyz's Wallet interface with Privy's embedded Solana wallet,
/// enabling seamless transaction signing for x402 payments in AxyN.
class PrivyWallet implements Wallet {
  final PublicKey _publicKey;
  final EmbeddedSolanaWallet _embeddedWallet;

  PrivyWallet({
    required String walletAddress,
    required EmbeddedSolanaWallet embeddedWallet,
  })  : _publicKey = PublicKey.fromBase58(walletAddress),
        _embeddedWallet = embeddedWallet;

  @override
  PublicKey get publicKey => _publicKey;

  @override
  Future<T> signTransaction<T>(T transaction) async {
    AppLogger.d('🔑 PrivyWallet: Signing transaction...');

    try {
      // Check if this is a Transaction type that we can sign
      if (transaction is types.Transaction) {
        // Get the message bytes to sign
        final messageBytes = transaction.compileMessage();

        AppLogger.d(
          '📝 Compiling transaction message (${messageBytes.length} bytes)',
        );

        // Sign the message bytes using Privy
        final signature = await _signMessageBytes(messageBytes);

        AppLogger.d(
          '✅ Transaction message signed, adding signature to transaction',
        );

        // Add the signature to the transaction
        transaction.addSignature(_publicKey, signature);

        AppLogger.d('✅ Transaction signed successfully');
        return transaction;
      } else {
        // For other transaction types, try to handle generically
        AppLogger.w(
          '⚠️ Unknown transaction type ${T.toString()}, returning as-is',
        );
        return transaction;
      }
    } catch (e) {
      AppLogger.e('❌ Error signing transaction: $e');
      rethrow;
    }
  }

  @override
  Future<List<T>> signAllTransactions<T>(List<T> transactions) async {
    AppLogger.d('🔑 Signing ${transactions.length} transactions...');

    final signedTransactions = <T>[];
    for (final transaction in transactions) {
      final signed = await signTransaction(transaction);
      signedTransactions.add(signed);
    }

    AppLogger.d('✅ All transactions signed successfully');
    return signedTransactions;
  }

  @override
  Future<Uint8List> signMessage(Uint8List message) async {
    AppLogger.d('🔑 Signing message...');
    return await _signMessageBytes(message);
  }

  /// Internal method to sign message bytes using Privy embedded wallet
  ///
  /// Converts message to base64, sends to Privy for signing, returns 64-byte signature
  Future<Uint8List> _signMessageBytes(Uint8List messageBytes) async {
    try {
      AppLogger.d('📝 Signing ${messageBytes.length} bytes with Privy...');

      // Convert to base64 for Privy
      final messageBase64 = base64Encode(messageBytes);

      // Sign with Privy embedded wallet
      final signatureResult = await _embeddedWallet.provider.signMessage(
        messageBase64,
      );

      if (signatureResult is Success<String>) {
        final signatureBase64 = signatureResult.value;
        final signatureBytes = base64Decode(signatureBase64);

        // Validate signature length (Solana Ed25519 signatures are 64 bytes)
        if (signatureBytes.length != 64) {
          throw Exception(
            'Invalid signature length: ${signatureBytes.length}. Expected 64 bytes',
          );
        }

        AppLogger.d('✅ Message signed successfully');
        return Uint8List.fromList(signatureBytes);
      } else if (signatureResult is Failure) {
        throw Exception('Privy signing failed: ${signatureResult.toString()}');
      } else {
        throw Exception('Unknown Privy response type');
      }
    } catch (e) {
      AppLogger.e('❌ Error signing message: $e');
      rethrow;
    }
  }
}
