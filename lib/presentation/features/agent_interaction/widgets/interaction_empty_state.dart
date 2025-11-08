import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/domain/entities/agent_listing.dart';

/// Empty state shown when no messages exist yet
class InteractionEmptyState extends StatelessWidget {
  const InteractionEmptyState({
    required this.agent,
    super.key,
  });

  final AgentListing agent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(
              PhosphorIconsFill.robot,
              size: 40.sp,
              color: scheme.primary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Start chatting with ${agent.name}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
            ),
            child: Text(
              'Messages cost ${agent.priceDisplay}. Paid via Privy on send.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
