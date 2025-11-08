import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/shared/widgets/app_button.dart';

/// Modal for displaying full transaction details.
///
/// Features:
/// - Transaction type (Payment/Withdrawal/Refund)
/// - Amount (large display)
/// - Date & time (full)
/// - Status badge
/// - Transaction signature (with copy)
/// - "View on Solscan" link
class TransactionDetailModal extends StatelessWidget {
  const TransactionDetailModal({
    super.key,
    required this.transaction,
  });

  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final token = transaction['token'] as String;
    final timestamp = transaction['timestamp'] as DateTime;
    final status = transaction['status'] as String;
    final signature = transaction['signature'] as String;
    final isNegative = amount < 0;

    return Container(
      height: mediaQuery.size.height * 0.75,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Transaction Details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: PhosphorIcon(PhosphorIconsRegular.x),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  // Type icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isNegative
                          ? scheme.errorContainer
                          : scheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: PhosphorIcon(
                      isNegative
                          ? PhosphorIconsRegular.arrowCircleUp
                          : PhosphorIconsRegular.arrowCircleDown,
                      size: 48,
                      color: isNegative
                          ? scheme.onErrorContainer
                          : scheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Amount
                  Text(
                    '${isNegative ? '' : '+'}\$${amount.abs().toStringAsFixed(2)}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isNegative ? scheme.error : scheme.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Details container
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Token',
                          value: token,
                        ),
                        const Divider(height: AppSpacing.lg),
                        _DetailRow(
                          label: 'Date & Time',
                          value: DateFormat('MMM d, yyyy • HH:mm:ss')
                              .format(timestamp),
                        ),
                        const Divider(height: AppSpacing.lg),
                        _DetailRow(
                          label: 'Status',
                          value: status,
                          valueColor: scheme.primary,
                        ),
                        const Divider(height: AppSpacing.lg),
                        _DetailRow(
                          label: 'Signature',
                          value: _truncateSignature(signature),
                          icon: PhosphorIconsRegular.copy,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: signature));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Signature copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // View on Solscan button
                  AppButton.secondary(
                    label: 'View on Solscan',
                    onPressed: () {
                      // TODO: Open Solscan URL
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening Solscan...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: PhosphorIconsRegular.arrowSquareOut,
                    expanded: true,
                  ),
                ],
              ),
            ),
          ),

          // Close button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SafeArea(
              child: AppButton.primary(
                label: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                expanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateSignature(String sig) {
    if (sig.length <= 16) return sig;
    return '${sig.substring(0, 8)}...${sig.substring(sig.length - 8)}';
  }
}

/// Detail row in transaction details.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final PhosphorIconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? scheme.onSurface,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              PhosphorIcon(
                icon!,
                size: 16,
                color: scheme.primary,
              ),
            ],
          ],
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
