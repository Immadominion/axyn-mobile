import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Clean settings tile matching reference design
/// Simple list item with icon, title, optional value, and chevron
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 16.h,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 24.w,
        ),
        child: Row(
          children: [
            // Icon
            PhosphorIcon(
              icon,
              size: 32.sp,
              color: iconColor ?? scheme.onSurface,
            ),

            SizedBox(width: 16.w),

            // Title
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? scheme.onSurface,
                ),
              ),
            ),

            // Value or trailing widget
            if (value != null)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Text(
                  value!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: scheme.onSurface,
                  ),
                ),
              ),

            if (trailing != null)
              trailing!
            else if (onTap != null)
              PhosphorIcon(
                PhosphorIconsBold.caretRight,
                size: 20.sp,
                color: scheme.onSurface,
              ),
          ],
        ),
      ),
    );
  }
}
