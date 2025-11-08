import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/logging/app_logger.dart';
import '../../core/services/x402_service.dart';

/// Response from agent proxy API call
class AgentProxyResponse {
  const AgentProxyResponse({
    required this.agentResponse,
    required this.transaction,
  });

  factory AgentProxyResponse.fromJson(Map<String, dynamic> json) {
    return AgentProxyResponse(
      agentResponse: json['agentResponse'],
      transaction: json['transaction'] as Map<String, dynamic>,
    );
  }

  final dynamic agentResponse; // Agent's response (structure depends on agent)
  final Map<String, dynamic> transaction; // Transaction details
}

/// Remote datasource for agent proxy API calls (x402 protected)
///
/// Handles the x402 payment flow:
/// 1. POST /proxy/agent/:id -> 402 Payment Required
/// 2. Parse payment details, sign USDC payment
/// 3. Retry with X-Payment-Signature and X-Payment-Nonce headers
/// 4. Backend verifies payment -> proxies to agent -> returns response
class AgentProxyDatasource {
  AgentProxyDatasource(this._dio, this._x402Service);

  final Dio _dio;
  final X402Service _x402Service;

  /// Call an agent via the x402-protected proxy endpoint
  ///
  /// This method handles the complete x402 payment flow:
  /// - Makes initial request to agent
  /// - Catches 402 response
  /// - Returns payment details to caller (caller must handle payment)
  /// - Accepts payment signature for retry
  ///
  /// Throws [X402PaymentRequired] if payment is needed
  /// Throws [DioException] for other errors
  Future<AgentProxyResponse> callAgent({
    required String agentId,
    required String message,
    String? conversationId,
    Map<String, dynamic>? metadata,
    String? paymentSignature,
    String? paymentNonce,
    List<PlatformFile>? attachedFiles,
  }) async {
    try {
      AppLogger.d('[AgentProxyDatasource] Calling agent $agentId');
      AppLogger.d('[AgentProxyDatasource] Message: $message');
      AppLogger.d(
        '[AgentProxyDatasource] Has payment proof: ${paymentSignature != null}',
      );
      AppLogger.d(
        '[AgentProxyDatasource] Attached files: ${attachedFiles?.length ?? 0}',
      );

      final Map<String, dynamic> body = {
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
        if (metadata != null) 'metadata': metadata,
      };

      // Handle file attachments (currently supports single file)
      if (attachedFiles != null && attachedFiles.isNotEmpty) {
        final file = attachedFiles.first;
        if (file.path != null) {
          AppLogger.d(
            '[AgentProxyDatasource] Reading file: ${file.name} (${file.size} bytes)',
          );

          // Read file bytes and convert to base64
          final fileBytes = await File(file.path!).readAsBytes();
          final base64File = base64Encode(fileBytes);

          body['file'] = base64File;
          body['filename'] = file.name;

          AppLogger.d(
            '[AgentProxyDatasource] Encoded file to base64 (${base64File.length} chars)',
          );
        }
      }

      final Map<String, String> headers = {};
      if (paymentSignature != null && paymentNonce != null) {
        headers.addAll(
          _x402Service.buildPaymentHeaders(
            txSignature: paymentSignature,
            nonce: paymentNonce,
          ),
        );
        AppLogger.d('[AgentProxyDatasource] Added payment headers to request');
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/proxy/agent/$agentId',
        data: body,
        options: Options(
          headers: headers,
          // Increased timeout to 150s to accommodate slow agents (HF Spaces cold starts)
          receiveTimeout: const Duration(seconds: 150),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      AppLogger.d(
        '[AgentProxyDatasource] Agent responded: ${response.statusCode}',
      );

      return AgentProxyResponse.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (e) {
      // Check if this is a 402 Payment Required response
      if (_x402Service.is402Response(e)) {
        AppLogger.d('[AgentProxyDatasource] Received 402 Payment Required');

        final paymentDetails = _x402Service.extractPaymentDetails(e.response);
        if (paymentDetails != null) {
          // Throw the payment details as an exception
          // Caller must catch this and handle payment flow
          throw paymentDetails;
        } else {
          AppLogger.e(
            '[AgentProxyDatasource] Failed to parse 402 payment details',
          );
          throw Exception('Invalid 402 response from backend');
        }
      }

      // Re-throw other errors
      AppLogger.e('[AgentProxyDatasource] Error calling agent: $e');
      rethrow;
    } catch (e, stack) {
      AppLogger.e('[AgentProxyDatasource] Unexpected error: $e');
      AppLogger.e('[AgentProxyDatasource] Stack trace: $stack');
      rethrow;
    }
  }
}
