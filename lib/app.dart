import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'package:axyn_mobile/application/app_settings/theme_controller.dart';
import 'package:axyn_mobile/core/config/app_config.dart';
import 'package:axyn_mobile/core/localization/app_localizations.dart';
import 'package:axyn_mobile/core/router/app_router.dart';
import 'package:axyn_mobile/core/services/connectivity_service.dart';
import 'package:axyn_mobile/core/theme/app_theme.dart';
import 'package:axyn_mobile/presentation/features/network_error/view/network_error_screen.dart';

class AxyNApp extends ConsumerStatefulWidget {
  const AxyNApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  ConsumerState<AxyNApp> createState() => _AxyNAppState();
}

class _AxyNAppState extends ConsumerState<AxyNApp> {
  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(appRouterProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      splitScreenMode: true,
      minTextAdapt: true,
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          breakpoints: const [
            Breakpoint(start: 0, end: 450, name: PHONE),
            Breakpoint(start: 451, end: 800, name: TABLET),
            Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
          ],
          child: child!,
        );
      },
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: widget.config.isDebugMode,
        themeMode: themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) {
          // Wrap with connectivity-aware overlay
          return MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.9,
            maxScaleFactor: 1.3,
            child: Stack(
              children: [
                child ?? const SizedBox.shrink(),
                // Show offline screen as overlay when offline
                connectivityStatus.when(
                  data: (status) {
                    if (status == ConnectivityStatus.offline) {
                      return const NetworkErrorScreen();
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
