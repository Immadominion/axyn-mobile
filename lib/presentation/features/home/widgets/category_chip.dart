import 'package:flutter/material.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';

/// Category filter chip widget for the marketplace.
///
/// Used to filter agents by category (e.g., Trading, DeFi, NFTs, etc.).
class CategoryChip extends StatelessWidget {
  const CategoryChip(
    this.label, {
    this.isSelected = false,
    required this.scheme,
    this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final ColorScheme scheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.secondary.withValues(alpha: 0.2)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20), // More rounded
        border: Border.all(
          color: isSelected
              ? scheme.secondary
              : scheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? scheme.secondary : scheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
