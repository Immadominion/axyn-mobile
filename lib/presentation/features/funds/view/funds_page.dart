import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/transactions/transaction_provider.dart';
import '../../../../core/constants/app_sizes.dart';

/// MY AGENTS tab - View and manage hired AI agents.
///
/// Features:
/// - Stats overview (total agents, total spent, queries today)
/// - List of hired agents with usage stats
/// - Quick access to interact with agents again
/// - Filter by recently used, most used, etc.
class FundsPage extends ConsumerWidget {
  const FundsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Fetch real transaction data from backend
    final transactionsAsync = ref.watch(userTransactionsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        // Calculate stats from real transactions
        final totalAgents = transactions
            .map((tx) => (tx as Map<String, dynamic>)['agentId'])
            .toSet()
            .length;
        final totalSpent = transactions.fold<double>(
          0,
          (sum, tx) =>
              sum + ((tx as Map<String, dynamic>)['amount'] as num).toDouble(),
        );

        // Count transactions today
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final queriesToday = transactions.where((tx) {
          final createdAt = DateTime.parse(
            (tx as Map<String, dynamic>)['createdAt'] as String,
          );
          return createdAt.isAfter(todayStart);
        }).length;

        return _buildContent(
          context,
          scheme,
          theme,
          totalAgents,
          totalSpent,
          queriesToday,
          transactions,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load transactions',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
    int totalAgents,
    double totalSpent,
    int queriesToday,
    List<dynamic> transactions,
  ) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Agents',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Manage your hired AI agents',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Overview Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.smart_toy_rounded,
                      label: 'Agents',
                      value: totalAgents.toString(),
                      scheme: scheme,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.payments_rounded,
                      label: 'Total Spent',
                      value: '\$${totalSpent.toStringAsFixed(2)}',
                      scheme: scheme,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.trending_up_rounded,
                      label: 'Today',
                      value: queriesToday.toString(),
                      scheme: scheme,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip('All', isSelected: true, scheme: scheme),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip('Recent', scheme: scheme),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip('Most Used', scheme: scheme),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip('Favorites', scheme: scheme),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Hired Agents List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: transactions.isEmpty
                ? SliverFillRemaining(
                    child: _EmptyState(scheme: scheme, theme: theme),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = transactions[index] as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _TransactionCard(
                            transaction: tx,
                            scheme: scheme,
                            theme: theme,
                          ),
                        );
                      },
                      childCount: transactions.length,
                    ),
                  ),
          ),

          // Bottom spacing for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

/// Small stat card for overview metrics
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: scheme.primary,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  const _FilterChip(
    this.label, {
    this.isSelected = false,
    required this.scheme,
  });

  final String label;
  final bool isSelected;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filtering
      },
      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
      selectedColor: scheme.primary.withValues(alpha: 0.2),
      checkmarkColor: scheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? scheme.primary : scheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            isSelected ? scheme.primary : scheme.outline.withValues(alpha: 0.2),
      ),
    );
  }
}

/// Transaction card showing agent interaction history
class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.scheme,
    required this.theme,
  });

  final Map<String, dynamic> transaction;
  final ColorScheme scheme;
  final ThemeData theme;

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

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(transaction['createdAt'] as String);
    final agentName = transaction['agentName'] as String? ?? 'Unknown Agent';
    final amount = (transaction['amount'] as num).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
          Row(
            children: [
              // Agent icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: scheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Transaction info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agentName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLastUsed(createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                '\$${amount.toStringAsFixed(4)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Transaction signature (truncated)
          Text(
            'Tx: ${(transaction['signature'] as String).substring(0, 20)}...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // View on Explorer button
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Open Solana Explorer with transaction signature
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('View on Explorer'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small stat pill for agent card
class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no agents are hired
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.scheme,
    required this.theme,
  });

  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 80,
            color: scheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No agents hired yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Discover and hire AI agents\nfrom the marketplace',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
