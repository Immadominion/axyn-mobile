import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/presentation/features/agents/widgets/stat_pill.dart';

/// Hired agent card showing usage stats and quick access.
///
/// Displays agent information including icon, name, rating, category,
/// description, usage count, last used time, and total spent.
class HiredAgentCard extends StatelessWidget {
  const HiredAgentCard({
    required this.agent,
    required this.scheme,
    required this.theme,
    required this.onTap,
    super.key,
  });

  final Map<String, dynamic> agent;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback onTap;

  String _formatLastUsed(DateTime lastUsed) {
    final now = DateTime.now();
    final difference = now.difference(lastUsed);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0.00';

    final double amount = value is double
        ? value
        : value is int
            ? value.toDouble()
            : double.tryParse(value.toString()) ?? 0.0;

    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Agent icon
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: scheme.primary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                // Agent info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent['name'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          fontSize: 16.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14.sp,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            agent['rating'].toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              agent['category'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            // Description
            Text(
              agent['description'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.md.h),
            // Stats row
            Row(
              children: [
                StatPill(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${agent['usageCount']} queries',
                  scheme: scheme,
                  theme: theme,
                ),
                SizedBox(width: AppSpacing.sm.w),
                StatPill(
                  icon: Icons.schedule_rounded,
                  label: _formatLastUsed(
                    agent['lastUsed'] != null
                        ? DateTime.parse(agent['lastUsed'] as String)
                        : DateTime.now(),
                  ),
                  scheme: scheme,
                  theme: theme,
                ),
                const Spacer(),
                Text(
                  '\$${_formatCurrency(agent['totalSpent'])}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
