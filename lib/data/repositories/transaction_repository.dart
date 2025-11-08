import '../datasources/transaction_remote_datasource.dart';

/// Repository for transaction-related operations
class TransactionRepository {
  TransactionRepository(this._datasource);

  final TransactionRemoteDatasource _datasource;

  /// Record a transaction after payment
  Future<Map<String, dynamic>> recordTransaction({
    required int agentId,
    required String signature,
    required double amount,
    String? currency,
    String? metadata,
  }) async {
    return _datasource.recordTransaction(
      agentId: agentId,
      signature: signature,
      amount: amount,
      currency: currency,
      metadata: metadata,
    );
  }

  /// Check if user has paid for an agent
  Future<bool> checkPayment(int agentId) async {
    return _datasource.checkPayment(agentId);
  }

  /// Get user's transaction history
  Future<List<dynamic>> getMyTransactions() async {
    return _datasource.getMyTransactions();
  }

  /// Get user's hired agents
  Future<List<dynamic>> getMyHiredAgents() async {
    return _datasource.getMyHiredAgents();
  }
}
