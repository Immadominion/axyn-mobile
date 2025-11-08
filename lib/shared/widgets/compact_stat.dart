import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact inline stat display (value + label) for the My Agents stats bar.
///
/// Displays a metric in a vertical layout with a large value and small label.
class CompactStat extends StatelessWidget {
  const CompactStat({
    required this.value,
    required this.label,
    required this.scheme,
    required this.theme,
    super.key,
  });

  final String value;
  final String label;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
            fontSize: 28.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}
