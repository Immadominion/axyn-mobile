import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class AppLogger {
  AppLogger._();

  static late bool _canLog;

  static void initialize(AppConfig config) {
    _canLog = config.enableLogging;
  }

  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace);
  }

  static void i(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARN', message, error, stackTrace);
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  static void _log(
    String level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // if (!_canLog) return;
    // // Suppress debug logs in release mode (production builds)
    // if (!kDebugMode && level == 'DEBUG') {
    //   return;
    // }

    developer.log(
      message,
      name: 'AxyN::$level',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
