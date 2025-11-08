import 'dart:convert';

import 'package:dio/dio.dart';

import '../logging/app_logger.dart';

/// x402 Payment Details from 402 response
class X402PaymentRequired {
  const X402PaymentRequired({
    required this.amount,
    required this.asset,
    required this.network,
    required this.recipient,
    required this.nonce,
    required this.resource,
    required this.description,
  });

  factory X402PaymentRequired.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>;
    return X402PaymentRequired(
      amount: (payment['amount'] as num).toDouble(),
      asset: payment['asset'] as String,
      network: payment['network'] as String,
      recipient: payment['recipient'] as String,
      nonce: payment['nonce'] as String,
      resource: payment['resource'] as String,
      description: payment['description'] as String,
    );
  }

  final double amount; // In USDC base units (lamports)
  final String asset; // 'USDC'
  final String network; // 'devnet' | 'mainnet-beta'
  final String recipient; // Wallet address to pay
  final String nonce; // Unique payment nonce
  final String resource; // API resource path
  final String description; // Payment description

  /// Convert USDC base units to display format (divide by 1M)
  double get amountUsd => amount / 1000000;
}

/// Service for handling x402 payment protocol
///
/// Implements the x402 payment flow:
/// 1. Initial request returns 402 Payment Required
/// 2. Parse payment details from 402 response
/// 3. Sign USDC payment using Privy wallet
/// 4. Retry request with X-Payment-Signature and X-Payment-Nonce headers
/// 5. Backend verifies payment with Corbits facilitator
/// 6. Access granted, return response
class X402Service {
  X402Service();

  /// Check if a DioException is a 402 Payment Required response
  bool is402Response(DioException error) {
    return error.response?.statusCode == 402;
  }

  /// Extract payment details from 402 response
  X402PaymentRequired? extractPaymentDetails(Response<dynamic>? response) {
    if (response == null || response.statusCode != 402) {
      return null;
    }

    try {
      AppLogger.d('[X402Service] Parsing 402 response');
      AppLogger.d('[X402Service] Response data: ${response.data}');

      final Map<String, dynamic> data;
      if (response.data is String) {
        data = json.decode(response.data as String) as Map<String, dynamic>;
      } else {
        data = response.data as Map<String, dynamic>;
      }

      final paymentDetails = X402PaymentRequired.fromJson(data);

      AppLogger.d(
        '[X402Service] Payment required: \$${paymentDetails.amountUsd} USDC',
      );
      AppLogger.d('[X402Service] Recipient: ${paymentDetails.recipient}');
      AppLogger.d('[X402Service] Nonce: ${paymentDetails.nonce}');

      return paymentDetails;
    } catch (e, stack) {
      AppLogger.e('[X402Service] Failed to parse 402 response: $e');
      AppLogger.e('[X402Service] Stack trace: $stack');
      return null;
    }
  }

  /// Build x402 payment headers for retry request
  Map<String, String> buildPaymentHeaders({
    required String txSignature,
    required String nonce,
  }) {
    return {
      'X-Payment-Signature': txSignature,
      'X-Payment-Nonce': nonce,
    };
  }

  /// Determine if payment should be auto-approved without confirmation dialog
  /// Auto-approve payments under $0.10 as per copilot instructions
  bool shouldAutoApprove(double amountUsd) {
    return amountUsd < 0.10;
  }
}
