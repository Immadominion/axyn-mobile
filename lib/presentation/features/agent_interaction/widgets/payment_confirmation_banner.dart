import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';

/// Payment confirmation banner shown after sending a message
class PaymentConfirmationBanner extends StatelessWidget {
  const PaymentConfirmationBanner({
    required this.amount,
    required this.scheme,
    required this.theme,
    super.key,
  });

  final double amount;
  final ColorScheme scheme;
  final ThemeData theme;

  /// Format amount to show appropriate decimal places
  /// - Less than $0.01: show 4 decimals
  /// - Otherwise: show 2 decimals
  String _formatAmount(double value) {
    if (value < 0.01) {
      return value.toStringAsFixed(4);
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: scheme.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIconsBold.checkCircle,
                size: 14.sp,
                color: scheme.secondary,
              ),
              SizedBox(width: 6.w),
              Text(
                'Paid \$${_formatAmount(amount)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
