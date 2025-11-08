import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:axyn_mobile/core/logging/app_logger.dart';
import 'package:axyn_mobile/core/router/routes.dart';
import 'package:axyn_mobile/core/services/privy_auth_service.dart';
import 'package:axyn_mobile/domain/entities/agent_listing.dart';
import 'package:axyn_mobile/presentation/features/agent_detail/view/agent_detail_page.dart';
import 'package:axyn_mobile/presentation/features/agent_interaction/view/agent_interaction_page.dart';
import 'package:axyn_mobile/presentation/features/agents/view/create_agent_page.dart';
import 'package:axyn_mobile/presentation/features/authentication/view/authentication_page.dart';
import 'package:axyn_mobile/presentation/features/main_app/view/main_scaffold.dart';
import 'package:axyn_mobile/presentation/features/onboarding/view/onboarding_carousel.dart';
import 'package:axyn_mobile/presentation/features/settings/view/edit_profile_page.dart';
import 'package:axyn_mobile/presentation/features/splash/view/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutePaths.splash,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) async {
      final isOnSplash = state.matchedLocation == AppRoutePaths.splash;
      final isOnOnboarding = state.matchedLocation == AppRoutePaths.onboarding;
      final isOnAuth = state.matchedLocation == AppRoutePaths.authentication;

      // Allow splash and onboarding
      if (isOnSplash || isOnOnboarding) {
        return null;
      }

      // Check auth status asynchronously
      final authService = ref.read(privyAuthServiceProvider);
      final isAuthenticated = await authService.isAuthenticated();

      // Not authenticated → force auth
      if (!isAuthenticated && !isOnAuth) {
        AppLogger.d('Redirecting to auth (not authenticated)');
        return AppRoutePaths.authentication;
      }

      // Authenticated but on auth page → go to dashboard
      if (isAuthenticated && isOnAuth) {
        AppLogger.d('Redirecting to dashboard from auth');
        return AppRoutePaths.dashboard;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutePaths.splash,
        name: 'splash',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: OnboardingCarousel(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.authentication,
        name: 'authentication',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          child: AuthenticationPage(
            initialErrorMessage:
                state.extra is String ? state.extra as String : null,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: MainScaffold(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.agentDetail,
        name: 'agentDetail',
        builder: (context, state) {
          final agent = state.extra as AgentListing;
          return AgentDetailPage(agent: agent);
        },
      ),
      GoRoute(
        path: AppRoutePaths.agentInteraction,
        name: 'agentInteraction',
        builder: (context, state) {
          final agent = state.extra as AgentListing;
          return AgentInteractionPage(agent: agent);
        },
      ),
      GoRoute(
        path: AppRoutePaths.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutePaths.createAgent,
        name: 'createAgent',
        builder: (context, state) => const CreateAgentPage(),
      ),
    ],
  );
});
