import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/presentation/features/home/providers/payment_flow_providers.dart';

/// Token selector for USDC and USDT (shown when Crypto payment type is selected).
class TokenSelector extends StatelessWidget {
  const TokenSelector({
    super.key,
    required this.selectedToken,
    required this.onTokenChanged,
  });

  final TokenType selectedToken;
  final ValueChanged<TokenType> onTokenChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TokenCard(
            label: 'USDC',
            icon: PhosphorIconsRegular.currencyCircleDollar,
            balance: '1,234.56', // TODO: Get real balance
            isSelected: selectedToken == TokenType.usdc,
            onTap: () => onTokenChanged(TokenType.usdc),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TokenCard(
            label: 'USDT',
            icon: PhosphorIconsRegular.currencyCircleDollar,
            balance: '567.89', // TODO: Get real balance
            isSelected: selectedToken == TokenType.usdt,
            onTap: () => onTokenChanged(TokenType.usdt),
          ),
        ),
      ],
    );
  }
}

/// Individual token card.
class _TokenCard extends StatelessWidget {
  const _TokenCard({
    required this.label,
    required this.icon,
    required this.balance,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final PhosphorIconData icon;
  final String balance;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              balance,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? scheme.onPrimaryContainer.withValues(alpha: 0.7)
                    : scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
