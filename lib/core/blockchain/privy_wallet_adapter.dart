import 'dart:convert';
import 'dart:typed_data';

import 'package:coral_xyz/coral_xyz.dart';
import 'package:privy_flutter/privy_flutter.dart';

import 'package:axyn_mobile/core/logging/app_logger.dart';

/// Wallet adapter that connects Privy with coral_xyz Transaction signing
class PrivyWalletAdapter implements Wallet {
  PrivyWalletAdapter({
    required String walletAddress,
    required EmbeddedSolanaWallet embeddedWallet,
    required Privy privyInstance,
  })  : _publicKey = PublicKey.fromBase58(walletAddress),
        _embeddedWallet = embeddedWallet,
        _privy = privyInstance;

  final PublicKey _publicKey;
  final EmbeddedSolanaWallet _embeddedWallet;
  final Privy _privy;

  @override
  PublicKey get publicKey => _publicKey;

  @override
  Future<T> signTransaction<T>(T transaction) async {
    AppLogger.d('Signing transaction with Privy wallet');

    try {
      // Cast to dynamic to work with coral_xyz Transaction
      final dynamic tx = transaction;

      final Uint8List messageBytes = tx.compileMessage() as Uint8List;
      AppLogger.d('Compiled transaction message: ${messageBytes.length} bytes');

      final signature = await _signMessageBytes(messageBytes);
      tx.addSignature(_publicKey, signature);

      AppLogger.d('Transaction signed successfully');
      return transaction;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to sign transaction', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<T>> signAllTransactions<T>(List<T> transactions) async {
    AppLogger.d('Signing ${transactions.length} transactions');

    final signedTransactions = <T>[];
    for (final transaction in transactions) {
      final signed = await signTransaction(transaction);
      signedTransactions.add(signed);
    }

    return signedTransactions;
  }

  @override
  Future<Uint8List> signMessage(Uint8List message) async {
    AppLogger.d('Signing message');
    return _signMessageBytes(message);
  }

  Future<Uint8List> _signMessageBytes(Uint8List messageBytes) async {
    try {
      final messageBase64 = base64Encode(messageBytes);

      AppLogger.d('Ensuring Privy is ready before signing');
      await _privy.awaitReady();

      AppLogger.d('Requesting signature from Privy (user approval required)');

      // Note: This will show a UI prompt to the user to approve the signature
      // The user must approve within the timeout period
      final signatureResult =
          await _embeddedWallet.provider.signMessage(messageBase64);

      if (signatureResult is Success<String>) {
        final signatureBase64 = signatureResult.value;
        final signatureBytes = base64Decode(signatureBase64);

        if (signatureBytes.length != 64) {
          throw Exception(
            'Invalid signature length: ${signatureBytes.length}. Expected 64 bytes',
          );
        }

        AppLogger.d('Signature received successfully');
        return Uint8List.fromList(signatureBytes);
      } else if (signatureResult is Failure) {
        final failure = signatureResult as Failure;
        final errorMessage = failure.error.toString();
        AppLogger.e('Privy signing failed: $errorMessage');

        // Provide more context for common errors
        if (errorMessage.contains('timed out')) {
          throw Exception(
            'Signature request timed out.',
          );
        } else if (errorMessage.contains('rejected') ||
            errorMessage.contains('denied')) {
          throw Exception('Transaction was rejected by user');
        }

        throw Exception('Privy signing failed: $errorMessage');
      } else {
        throw Exception('Unknown Privy response type');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error signing message bytes', e, stackTrace);
      rethrow;
    }
  }
}
