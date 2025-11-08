import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axyn_mobile/app.dart';
import 'package:axyn_mobile/core/config/app_config.dart';
import 'package:axyn_mobile/core/logging/app_logger.dart';

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.initialize(config);
  AppLogger.d('AxyN Mobile initialized');

  FlutterError.onError = (details) {
    AppLogger.e('Flutter error', details.exception, details.stack);
  };

  final binding = WidgetsBinding.instance;
  binding.platformDispatcher.onError = (Object error, StackTrace stack) {
    AppLogger.e('Uncaught platform error', error, stack);
    return true;
  };

  final observers = <ProviderObserver>[
    if (kDebugMode) const RiverpodLogger(),
  ];

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      observers: observers,
      child: AxyNApp(config: config),
    ),
  );
}

final class RiverpodLogger extends ProviderObserver {
  const RiverpodLogger();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (newValue == previousValue) return;
    final provider = context.provider;
    AppLogger.d('Provider ${provider.name ?? provider.runtimeType} changed');
  }
}
