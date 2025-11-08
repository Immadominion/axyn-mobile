import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small stat pill for displaying agent usage metrics with icon.
///
/// Used in agent cards to show compact stats like query count and last used time.
class StatPill extends StatelessWidget {
  const StatPill({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.theme,
    super.key,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
