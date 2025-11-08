import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/x402_service.dart';
import '../../data/datasources/agent_proxy_datasource.dart';
import '../../data/network/dio_client.dart';

/// Provider for X402Service
final x402ServiceProvider = Provider<X402Service>((ref) {
  return X402Service();
});

/// Provider for AgentProxyDatasource
final agentProxyDatasourceProvider = Provider<AgentProxyDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  final x402Service = ref.watch(x402ServiceProvider);
  return AgentProxyDatasource(dio, x402Service);
});
