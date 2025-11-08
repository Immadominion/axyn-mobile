import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../application/account/balance_provider.dart';
import '../../../../application/agents/agent_list_controller.dart';
import '../../../../application/agents/agents_provider.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/routes.dart';
import '../../../../domain/entities/agent_listing.dart';
import '../modals/balance_info_modal.dart';
import '../widgets/agent_card.dart';
import '../widgets/battery_indicator.dart';
import '../widgets/category_chip.dart';
import '../widgets/quick_action_card.dart';

/// HOME tab - Browse and discover AI agents
///
/// Browse and search for AI agents. View trending agents, search by skills,
/// and connect your wallet to interact with agents.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debounce search to avoid too many requests
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        // Refresh to show all agents
        ref.read(agentListControllerProvider.notifier).refresh();
      } else {
        // Search with query
        ref.read(agentListControllerProvider.notifier).search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(balanceProvider);
    final recentAgents = ref
        .watch(recentAgentsProvider)
        .maybeWhen(data: (agents) => agents, orElse: () => <AgentListing>[]);
    final agentListAsync = ref.watch(agentListControllerProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Fixed Header with battery indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with Battery Indicator
                Row(
                  children: [
                    Text(
                      'Discover AI Agents',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () => showBalanceInfoModal(
                        context: context,
                        balance: balance,
                      ),
                      child: BatteryIndicator(
                        balance: balance,
                        scheme: scheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Find and hire AI agents to help with your tasks',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Fixed Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'What do you want to do?',
                hintStyle: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: PhosphorIcon(
                  PhosphorIconsBold.binoculars,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor:
                    scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: scheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Quick Actions - only show if user has recent agents
          if (recentAgents.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      PhosphorIcon(
                        PhosphorIconsRegular.clockClockwise,
                        size: 20.sp,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            SizedBox(
              height: 130.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                itemCount: recentAgents.length,
                separatorBuilder: (_, __) => SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final agent = recentAgents[index];
                  return QuickActionCard(
                    agent: agent,
                    onTap: () => _navigateToAgentDetail(context, agent),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          // Fixed Category tabs - full width scrolling
          SizedBox(
            height: 52.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              children: [
                CategoryChip('All', isSelected: true, scheme: scheme),
                const SizedBox(width: AppSpacing.sm),
                CategoryChip('Trending', scheme: scheme),
                const SizedBox(width: AppSpacing.sm),
                CategoryChip('Recent', scheme: scheme),
                const SizedBox(width: AppSpacing.sm),
                CategoryChip('Crypto', scheme: scheme),
                const SizedBox(width: AppSpacing.sm),
                CategoryChip('Analysis', scheme: scheme),
                const SizedBox(width: AppSpacing.sm),
                CategoryChip('Trading', scheme: scheme),
                const SizedBox(width: AppSpacing.sm),
                CategoryChip('Research', scheme: scheme),
              ],
            ),
          ),

          // Scrollable Agent grid
          Expanded(
            child: agentListAsync.when(
              data: (agents) {
                if (agents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'No agents available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Check back later for new AI agents',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(agentListControllerProvider.notifier)
                        .refresh();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                    ),
                    itemCount: agents.length,
                    itemBuilder: (context, index) {
                      final agent = agents[index];
                      return AgentCard(
                        agent: agent,
                        onTap: () => _navigateToAgentDetail(context, agent),
                      );
                    },
                  ),
                );
              },
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: scheme.primary,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Loading agents...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PhosphorIcon(
                        PhosphorIconsRegular.warningCircle,
                        size: 64.sp,
                        color: scheme.error,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Failed to load agents',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.md),
                      FilledButton.icon(
                        onPressed: () {
                          ref
                              .read(agentListControllerProvider.notifier)
                              .refresh();
                        },
                        icon: PhosphorIcon(
                          PhosphorIconsRegular.arrowClockwise,
                          size: 20.sp,
                        ),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAgentDetail(BuildContext context, dynamic agent) {
    // Navigate to agent detail page
    context.push(
      AppRoutePaths.agentDetail,
      extra: agent,
    );
  }
}
