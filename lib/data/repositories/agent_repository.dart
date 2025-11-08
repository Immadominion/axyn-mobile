import '../datasources/agent_remote_datasource.dart';
import '../../domain/entities/agent_listing.dart';

/// Repository for agent-related operations
/// Follows clean architecture pattern by abstracting data source implementation
class AgentRepository {
  AgentRepository(this._datasource);

  final AgentRemoteDatasource _datasource;

  /// Get all agents with optional filters
  Future<List<AgentListing>> getAllAgents({
    String? category,
    String? search,
    bool? isOnline,
  }) async {
    return _datasource.getAllAgents(
      category: category,
      search: search,
      isOnline: isOnline,
    );
  }

  /// Get a single agent by ID
  Future<AgentListing> getAgentById(String id) async {
    return _datasource.getAgentById(id);
  }

  /// Get agents owned by current user
  Future<List<AgentListing>> getMyAgents() async {
    return _datasource.getMyAgents();
  }
}
