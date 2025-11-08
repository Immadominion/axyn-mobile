import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/core/services/connectivity_service.dart';
import 'package:axyn_mobile/shared/widgets/app_button.dart';

/// Full-screen overlay shown when device is offline
class NetworkErrorScreen extends ConsumerWidget {
  const NetworkErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 404 Illustration
                Image.asset(
                  'assets/images/404-illustration.png',
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Title
                Text(
                  'Network Error!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  'Connect your network and try again',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Retry Button
                AppButton.primary(
                  label: 'Retry',
                  onPressed: () async {
                    final service = ref.read(connectivityServiceProvider);
                    await service.refresh();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
