import 'package:flutter/material.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<T?> showAppModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool enableDrag = true,
  double maxWidth = 520,
  Color? barrierColor,
}) {
  final overlayColor = barrierColor ?? Colors.black.withValues(alpha: 0.35);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    enableDrag: enableDrag,
    barrierColor: overlayColor,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final mediaQuery = MediaQuery.of(sheetContext);
      final viewInsets = mediaQuery.viewInsets;
      // final bottomPadding = mediaQuery.padding.bottom;
      final theme = Theme.of(sheetContext);

      return AnimatedPadding(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md.w,
              AppSpacing.md.h,
              AppSpacing.md.w,
              0,
              // AppSpacing.lg + bottomPadding,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      builder(sheetContext),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
