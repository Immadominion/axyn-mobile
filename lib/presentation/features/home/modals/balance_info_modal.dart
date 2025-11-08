import 'package:flutter/material.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/presentation/features/home/widgets/battery_indicator.dart';
import 'package:axyn_mobile/shared/widgets/app_modal_sheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Show balance info modal with battery indicator and x402 payment details.
Future<void> showBalanceInfoModal({
  required BuildContext context,
  required double balance,
}) {
  return showAppModalSheet<void>(
    context: context,
    builder: (sheetContext) => _BalanceInfoContent(balance: balance),
  );
}

/// Balance info modal content widget.
class _BalanceInfoContent extends StatelessWidget {
  const _BalanceInfoContent({required this.balance});

  final double balance;

  String _getBalanceStatusText() {
    if (balance >= 10) {
      return 'Power User Status - You\'re all set for extended usage!';
    } else if (balance >= 5) {
      return 'Great! You have plenty of balance for agent interactions.';
    } else if (balance >= 1) {
      return 'Good balance. You can make 100-1000 agent calls.';
    } else if (balance >= 0.10) {
      return 'Low balance. Consider adding funds soon.';
    } else {
      return 'Very low balance. Add funds to continue using agents.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Battery icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BatteryIndicator(
                balance: balance,
                scheme: scheme,
                size: 26.w,
              ),
              const SizedBox(width: AppSpacing.xs),

              // Balance amount
              Text(
                '\$${balance.toStringAsFixed(2)} USDC',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Balance status
          Text(
            _getBalanceStatusText(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Info card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: scheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'About x402 Micro-Payments',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  r'Your battery shows your x402 payment capacity. Most AI agent calls cost 0.001-0.01 USDC per request. Keep your balance above $1 for optimal experience.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Add funds button
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to add funds screen
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Copy Address'),
          ),
        ],
      ),
    );
  }
}
