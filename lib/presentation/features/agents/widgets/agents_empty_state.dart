import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';

/// Empty state widget shown when no agents are hired.
///
/// Displays a placeholder icon and message encouraging users to discover agents.
class AgentsEmptyState extends StatelessWidget {
  const AgentsEmptyState({
    required this.scheme,
    required this.theme,
    super.key,
  });

  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 80.sp,
            color: scheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: AppSpacing.lg.h),
          Text(
            'No agents hired yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'Discover and hire AI agents\nfrom the marketplace',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
