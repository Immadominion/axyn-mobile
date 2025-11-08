import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/entities/agent_listing.dart';

/// Agent card widget for marketplace grid.
///
/// Displays agent information including avatar, name, description, price, and rating.
class AgentCard extends StatelessWidget {
  const AgentCard({
    required this.agent,
    this.onTap,
    super.key,
  });

  final AgentListing agent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent avatar with online status
            Stack(
              children: [
                Container(
                  height: 107.h,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: agent.iconUrl.isEmpty
                        ? Icon(
                            Icons.smart_toy_rounded,
                            size: 48.sp,
                            color: scheme.primary,
                          )
                        : Image.network(
                            agent.iconUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.smart_toy_rounded,
                              size: 48.sp,
                              color: scheme.primary,
                            ),
                          ),
                  ),
                ),
                // Online/offline indicator
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: agent.isOnline
                          ? Colors.green.withValues(alpha: 0.9)
                          : Colors.grey.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          agent.isOnline ? 'Online' : 'Offline',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Agent name
                  Text(
                    agent.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  // Description
                  Text(
                    agent.shortDescription ?? agent.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  // Price and rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Container(
                        padding: EdgeInsets.only(left: 2.w, right: 1.w),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.1),
                          border: Border(
                            left: BorderSide(color: scheme.primary),
                          ),
                        ),
                        child: Text(
                          agent.priceDisplay,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Jobs count
                      Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIconsRegular.briefcase,
                            size: 12.sp,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${agent.jobsDisplay} jobs',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(
                            PhosphorIconsFill.star,
                            size: 14.sp,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            agent.ratingDisplay,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
