import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/application/account/user_profile_provider.dart';
import 'package:axyn_mobile/application/auth/session_controller.dart';
import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/core/router/routes.dart';
import 'package:axyn_mobile/core/services/privy_auth_service.dart';
import 'package:axyn_mobile/shared/widgets/app_background.dart';
import 'package:axyn_mobile/shared/widgets/app_noise_overlay.dart';
import 'package:axyn_mobile/presentation/features/authentication/view/email_login_flow.dart';
import 'package:axyn_mobile/presentation/features/main_app/controller/main_tab_index_controller.dart';

/// Authentication screen with Privy multi-provider sign-in
class AuthenticationPage extends ConsumerStatefulWidget {
  const AuthenticationPage({super.key, this.initialErrorMessage});

  final String? initialErrorMessage;

  @override
  ConsumerState<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends ConsumerState<AuthenticationPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final message = widget.initialErrorMessage;
      if (message != null && message.isNotEmpty) {
        _showError(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SessionState>>(sessionControllerProvider,
        (previous, next) {
      next.whenData((sessionState) {
        if (!sessionState.isAuthenticated &&
            sessionState.errorMessage != null &&
            sessionState.errorMessage!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showError(sessionState.errorMessage!);
          });
        }
      });
    });

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(child: SizedBox.expand()),
          const AppNoiseOverlay(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  SizedBox(height: AppSpacing.xxl.h * 2),
                  Image.asset(
                    'assets/images/icons/axyn-large.png',
                    width: 200.w,
                    height: 200.h,
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    'AI Exchange Network',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    'Sign in to get started',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl.h),
                  _GoogleButton(
                    onPressed: () => _handleLogin(LoginMethod.google),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: scheme.onBackground.withOpacity(0.2),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
                        child: Text(
                          'or',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onBackground.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: scheme.onBackground.withOpacity(0.2),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _IconLoginButton(
                        icon: PhosphorIconsFill.xLogo,
                        backgroundColor: const Color(0xFF000000),
                        onPressed: () => _handleLogin(LoginMethod.twitter),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      _IconLoginButton(
                        icon: PhosphorIconsFill.discordLogo,
                        backgroundColor: const Color(0xFF5865F2),
                        onPressed: () => _handleLogin(LoginMethod.discord),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      _IconLoginButton(
                        icon: PhosphorIconsFill.envelope,
                        backgroundColor: scheme.inversePrimary,
                        onPressed: () => _handleLogin(LoginMethod.email),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.md,
                    children: [
                      TextButton(
                        onPressed: () {
                          //TODO: Implement privacy policy website navigation
                        },
                        child: Text(
                          'Privacy Policy',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ),
                      Text(
                        '•',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          //TODO: Implement terms of service website navigation
                        },
                        child: Text(
                          'Terms of Service',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin(LoginMethod method) async {
    if (method == LoginMethod.email) {
      await _handleEmailLogin();
      return;
    }

    final authService = ref.read(privyAuthServiceProvider);
    final result = await authService.authenticate(method);

    if (!mounted) return;

    if (result.success) {
      final sessionNotifier = ref.read(sessionControllerProvider.notifier);
      final persisted = await sessionNotifier.onLoginSuccess(method);

      if (!mounted) return;

      if (persisted) {
        // Invalidate user profile to force fresh data fetch
        ref.invalidate(userProfileProvider);
        ref.invalidate(mainTabIndexProvider);

        context.go(AppRoutePaths.dashboard);
      } else {
        final sessionState =
            ref.read(sessionControllerProvider).maybeWhen<SessionState?>(
                  data: (value) => value,
                  orElse: () => null,
                );
        final error = sessionState?.errorMessage ??
            result.error ??
            'Authentication failed';
        _showError(error);
      }
    } else {
      _showError(result.error ?? 'Authentication failed');
    }
  }

  Future<void> _handleEmailLogin() async {
    final authService = ref.read(privyAuthServiceProvider);
    final success = await showEmailLoginFlow(
      context: context,
      authService: authService,
    );

    if (!mounted || success != true) {
      return;
    }

    final sessionNotifier = ref.read(sessionControllerProvider.notifier);
    final persisted = await sessionNotifier.onLoginSuccess(LoginMethod.email);

    if (!mounted) return;

    if (persisted) {
      // Invalidate user profile to force fresh data fetch
      ref.invalidate(userProfileProvider);
      ref.invalidate(mainTabIndexProvider);

      context.go(AppRoutePaths.dashboard);
    } else {
      final sessionState =
          ref.read(sessionControllerProvider).maybeWhen<SessionState?>(
                data: (value) => value,
                orElse: () => null,
              );
      final error = sessionState?.errorMessage ??
          'We couldn\'t verify your email session. Please try again.';
      _showError(error);
    }
  }

  void _showError(String? message) {
    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(PhosphorIconsRegular.googleLogo,
                size: 24.sp, color: Colors.black87),
            SizedBox(width: AppSpacing.md.w),
            Text(
              'Continue with Google',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconLoginButton extends StatelessWidget {
  const _IconLoginButton({
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });
  final PhosphorIconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.w,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
        child: PhosphorIcon(icon, size: 24.sp, color: Colors.white),
      ),
    );
  }
}
