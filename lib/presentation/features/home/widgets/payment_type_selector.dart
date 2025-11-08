import 'package:flutter/material.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/presentation/features/home/providers/payment_flow_providers.dart';

/// Horizontal pill selector for payment types (Crypto, Cash, Card).
class PaymentTypeSelector extends StatelessWidget {
  const PaymentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final PaymentType selectedType;
  final ValueChanged<PaymentType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PaymentTypePill(
            label: 'Crypto',
            isSelected: selectedType == PaymentType.crypto,
            onTap: () => onTypeChanged(PaymentType.crypto),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _PaymentTypePill(
            label: 'Cash',
            isSelected: selectedType == PaymentType.cash,
            onTap: () => onTypeChanged(PaymentType.cash),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _PaymentTypePill(
            label: 'Card',
            isSelected: selectedType == PaymentType.card,
            onTap: () => onTypeChanged(PaymentType.card),
          ),
        ),
      ],
    );
  }
}

/// Individual pill button for payment type.
class _PaymentTypePill extends StatelessWidget {
  const _PaymentTypePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
