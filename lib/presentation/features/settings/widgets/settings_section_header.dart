import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Section header for settings groups (e.g., "About")
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 16.w, 8.h),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
