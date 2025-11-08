import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/entities/agent_listing.dart';
import '../../domain/models/create_agent_request.dart';

/// Remote datasource for agent-related API calls
class AgentRemoteDatasource {
  AgentRemoteDatasource(this._dio);

  final Dio _dio;

  /// Get all agents with optional filters
  Future<List<AgentListing>> getAllAgents({
    String? category,
    String? search,
    bool? isOnline,
  }) async {
    try {
      AppLogger.d('[AgentRemoteDatasource] Fetching all agents');
      AppLogger.d(
          '  Filters: category=$category, search=$search, isOnline=$isOnline');

      final Map<String, dynamic> queryParams = {};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (isOnline != null) {
        queryParams['isOnline'] = isOnline.toString();
      }

      final response = await _dio.get<List<dynamic>>(
        '/agent',
        queryParameters: queryParams,
      );

      AppLogger.d(
          '[AgentRemoteDatasource] Response status: ${response.statusCode}');
      AppLogger.d(
          '[AgentRemoteDatasource] Response data type: ${response.data.runtimeType}');

      if (response.data is! List) {
        AppLogger.e(
            '[AgentRemoteDatasource] Expected List but got: ${response.data.runtimeType}');
        return [];
      }

      final List<dynamic> data = response.data as List<dynamic>;
      AppLogger.d('[AgentRemoteDatasource] Found ${data.length} agents');

      final agents = data
          .map((json) {
            try {
              return AgentListing.fromJson(json as Map<String, dynamic>);
            } catch (e, stack) {
              AppLogger.e('[AgentRemoteDatasource] Error parsing agent: $e');
              AppLogger.e('[AgentRemoteDatasource] Stack trace: $stack');
              AppLogger.e('[AgentRemoteDatasource] JSON: $json');
              return null;
            }
          })
          .whereType<AgentListing>()
          .toList();

      AppLogger.d(
          '[AgentRemoteDatasource] Successfully parsed ${agents.length} agents');
      return agents;
    } catch (e, stack) {
      AppLogger.e('[AgentRemoteDatasource] Error fetching agents: $e');
      AppLogger.e('[AgentRemoteDatasource] Stack trace: $stack');
      rethrow;
    }
  }

  /// Get a single agent by ID
  Future<AgentListing> getAgentById(String id) async {
    try {
      AppLogger.d('[AgentRemoteDatasource] Fetching agent by ID: $id');

      final response = await _dio.get<Map<String, dynamic>>('/agent/$id');

      AppLogger.d(
          '[AgentRemoteDatasource] Response status: ${response.statusCode}');

      final agent = AgentListing.fromJson(
        response.data as Map<String, dynamic>,
      );

      AppLogger.d(
          '[AgentRemoteDatasource] Successfully fetched agent: ${agent.name}');
      return agent;
    } catch (e, stack) {
      AppLogger.e('[AgentRemoteDatasource] Error fetching agent $id: $e');
      AppLogger.e('[AgentRemoteDatasource] Stack trace: $stack');
      rethrow;
    }
  }

  /// Get agents owned by current user (requires authentication)
  Future<List<AgentListing>> getMyAgents() async {
    try {
      AppLogger.d('[AgentRemoteDatasource] Fetching my agents');

      final response = await _dio.get<List<dynamic>>('/agent/my-agents');

      AppLogger.d(
          '[AgentRemoteDatasource] Response status: ${response.statusCode}');

      if (response.data is! List) {
        AppLogger.e(
            '[AgentRemoteDatasource] Expected List but got: ${response.data.runtimeType}');
        return [];
      }

      final List<dynamic> data = response.data as List<dynamic>;
      AppLogger.d('[AgentRemoteDatasource] Found ${data.length} of my agents');

      final agents = data
          .map((json) {
            try {
              return AgentListing.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              AppLogger.e('[AgentRemoteDatasource] Error parsing agent: $e');
              return null;
            }
          })
          .whereType<AgentListing>()
          .toList();

      return agents;
    } catch (e, stack) {
      AppLogger.e('[AgentRemoteDatasource] Error fetching my agents: $e');
      AppLogger.e('[AgentRemoteDatasource] Stack trace: $stack');
      rethrow;
    }
  }

  /// Upload agent icon (multipart/form-data)
  Future<String> uploadIcon(File iconFile) async {
    try {
      AppLogger.d('[AgentRemoteDatasource] Uploading icon: ${iconFile.path}');

      final fileName = iconFile.path.split('/').last;
      final formData = FormData.fromMap({
        'icon': await MultipartFile.fromFile(
          iconFile.path,
          filename: fileName,
          contentType: MediaType('image', fileName.split('.').last),
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/agent/upload-icon',
        data: formData,
      );

      if (response.data == null) {
        throw Exception('No response data from icon upload');
      }

      final iconUrl = response.data!['iconUrl'] as String?;
      if (iconUrl == null) {
        throw Exception('No iconUrl in response');
      }

      AppLogger.d('[AgentRemoteDatasource] Icon uploaded: $iconUrl');
      return iconUrl;
    } catch (e, stack) {
      AppLogger.e('[AgentRemoteDatasource] Error uploading icon: $e');
      AppLogger.e('[AgentRemoteDatasource] Stack trace: $stack');
      rethrow;
    }
  }

  /// Create new agent
  Future<AgentListing> createAgent(CreateAgentRequest request) async {
    try {
      AppLogger.d('[AgentRemoteDatasource] Creating agent: ${request.name}');
      AppLogger.d('[AgentRemoteDatasource] Request data: ${request.toJson()}');

      final response = await _dio.post<Map<String, dynamic>>(
        '/agent',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw Exception('No response data from agent creation');
      }

      final agent = AgentListing.fromJson(response.data!);
      AppLogger.d('[AgentRemoteDatasource] Agent created: ${agent.id}');
      return agent;
    } catch (e, stack) {
      AppLogger.e('[AgentRemoteDatasource] Error creating agent: $e');
      AppLogger.e('[AgentRemoteDatasource] Stack trace: $stack');
      rethrow;
    }
  }
}
