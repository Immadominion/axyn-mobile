import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';

/// Activity card matching NFT marketplace style
/// Shows agent interaction with thumbnail, type, and pricing
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.activity,
    required this.scheme,
    required this.theme,
    required this.onTap,
    super.key,
  });

  final Map<String, dynamic> activity;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback onTap;

  String _getActivityTypeLabel(String type) {
    switch (type) {
      case 'chat':
        return 'Chat';
      case 'query':
        return 'Query';
      case 'upload':
        return 'Upload';
      case 'analysis':
        return 'Analysis';
      case 'agent_hire':
        return 'Hired';
      case 'agent_query':
        return 'Query';
      case 'agent_payment':
        return 'Payment';
      default:
        return 'Activity';
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'chat':
        return PhosphorIcons.chatCircle(PhosphorIconsStyle.fill);
      case 'query':
        return PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.fill);
      case 'upload':
        return PhosphorIcons.uploadSimple(PhosphorIconsStyle.fill);
      case 'analysis':
        return PhosphorIcons.chartLine(PhosphorIconsStyle.fill);
      case 'agent_hire':
        return PhosphorIcons.userPlus(PhosphorIconsStyle.fill);
      default:
        return PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Support both old mock data structure and new backend structure
    final type = activity['activityType'] as String? ??
        activity['type'] as String? ??
        'query';
    final agentName = activity['agentName'] as String? ?? 'Unknown Agent';
    final amount = (activity['amount'] as num?)?.toDouble() ?? 0.0;

    // Parse timestamp - handle both DateTime objects and ISO strings
    final timestampRaw = activity['timestamp'];
    final timestamp = timestampRaw is DateTime
        ? timestampRaw
        : DateTime.tryParse(timestampRaw.toString()) ?? DateTime.now();

    // Get user prompt preview if available
    final userPrompt = activity['userPrompt'] as String?;
    final hasPrompt = userPrompt != null && userPrompt.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.md.h,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: scheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Activity icon based on type
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primaryContainer,
                    scheme.primaryContainer.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _getActivityIcon(type),
                size: 28.sp,
                color: scheme.primary,
              ),
            ),

            SizedBox(width: AppSpacing.md.w),

            // Agent info and activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Activity type label
                  Text(
                    _getActivityTypeLabel(type),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Agent name
                  Text(
                    agentName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      color: scheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasPrompt) ...[
                    SizedBox(height: 4.h),
                    // User prompt preview
                    Text(
                      userPrompt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: AppSpacing.sm.w),

            // Right side: Activity type, amount, timestamp
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Activity type label
                Text(
                  _getActivityTypeLabel(type),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                // Amount with crypto icon
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.currencyCircleDollar(
                        PhosphorIconsStyle.fill,
                      ),
                      size: 16.sp,
                      color: scheme.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      amount.toStringAsFixed(2),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Timestamp
                Text(
                  _formatTimestamp(timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12.sp,
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
