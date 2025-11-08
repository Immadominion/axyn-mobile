import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  ConnectivityService() {
    _init();
  }

  final _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Whether the device is currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  void _init() {
    // Check initial status and emit it
    _checkConnectivity().then((_) {
      // Emit initial status to ensure UI gets it immediately
      _controller.add(_currentStatus);
    });

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _updateStatus(results),
      onError: (Object error) {
        AppLogger.e('Connectivity stream error', error);
      },
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      AppLogger.e('Failed to check connectivity', e);
      _updateStatus([ConnectivityResult.none]);
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final newStatus = _determineStatus(results);

    if (newStatus != _currentStatus) {
      final oldStatus = _currentStatus;
      _currentStatus = newStatus;

      AppLogger.d(
        'Connectivity changed: ${oldStatus.name} → ${newStatus.name}',
      );

      _controller.add(newStatus);
    }
  }

  ConnectivityStatus _determineStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return ConnectivityStatus.offline;
    }

    // Treat any known connectivity (including bluetooth/other) as online.
    final hasConnection = results.any((result) {
      switch (result) {
        case ConnectivityResult.mobile:
        case ConnectivityResult.wifi:
        case ConnectivityResult.ethernet:
        case ConnectivityResult.vpn:
        case ConnectivityResult.bluetooth:
        case ConnectivityResult.other:
          return true;
        case ConnectivityResult.none:
          return false;
      }
    });

    return hasConnection
        ? ConnectivityStatus.online
        : ConnectivityStatus.offline;
  }

  /// Manually refresh connectivity status
  /// Forces a re-check and emits current status even if unchanged
  Future<void> refresh() async {
    AppLogger.d('Manual connectivity refresh requested');
    await _checkConnectivity();

    // Force emit current status to update UI even if status hasn't changed
    // This ensures the network error screen can be dismissed if connection is restored
    _controller.add(_currentStatus);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

/// Connectivity status enum
enum ConnectivityStatus {
  unknown,
  online,
  offline;

  bool get isOnline => this == ConnectivityStatus.online;
  bool get isOffline => this == ConnectivityStatus.offline;
}

/// Provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

/// Stream provider for connectivity status
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// Provider for current connectivity status (synchronous)
final currentConnectivityProvider = Provider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  // Also listen to stream to keep this updated
  ref.listen(connectivityStatusProvider, (_, __) {});
  return service.currentStatus;
});
