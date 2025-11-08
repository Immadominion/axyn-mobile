import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/network/dio_client.dart';

// Use the existing transaction datasource provider from agent_list_controller
// But define it here for clarity
final activityTransactionDatasourceProvider =
    Provider<TransactionRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return TransactionRemoteDatasource(dio);
});

// Activity history provider - fetches last 100 activities with previews
final activityHistoryProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    AppLogger.d('[ActivityController] Fetching activity history');
    final datasource = ref.watch(activityTransactionDatasourceProvider);
    final activities = await datasource.getActivityHistory();
    AppLogger.d('[ActivityController] Fetched ${activities.length} activities');
    return activities;
  } catch (e, stack) {
    AppLogger.e('[ActivityController] Error fetching activity history: $e');
    AppLogger.e('[ActivityController] Stack trace: $stack');
    rethrow;
  }
});

// Activity detail provider - fetches full details of a specific activity
final activityDetailProvider = FutureProvider.family<Map<String, dynamic>, int>(
    (ref, transactionId) async {
  try {
    AppLogger.d(
        '[ActivityController] Fetching activity detail for transaction: $transactionId');
    final datasource = ref.watch(activityTransactionDatasourceProvider);
    final detail = await datasource.getActivityDetail(transactionId);
    AppLogger.d('[ActivityController] Activity detail fetched successfully');
    return detail;
  } catch (e, stack) {
    AppLogger.e('[ActivityController] Error fetching activity detail: $e');
    AppLogger.e('[ActivityController] Stack trace: $stack');
    rethrow;
  }
});

// Activity stats provider - computes statistics from activity history
final activityStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final activitiesAsync = ref.watch(activityHistoryProvider);

  return activitiesAsync.when(
    data: (activities) {
      // Calculate statistics
      final totalActivities = activities.length;

      final totalSpent = activities.fold<double>(
        0.0,
        (sum, activity) {
          final amount = activity['amount'];
          if (amount is num) {
            return sum + amount.toDouble();
          }
          return sum;
        },
      );

      // Count by activity type
      final Map<String, int> activityTypeCounts = {};
      for (final activity in activities) {
        final type = activity['activityType'] as String? ?? 'query';
        activityTypeCounts[type] = (activityTypeCounts[type] ?? 0) + 1;
      }

      // Find most used agent
      final Map<String, int> agentUsageCounts = {};
      String? mostUsedAgent;
      int mostUsedCount = 0;

      for (final activity in activities) {
        final agentName = activity['agentName'] as String? ?? 'Unknown';
        agentUsageCounts[agentName] = (agentUsageCounts[agentName] ?? 0) + 1;

        if (agentUsageCounts[agentName]! > mostUsedCount) {
          mostUsedCount = agentUsageCounts[agentName]!;
          mostUsedAgent = agentName;
        }
      }

      return {
        'totalActivities': totalActivities,
        'totalSpent': totalSpent,
        'activityTypeCounts': activityTypeCounts,
        'mostUsedAgent': mostUsedAgent,
        'mostUsedCount': mostUsedCount,
      };
    },
    loading: () => {
      'totalActivities': 0,
      'totalSpent': 0.0,
      'activityTypeCounts': <String, int>{},
      'mostUsedAgent': null,
      'mostUsedCount': 0,
    },
    error: (error, stack) {
      AppLogger.e('[ActivityController] Error computing stats: $error');
      return {
        'totalActivities': 0,
        'totalSpent': 0.0,
        'activityTypeCounts': <String, int>{},
        'mostUsedAgent': null,
        'mostUsedCount': 0,
      };
    },
  );
});
