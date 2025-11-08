import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/network/dio_client.dart';
import '../../data/repositories/transaction_repository.dart';

// Datasource provider
final transactionRemoteDatasourceProvider =
    Provider<TransactionRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return TransactionRemoteDatasource(dio);
});

// Repository provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final datasource = ref.watch(transactionRemoteDatasourceProvider);
  return TransactionRepository(datasource);
});

// Transaction list provider (user's history)
final userTransactionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getMyTransactions();
});

// Hired agents provider (agents user has paid for)
final hiredAgentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getMyHiredAgents();
});
