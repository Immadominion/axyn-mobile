import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/application/agents/agent_list_controller.dart';
import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/core/router/routes.dart';
import 'package:axyn_mobile/presentation/features/agents/widgets/agents_empty_state.dart';
import 'package:axyn_mobile/shared/widgets/compact_stat.dart';
import 'package:axyn_mobile/presentation/features/agents/widgets/hired_agent_card.dart';

/// MY AGENTS tab - View and manage hired AI agents.
///
/// Features:
/// - Stats overview (total agents, total spent, queries today)
/// - List of hired agents with usage stats
/// - Quick access to interact with agents again
/// - Filter by recently used, most used, etc.
class FundsPage extends ConsumerStatefulWidget {
  const FundsPage({super.key});

  @override
  ConsumerState<FundsPage> createState() => _FundsPageState();
}

class _FundsPageState extends ConsumerState<FundsPage>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _startCollapseAnimation();
  }

  void _startCollapseAnimation() {
    setState(() => _isExpanded = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isExpanded = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Watch stats provider for real data
    final statsAsync = ref.watch(myAgentStatsProvider);
    final hiredAgentsAsync = ref.watch(myHiredAgentsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: statsAsync.when(
          data: (stats) {
            final totalAgents = stats['totalAgents'] as int;
            final totalSpent = stats['totalSpent'] as double;
            final queriesToday = stats['queriesToday'] as int;

            return hiredAgentsAsync.when(
              data: (hiredAgents) {
                return Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        // Header with compact inline stats
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
                                  'My Agents',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                    fontSize: 24.sp,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xs.h),
                                Text(
                                  'Create and manage Agentic Envoys',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        scheme.onSurface.withValues(alpha: 0.7),
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.lg.h),

                                // Compact horizontal stats bar
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    CompactStat(
                                      value: totalAgents.toString(),
                                      label: 'Agents',
                                      scheme: scheme,
                                      theme: theme,
                                    ),
                                    Container(
                                      width: 1.w,
                                      height: 24.h,
                                      color:
                                          scheme.outline.withValues(alpha: 0.2),
                                    ),
                                    CompactStat(
                                      value:
                                          '\$${totalSpent.toStringAsFixed(2)}',
                                      label: 'Total Spent',
                                      scheme: scheme,
                                      theme: theme,
                                    ),
                                    Container(
                                      width: 1.w,
                                      height: 24.h,
                                      color:
                                          scheme.outline.withValues(alpha: 0.2),
                                    ),
                                    CompactStat(
                                      value: queriesToday.toString(),
                                      label: 'Queries Today',
                                      scheme: scheme,
                                      theme: theme,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                            child: SizedBox(height: AppSpacing.lg.h)),

                        // Hired Agents List
                        SliverPadding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                          sliver: hiredAgents.isEmpty
                              ? SliverFillRemaining(
                                  child: AgentsEmptyState(
                                      scheme: scheme, theme: theme),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final agent = hiredAgents[index]
                                          as Map<String, dynamic>;
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom: AppSpacing.md.h),
                                        child: HiredAgentCard(
                                          agent: agent,
                                          scheme: scheme,
                                          theme: theme,
                                          onTap: () {
                                            // TODO: Navigate to agent interaction screen
                                          },
                                        ),
                                      );
                                    },
                                    childCount: hiredAgents.length,
                                  ),
                                ),
                        ),

                        // Bottom spacing for nav bar
                        SliverToBoxAdapter(child: SizedBox(height: 96.h)),
                      ],
                    ),
                    Positioned(
                      bottom: AppSpacing.xxl.h * 2.5,
                      right: AppSpacing.lg.w,
                      child: GestureDetector(
                        onTap: () {
                          context.push(AppRoutePaths.createAgent);
                          // Reset animation when returning
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) _startCollapseAnimation();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: _isExpanded ? 150.w : 50.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.shadow.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14.r),
                              onTap: () {
                                context.push(AppRoutePaths.createAgent);
                                // Reset animation when returning
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  if (mounted) _startCollapseAnimation();
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: Row(
                                  mainAxisAlignment: _isExpanded
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.plusCircle,
                                      color: scheme.onPrimary,
                                      size: 24.sp,
                                    ),
                                    if (_isExpanded) ...[
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Text(
                                          'Create Agent',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: scheme.onPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14.sp,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading agents: $error'),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading stats: $error'),
          ),
        ),
      ),
    );
  }
}
