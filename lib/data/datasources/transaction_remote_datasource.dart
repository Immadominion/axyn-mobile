import 'package:dio/dio.dart';

import '../../core/logging/app_logger.dart';

/// Datasource for transaction-related API calls
class TransactionRemoteDatasource {
  TransactionRemoteDatasource(this._dio);

  final Dio _dio;

  /// Record a transaction after payment
  Future<Map<String, dynamic>> recordTransaction({
    required int agentId,
    required String signature,
    required double amount,
    String? currency,
    String? metadata,
  }) async {
    try {
      AppLogger.d('[TransactionDatasource] Recording transaction');
      AppLogger.d('  Agent ID: $agentId');
      AppLogger.d('  Signature: $signature');
      AppLogger.d('  Amount: $amount');

      final response = await _dio.post<Map<String, dynamic>>(
        '/transaction',
        data: {
          'agentId': agentId,
          'signature': signature,
          'amount': amount,
          if (currency != null) 'currency': currency,
          if (metadata != null) 'metadata': metadata,
        },
      );

      AppLogger.d('[TransactionDatasource] Transaction recorded successfully');
      return response.data!;
    } catch (e, stack) {
      AppLogger.e('[TransactionDatasource] Error recording transaction: $e');
      AppLogger.e('[TransactionDatasource] Stack trace: $stack');
      rethrow;
    }
  }

  /// Check if user has paid for an agent
  Future<bool> checkPayment(int agentId) async {
    try {
      AppLogger.d(
          '[TransactionDatasource] Checking payment for agent: $agentId');

      final response = await _dio.get<Map<String, dynamic>>(
        '/transaction/check/$agentId',
      );

      final hasPaid = response.data?['hasPaid'] as bool? ?? false;
      AppLogger.d('[TransactionDatasource] Has paid: $hasPaid');
      return hasPaid;
    } catch (e, stack) {
      AppLogger.e('[TransactionDatasource] Error checking payment: $e');
      AppLogger.e('[TransactionDatasource] Stack trace: $stack');
      return false;
    }
  }

  /// Get user's transaction history
  Future<List<dynamic>> getMyTransactions() async {
    try {
      AppLogger.d('[TransactionDatasource] Fetching my transactions');

      final response = await _dio.get<List<dynamic>>(
        '/transaction/my-transactions',
      );

      final transactions = response.data ?? [];
      AppLogger.d(
          '[TransactionDatasource] Found ${transactions.length} transactions');
      return transactions;
    } catch (e, stack) {
      AppLogger.e('[TransactionDatasource] Error fetching transactions: $e');
      AppLogger.e('[TransactionDatasource] Stack trace: $stack');
      rethrow;
    }
  }

  /// Get user's hired agents
  Future<List<dynamic>> getMyHiredAgents() async {
    try {
      AppLogger.d('[TransactionDatasource] Fetching my hired agents');

      final response = await _dio.get<List<dynamic>>(
        '/transaction/my-hired-agents',
      );

      final agents = response.data ?? [];
      AppLogger.d(
          '[TransactionDatasource] Found ${agents.length} hired agents');
      return agents;
    } catch (e, stack) {
      AppLogger.e('[TransactionDatasource] Error fetching hired agents: $e');
      AppLogger.e('[TransactionDatasource] Stack trace: $stack');
      rethrow;
    }
  }

  /// Get user's activity history with prompts and responses
  Future<List<dynamic>> getActivityHistory() async {
    try {
      AppLogger.d('[TransactionDatasource] Fetching activity history');

      final response = await _dio.get<List<dynamic>>(
        '/transaction/activity-history',
      );

      final activities = response.data ?? [];
      AppLogger.d(
          '[TransactionDatasource] Found ${activities.length} activities');
      return activities;
    } catch (e, stack) {
      AppLogger.e(
          '[TransactionDatasource] Error fetching activity history: $e');
      AppLogger.e('[TransactionDatasource] Stack trace: $stack');
      rethrow;
    }
  }

  /// Get detailed activity information
  Future<Map<String, dynamic>> getActivityDetail(int transactionId) async {
    try {
      AppLogger.d(
          '[TransactionDatasource] Fetching activity detail for transaction: $transactionId');

      final response = await _dio.get<Map<String, dynamic>>(
        '/transaction/activity/$transactionId',
      );

      AppLogger.d(
          '[TransactionDatasource] Activity detail fetched successfully');
      return response.data!;
    } catch (e, stack) {
      AppLogger.e('[TransactionDatasource] Error fetching activity detail: $e');
      AppLogger.e('[TransactionDatasource] Stack trace: $stack');
      rethrow;
    }
  }
}
