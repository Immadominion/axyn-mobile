import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../data/datasources/agent_remote_datasource.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/network/dio_client.dart';
import '../../data/repositories/agent_repository.dart';
import '../../domain/entities/agent_listing.dart';

// Datasource provider
final agentRemoteDatasourceProvider = Provider<AgentRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return AgentRemoteDatasource(dio);
});

// Transaction datasource provider
final transactionRemoteDatasourceProvider =
    Provider<TransactionRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return TransactionRemoteDatasource(dio);
});

// Repository provider
final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  final datasource = ref.watch(agentRemoteDatasourceProvider);
  return AgentRepository(datasource);
});

// Agent list controller provider
final agentListControllerProvider =
    AsyncNotifierProvider<AgentListController, List<AgentListing>>(
  AgentListController.new,
);

// Agent detail provider (fetches single agent by ID)
final agentDetailProvider =
    FutureProvider.family<AgentListing, String>((ref, id) async {
  final repository = ref.watch(agentRepositoryProvider);
  return repository.getAgentById(id);
});

// My agents provider (user's created agents)
final myAgentsProvider = FutureProvider<List<AgentListing>>((ref) async {
  final repository = ref.watch(agentRepositoryProvider);
  return repository.getMyAgents();
});

// Hired agents provider (agents user has paid for)
final myHiredAgentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final datasource = ref.watch(transactionRemoteDatasourceProvider);
  return datasource.getMyHiredAgents();
});

// My transactions provider
final myTransactionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final datasource = ref.watch(transactionRemoteDatasourceProvider);
  return datasource.getMyTransactions();
});

// Computed stats provider
final myAgentStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final hiredAgentsAsync = ref.watch(myHiredAgentsProvider);
  final transactionsAsync = ref.watch(myTransactionsProvider);

  return hiredAgentsAsync.when(
    data: (hiredAgents) {
      return transactionsAsync.when(
        data: (transactions) {
          // Calculate total spent
          final totalSpent = transactions.fold<double>(
            0.0,
            (sum, txn) {
              final amount = txn['amount'];
              if (amount is num) {
                return sum + amount.toDouble();
              }
              return sum;
            },
          );

          // Calculate queries today
          final now = DateTime.now();
          final startOfDay = DateTime(now.year, now.month, now.day);
          final queriesToday = transactions.where((txn) {
            try {
              final createdAt = DateTime.parse(txn['createdAt'] as String);
              return createdAt.isAfter(startOfDay);
            } catch (e) {
              return false;
            }
          }).length;

          return {
            'totalAgents': hiredAgents.length,
            'totalSpent': totalSpent,
            'queriesToday': queriesToday,
          };
        },
        loading: () => {
          'totalAgents': hiredAgents.length,
          'totalSpent': 0.0,
          'queriesToday': 0,
        },
        error: (_, __) => {
          'totalAgents': hiredAgents.length,
          'totalSpent': 0.0,
          'queriesToday': 0,
        },
      );
    },
    loading: () => {
      'totalAgents': 0,
      'totalSpent': 0.0,
      'queriesToday': 0,
    },
    error: (_, __) => {
      'totalAgents': 0,
      'totalSpent': 0.0,
      'queriesToday': 0,
    },
  );
});

/// Controller for agent list state management
class AgentListController extends AsyncNotifier<List<AgentListing>> {
  @override
  Future<List<AgentListing>> build() async {
    AppLogger.d('[AgentListController] Building agent list');

    try {
      final repository = ref.read(agentRepositoryProvider);
      final agents = await repository.getAllAgents();

      AppLogger.d('[AgentListController] Loaded ${agents.length} agents');
      return agents;
    } catch (e, stack) {
      AppLogger.e('[AgentListController] Error loading agents: $e');
      AppLogger.e('[AgentListController] Stack trace: $stack');
      rethrow;
    }
  }

  /// Refresh agent list
  Future<void> refresh() async {
    AppLogger.d('[AgentListController] Refreshing agent list');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Filter agents by category
  Future<void> filterByCategory(String? category) async {
    AppLogger.d('[AgentListController] Filtering by category: $category');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(agentRepositoryProvider);
      return repository.getAllAgents(category: category);
    });
  }

  /// Search agents by name/description
  Future<void> search(String? query) async {
    AppLogger.d('[AgentListController] Searching agents: $query');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(agentRepositoryProvider);
      return repository.getAllAgents(search: query);
    });
  }

  /// Filter agents by multiple criteria
  Future<void> filter({
    String? category,
    String? search,
    bool? isOnline,
  }) async {
    AppLogger.d('[AgentListController] Filtering agents');
    AppLogger.d('  category: $category');
    AppLogger.d('  search: $search');
    AppLogger.d('  isOnline: $isOnline');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(agentRepositoryProvider);
      return repository.getAllAgents(
        category: category,
        search: search,
        isOnline: isOnline,
      );
    });
  }
}
