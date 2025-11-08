import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axyn_mobile/application/agents/agent_list_controller.dart';
import 'package:axyn_mobile/domain/entities/agent_listing.dart';

/// Provider for recently used agents
/// Returns agents the user has recently interacted with, based on transaction history
final recentAgentsProvider = FutureProvider<List<AgentListing>>((ref) async {
  // Fetch hired agents which includes usage data
  final hiredAgents = await ref.watch(myHiredAgentsProvider.future);

  // Deduplicate agents by ID (keep first occurrence which is most recent)
  final seenIds = <String>{};
  final uniqueAgents = hiredAgents.where((agent) {
    final id = agent['id'].toString();
    if (seenIds.contains(id)) {
      return false;
    }
    seenIds.add(id);
    return true;
  }).toList();

  // Convert to AgentListing and take top 5 most recent unique agents
  final recentAgents = uniqueAgents.take(5).map((agent) {
    return AgentListing(
      id: agent['id'].toString(),
      name: agent['name'] as String? ?? 'Unknown Agent',
      description: agent['description'] as String? ?? '',
      category: agent['category'] as String? ?? 'General',
      pricePerRequest: (agent['price'] as num?)?.toDouble() ?? 0.0,
      rating: (agent['rating'] as num?)?.toDouble() ?? 0.0,
      totalJobs: agent['usageCount'] as int? ?? 0,
      uptime: 95.0, // Default uptime since we don't have this data
      isOnline: agent['status'] == 'active',
      walletAddress: '', // Not provided in hired agents response
      tags: [],
      apiEndpoint: '', // Not needed for display
      interfaceType: 'chat', // Default interface type
      iconUrl: '', // No icon in hired agents response
    );
  }).toList();

  return recentAgents;
});
