import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axyn_mobile/application/auth/session_controller.dart';
import 'package:axyn_mobile/core/router/routes.dart';
import 'package:axyn_mobile/core/services/onboarding_service.dart';
import 'package:axyn_mobile/core/services/session_persistence_service.dart';

class LaunchDecision {
  const LaunchDecision({
    required this.route,
    required this.isAuthenticated,
    this.sessionSnapshot,
    this.errorMessage,
  });

  final String route;
  final bool isAuthenticated;
  final SessionSnapshot? sessionSnapshot;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
}

final appLaunchDecisionProvider = FutureProvider<LaunchDecision>((ref) async {
  final onboardingCompleted =
      await ref.watch(hasCompletedOnboardingProvider.future);

  if (!onboardingCompleted) {
    return const LaunchDecision(
      route: AppRoutePaths.onboarding,
      isAuthenticated: false,
    );
  }

  final sessionState = await ref.watch(sessionControllerProvider.future);

  if (sessionState.isAuthenticated) {
    return LaunchDecision(
      route: AppRoutePaths.dashboard,
      isAuthenticated: true,
      sessionSnapshot: sessionState.snapshot,
    );
  }

  return LaunchDecision(
    route: AppRoutePaths.authentication,
    isAuthenticated: false,
    errorMessage: sessionState.errorMessage,
  );
});
