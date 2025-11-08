import 'package:flutter/material.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/shared/widgets/app_card.dart';

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    this.deltaLabel,
    this.trend = AppStatTrend.neutral,
    this.icon,
    this.accentColor,
  });

  final String title;
  final String value;
  final String? deltaLabel;
  final AppStatTrend trend;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color highlight = accentColor ?? scheme.primary;
    final TextTheme textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.md,
      backgroundColor: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: highlight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(icon, color: highlight, size: 20),
              ),
            ),
          if (icon != null) const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          if (deltaLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _DeltaBadge(
              label: deltaLabel!,
              trend: trend,
            ),
          ],
        ],
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({
    required this.label,
    required this.trend,
  });

  final String label;
  final AppStatTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (Color tint, IconData icon) = switch (trend) {
      AppStatTrend.up => (scheme.tertiary, Icons.arrow_outward_rounded),
      AppStatTrend.down => (scheme.error, Icons.south_east_rounded),
      AppStatTrend.neutral => (
          scheme.onSurfaceVariant.withOpacity(0.6),
          Icons.remove_rounded
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: tint),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: tint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum AppStatTrend { up, down, neutral }
