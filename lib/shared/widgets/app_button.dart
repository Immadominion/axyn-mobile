import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : variant = _AppButtonVariant.secondary;

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final _AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final ButtonStyle style;
    switch (variant) {
      case _AppButtonVariant.primary:
        style = FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 16.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        );
        break;
      case _AppButtonVariant.secondary:
        style = OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withOpacity(0.2), width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
        break;
    }

    final Widget buttonChild = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: variant == _AppButtonVariant.primary
                  ? scheme.onPrimary
                  : scheme.primary,
            ),
          ),
        ),
      ],
    );

    final Widget button;
    switch (variant) {
      case _AppButtonVariant.primary:
        button = FilledButton(
          onPressed: onPressed,
          style: style,
          child: buttonChild,
        );
        break;
      case _AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: onPressed,
          style: style,
          child: buttonChild,
        );
        break;
    }

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

enum _AppButtonVariant { primary, secondary }
