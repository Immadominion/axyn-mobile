import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/core/router/routes.dart';
import 'package:axyn_mobile/domain/entities/agent_listing.dart';
import 'package:axyn_mobile/presentation/features/agent_detail/modals/agent_share_modal.dart';
import 'package:axyn_mobile/presentation/features/agent_detail/widgets/agent_banner_section.dart';
import 'package:axyn_mobile/presentation/features/agent_detail/widgets/agent_example_section.dart';
import 'package:axyn_mobile/presentation/features/agent_detail/widgets/agent_hire_button.dart';
import 'package:axyn_mobile/presentation/features/agent_detail/widgets/agent_pricing_section.dart';
import 'package:axyn_mobile/shared/widgets/compact_stat.dart';

/// Agent Detail Page - Shows full information about an agent
///
/// Layout inspired by NFT marketplace with:
/// - Banner + avatar
/// - Agent name, description, verification badge
/// - Stats row (jobs, rating, uptime)
/// - Tags
/// - Example section
/// - Primary CTA: "Hire Agent" button
class AgentDetailPage extends ConsumerWidget {
  const AgentDetailPage({
    required this.agent,
    super.key,
  });

  final AgentListing agent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App bar with back button
              SliverAppBar(
                pinned: true,
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                backgroundColor: scheme.surface,
                leading: IconButton(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.arrowLeft,
                    color: scheme.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: PhosphorIcon(
                      PhosphorIconsRegular.paperPlaneTilt,
                      color: scheme.onSurface,
                    ),
                    onPressed: () {
                      showAgentShareModal(
                        context: context,
                        agent: agent,
                      );
                    },
                  ),
                  IconButton(
                    icon: PhosphorIcon(
                      PhosphorIconsRegular.dotsThreeCircle,
                      color: scheme.onSurface,
                    ),
                    onPressed: () {
                      // TODO: Show options menu (report, block, etc.)
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner + Avatar Section
                    AgentBannerSection(agent: agent, scheme: scheme),

                    // Agent Name & Verification
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                agent.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              // Verification badge
                              PhosphorIcon(
                                PhosphorIconsFill.sealCheck,
                                color: scheme.primary,
                                size: 18.sp,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Description
                          Text(
                            agent.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Tags
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: agent.tags.map((tag) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(7.r),
                                ),
                                child: Text(
                                  tag,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          Divider(color: scheme.outline.withValues(alpha: 0.2)),
                          const SizedBox(height: AppSpacing.sm),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CompactStat(
                                value: agent.jobsDisplay,
                                label: 'Jobs',
                                scheme: scheme,
                                theme: theme,
                              ),
                              Container(
                                width: 1.w,
                                height: 24.h,
                                color: scheme.outline.withValues(alpha: 0.2),
                              ),
                              CompactStat(
                                value: agent.ratingDisplay,
                                label: 'Rating',
                                scheme: scheme,
                                theme: theme,
                              ),
                              Container(
                                width: 1.w,
                                height: 24.h,
                                color: scheme.outline.withValues(alpha: 0.2),
                              ),
                              CompactStat(
                                value: agent.uptimeDisplay,
                                label: 'Uptime',
                                scheme: scheme,
                                theme: theme,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Pricing Section
                          AgentPricingSection(
                            agent: agent,
                            theme: theme,
                            scheme: scheme,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Example Section
                          AgentExampleSection(
                            agent: agent,
                            theme: theme,
                            scheme: scheme,
                          ),

                          SizedBox(height: 100.h), // Space for bottom button
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0.h,
            left: 0,
            right: 0,
            child: AgentHireButton(
              agent: agent,
              scheme: scheme,
              theme: theme,
              onTap: () {
                // Navigate to interaction page
                context.push(
                  AppRoutePaths.agentInteraction,
                  extra: agent,
                );
              },
            ),
          ),
        ],
      ),

      // Fixed bottom CTA
      // bottomNavigationBar:
      //     AgentHireButton(agent: agent, scheme: scheme, theme: theme),
    );
  }
}
