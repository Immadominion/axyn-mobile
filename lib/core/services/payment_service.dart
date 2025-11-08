import 'dart:convert' hide Encoding;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/dto.dart' show Encoding;
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

import '../config/app_config.dart';
import '../constants/solana_tokens.dart';
import '../logging/app_logger.dart';
import 'privy_auth_service.dart';

/// Service for handling x402 payments using Privy embedded wallet
///
/// This service creates USDC SPL token transfers on Solana, signs them with
/// Privy's embedded wallet, and broadcasts to the network.
class PaymentService {
  PaymentService(this._authService, this._config);

  final PrivyAuthService _authService;
  final AppConfig _config;

  // Lazy-initialized Solana RPC client
  SolanaClient? _solanaClient;

  SolanaClient get _client {
    _solanaClient ??= SolanaClient(
      rpcUrl: Uri.parse(_config.heliusRpcUrl),
      websocketUrl: Uri.parse(
        _config.heliusRpcUrl.replaceFirst('http', 'ws'),
      ),
    );
    return _solanaClient!;
  }

  /// Create and sign a USDC payment transaction
  ///
  /// This is the real implementation using solana package + Privy wallet signing:
  /// 1. Gets user's USDC associated token account
  /// 2. Gets recipient's USDC associated token account
  /// 3. Creates SPL token transfer instruction
  /// 4. Builds and signs transaction with Privy
  /// 5. Sends to Solana network
  /// 6. Returns transaction signature
  Future<String> payAgent({
    required String recipientAddress,
    required double amountUsd,
    required String agentName,
    String network = 'mainnet-beta', // Network from backend 402 response
  }) async {
    try {
      AppLogger.d('💰 [PaymentService] Initiating USDC payment');
      AppLogger.d('   Recipient: $recipientAddress');
      AppLogger.d('   Amount: \$$amountUsd USDC');
      AppLogger.d('   Agent: $agentName');
      AppLogger.d('   Network: $network');

      // Get user's wallet
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Ensure user has an embedded Solana wallet
      final solanaWallet = await _authService.ensureEmbeddedSolanaWallet();
      if (solanaWallet == null) {
        throw Exception('Failed to get Solana wallet');
      }

      final senderAddress = solanaWallet.address;
      AppLogger.d('   Sender wallet: $senderAddress');

      // Convert amount to lamports (USDC has 6 decimals)
      final amountLamports = (amountUsd * 1e6).toInt();
      AppLogger.d('   Amount in lamports: $amountLamports');

      // Get USDC mint address based on network from backend
      final usdcMint = network == 'devnet'
          ? SolanaTokenMints.usdcDevnet
          : SolanaTokenMints.usdc;
      AppLogger.d('   USDC mint: $usdcMint');

      // Parse addresses
      final senderPubkey = Ed25519HDPublicKey.fromBase58(senderAddress);
      final recipientPubkey = Ed25519HDPublicKey.fromBase58(recipientAddress);
      final usdcMintPubkey = Ed25519HDPublicKey.fromBase58(usdcMint);

      // Derive associated token accounts
      AppLogger.d('🔍 Deriving associated token accounts...');
      final senderAta = await findAssociatedTokenAddress(
        owner: senderPubkey,
        mint: usdcMintPubkey,
      );
      final recipientAta = await findAssociatedTokenAddress(
        owner: recipientPubkey,
        mint: usdcMintPubkey,
      );

      AppLogger.d('   Sender ATA: ${senderAta.toBase58()}');
      AppLogger.d('   Recipient ATA: ${recipientAta.toBase58()}');

      // Get latest blockhash
      AppLogger.d('📡 Fetching latest blockhash...');
      final blockhashResponse = await _client.rpcClient.getLatestBlockhash();
      final blockhash = blockhashResponse.value.blockhash;
      AppLogger.d('   Blockhash: $blockhash');

      // Check if recipient ATA exists
      AppLogger.d('🔍 Checking if recipient ATA exists...');
      final recipientAtaExists = await _checkAccountExists(recipientAta);

      final instructions = <Instruction>[];

      // Create recipient ATA if it doesn't exist
      if (!recipientAtaExists) {
        AppLogger.d('⚠️  Recipient ATA does not exist, creating it...');
        final createAtaInstruction =
            AssociatedTokenAccountInstruction.createAccount(
          mint: usdcMintPubkey,
          address: recipientAta,
          owner: recipientPubkey,
          funder: senderPubkey,
        );
        instructions.add(createAtaInstruction);
      } else {
        AppLogger.d('✅ Recipient ATA exists');
      }

      // Create SPL token transfer instruction
      AppLogger.d('📝 Creating SPL token transfer instruction...');
      final transferInstruction = TokenInstruction.transfer(
        amount: amountLamports,
        source: senderAta,
        destination: recipientAta,
        owner: senderPubkey,
      );
      instructions.add(transferInstruction);

      // Build message
      AppLogger.d(
          '🔨 Building message with ${instructions.length} instruction(s)...');
      final message = Message(
        instructions: instructions,
      );

      // Compile message
      final compiledMessage = message.compile(
        recentBlockhash: blockhash,
        feePayer: senderPubkey,
      );

      // Get message bytes for signing
      final messageBytes = compiledMessage.toByteArray().toList();
      AppLogger.d('📦 Message compiled: ${messageBytes.length} bytes');

      // Sign with Privy wallet
      AppLogger.d('🔐 Signing message with Privy wallet...');
      final messageBase64 = base64Encode(Uint8List.fromList(messageBytes));
      final signatureResult =
          await solanaWallet.provider.signMessage(messageBase64);

      // Extract signature from result
      // Privy returns Result<String> which can be Success or Failure
      final dynamic resultValue = signatureResult;
      final String signatureBase64;

      if (resultValue.runtimeType.toString().contains('Success')) {
        // It's a Success type, extract value
        signatureBase64 = (resultValue as dynamic).value as String;
      } else {
        throw Exception('Privy signing failed: ${resultValue.toString()}');
      }

      final signatureBytes = base64Decode(signatureBase64);

      if (signatureBytes.length != 64) {
        throw Exception(
          'Invalid signature length: ${signatureBytes.length}. Expected 64 bytes',
        );
      }

      AppLogger.d('✅ Message signed successfully');

      // Build signed transaction (legacy wire format)
      // tx = shortvec(num signatures) || signatures || message bytes
      AppLogger.d('🔧 Constructing signed transaction...');
      final builder = BytesBuilder();
      builder.add(_shortVecEncode(1)); // one signature
      builder.add(signatureBytes);
      builder.add(messageBytes);

      final signedTxBytes = builder.toBytes();
      final signedTxBase64 = base64Encode(signedTxBytes);
      AppLogger.d('   Signed tx size: ${signedTxBytes.length} bytes');

      // Send to network
      AppLogger.d('📡 Broadcasting transaction to Solana network...');
      final signature = await _client.rpcClient.sendTransaction(
        signedTxBase64,
        preflightCommitment: Commitment.confirmed,
      );

      AppLogger.d('✅ Transaction sent successfully!');
      AppLogger.d('   Signature: $signature');
      final explorerClusterQuery =
          network == 'mainnet-beta' ? '' : '?cluster=$network';
      AppLogger.d(
        '   Explorer: https://explorer.solana.com/tx/$signature$explorerClusterQuery',
      );

      return signature;
    } catch (e, stack) {
      AppLogger.e('❌ [PaymentService] Payment failed: $e');
      AppLogger.e('   Stack trace: $stack');
      rethrow;
    }
  }

  /// Checks if an account exists on-chain
  Future<bool> _checkAccountExists(Ed25519HDPublicKey address) async {
    try {
      final accountInfo = await _client.rpcClient.getAccountInfo(
        address.toBase58(),
        commitment: Commitment.confirmed,
        encoding: Encoding.base64,
      );

      final exists = accountInfo.value != null;
      if (exists) {
        AppLogger.d('✅ Account ${address.toBase58()} exists');
      }

      return exists;
    } catch (e) {
      AppLogger.w('Failed to check account existence: $e');
      return false;
    }
  }

  /// Encodes a number as a short vector (compact-u16)
  List<int> _shortVecEncode(int value) {
    if (value < 0x80) {
      return [value];
    } else if (value < 0x4000) {
      return [
        (value & 0x7f) | 0x80,
        (value >> 7) & 0xff,
      ];
    } else {
      return [
        (value & 0x7f) | 0x80,
        ((value >> 7) & 0x7f) | 0x80,
        (value >> 14) & 0xff,
      ];
    }
  }
}

/// Provider for PaymentService
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final authService = ref.watch(privyAuthServiceProvider);
  final config = ref.watch(appConfigProvider);
  return PaymentService(authService, config);
});
