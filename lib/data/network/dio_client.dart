import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import 'interceptors/auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);

  final options = BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    contentType: 'application/json',
  );

  final dio = Dio(options);
  dio.interceptors.add(AuthInterceptor(ref));

  // TODO: Add network traffic logging if needed
  // if (config.enableDebugLogging) {
  //   dio.interceptors.add(
  //     LogInterceptor(
  //       requestHeader: false,
  //       responseHeader: false,
  //       requestBody: true,
  //       responseBody: true,
  //     ),
  //   );
  // }

  return dio;
});
