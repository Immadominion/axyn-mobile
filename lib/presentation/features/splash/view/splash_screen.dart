import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:axyn_mobile/application/app_launch/app_launch_decision.dart';
import 'package:axyn_mobile/core/router/routes.dart';
import 'package:axyn_mobile/shared/widgets/app_background.dart';
import 'package:axyn_mobile/shared/widgets/app_noise_overlay.dart';

/// Splash screen that checks onboarding status and redirects.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;
  late final Future<void> _minimumDisplayFuture;

  @override
  void initState() {
    super.initState();
    // Minimum 2 seconds to show branding, but could take longer for merchant check
    _minimumDisplayFuture = Future<void>.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<LaunchDecision>>(appLaunchDecisionProvider,
        (previous, next) {
      next.whenData((decision) {
        if (!mounted || _hasNavigated) return;
        _hasNavigated = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final extra = decision.route == AppRoutePaths.authentication
              ? decision.errorMessage
              : null;
          _navigateAfterMinimum(decision.route, extra: extra);
        });
      });
    });

    final launchDecision = ref.watch(appLaunchDecisionProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(child: SizedBox.expand()),
          const AppNoiseOverlay(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                launchDecision.when(
                  data: (_) => _buildAnimatedTitle(context),
                  loading: () => _buildAnimatedTitle(context),
                  error: (error, stackTrace) {
                    if (!_hasNavigated) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted || _hasNavigated) return;
                        _hasNavigated = true;
                        _navigateAfterMinimum(
                          AppRoutePaths.authentication,
                          extra:
                              'We could not check your session. Please sign in again.',
                        );
                      });
                    }
                    return _buildAnimatedTitle(context);
                  },
                ),
                const SizedBox(height: 32),
                // Loading indicator
                launchDecision.when(
                  data: (_) => const SizedBox.shrink(),
                  loading: () => SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTitle(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayMedium?.copyWith(
          color: theme.colorScheme.onBackground,
          fontWeight: FontWeight.w800,
        ) ??
        const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        );

    return DefaultTextStyle(
      style: textStyle,
      child: AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(
            'AxyN',
            textAlign: TextAlign.center,
            speed: const Duration(milliseconds: 120),
          ),
        ],
        pause: Duration.zero,
        totalRepeatCount: 1,
        isRepeatingAnimation: false,
        displayFullTextOnTap: true,
      ),
    );
  }

  Future<void> _navigateAfterMinimum(String route, {String? extra}) async {
    await _minimumDisplayFuture;
    if (!mounted) return;
    context.go(route, extra: extra);
  }
}
