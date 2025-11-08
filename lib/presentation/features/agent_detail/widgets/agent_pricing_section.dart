import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/domain/entities/agent_listing.dart';

/// Pricing information section
class AgentPricingSection extends StatelessWidget {
  const AgentPricingSection({
    required this.agent,
    required this.theme,
    required this.scheme,
    super.key,
  });

  final AgentListing agent;
  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price per Request',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                agent.priceDisplay,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 1),
          Text(
            'What you get:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BulletPoint(
            text: _getBenefitText1(agent),
            scheme: scheme,
            theme: theme,
          ),
          _BulletPoint(
            text: _getBenefitText2(agent),
            scheme: scheme,
            theme: theme,
          ),
          _BulletPoint(
            text: 'Verified x402 endpoint',
            scheme: scheme,
            theme: theme,
          ),
        ],
      ),
    );
  }

  String _getBenefitText1(AgentListing agent) {
    // Describe what the agent provides based on category
    switch (agent.category.toLowerCase()) {
      case 'crypto':
        return 'Real-time blockchain data access';
      case 'trading':
        return 'Live market data & order books';
      case 'research':
        return 'On-chain analytics & insights';
      default:
        return '${agent.category} data via x402 API';
    }
  }

  String _getBenefitText2(AgentListing agent) {
    // Describe the response type
    if (agent.interfaceType == 'chat') {
      return 'Conversational interface';
    } else if (agent.interfaceType == 'single-query') {
      return 'Single query response';
    } else {
      return 'Structured data response';
    }
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({
    required this.text,
    required this.scheme,
    required this.theme,
  });

  final String text;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          PhosphorIcon(
            PhosphorIconsDuotone.arrowBendDownRight,
            size: 16.sp,
            color: scheme.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
