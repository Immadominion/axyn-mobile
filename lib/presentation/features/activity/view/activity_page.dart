import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axyn_mobile/application/activity/activity_controller.dart';
import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/presentation/features/activity/widgets/activity_card.dart';
import 'package:axyn_mobile/presentation/features/activity/widgets/activity_detail_modal.dart';
import 'package:axyn_mobile/presentation/features/activity/widgets/activity_empty_state.dart';
import 'package:axyn_mobile/shared/widgets/app_modal_sheet.dart';

/// ACTIVITY tab - Transaction history and agent interactions.
///
/// Features:
/// - Real-time activity history from backend
/// - User prompts and agent responses
/// - Activity type icons (chat, query, upload, analysis)
/// - Tap to see full details
/// - Solana transaction links
class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Watch activity history provider
    final activitiesAsync = ref.watch(activityHistoryProvider);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg.w,
                AppSpacing.lg.h,
                AppSpacing.lg.w,
                AppSpacing.sm.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                      color: scheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    'Your transaction history',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md.h)),

          // Activity List - Handle AsyncValue states
          activitiesAsync.when(
            data: (activities) {
              if (activities.isEmpty) {
                return SliverFillRemaining(
                  child: ActivityEmptyState(scheme: scheme, theme: theme),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final activity = activities[index] as Map<String, dynamic>;
                    return ActivityCard(
                      activity: activity,
                      scheme: scheme,
                      theme: theme,
                      onTap: () {
                        _showActivityDetail(context, ref, activity);
                      },
                    );
                  },
                  childCount: activities.length,
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: scheme.primary,
                ),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: scheme.error,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Text(
                        'Failed to load activities',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom spacing for nav bar
          SliverToBoxAdapter(child: SizedBox(height: 96.h)),
        ],
      ),
    );
  }

  void _showActivityDetail(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> activity,
  ) {
    showAppModalSheet<void>(
      context: context,
      builder: (context) => ActivityDetailModal(activity: activity),
    );
  }
}
