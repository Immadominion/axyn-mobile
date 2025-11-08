import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';

/// Empty state for activity page when no transactions exist
class ActivityEmptyState extends StatelessWidget {
  const ActivityEmptyState({
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
            PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.light),
            size: 80.sp,
            color: scheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: AppSpacing.lg.h),
          Text(
            'No activity yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'Your transaction history\nwill appear here',
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
