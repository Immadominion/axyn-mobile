import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/shared/widgets/app_button.dart';

/// Activity detail modal showing full prompt, response, and transaction info
class ActivityDetailModal extends ConsumerWidget {
  const ActivityDetailModal({
    required this.activity,
    super.key,
  });

  final Map<String, dynamic> activity;

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, y \'at\' h:mm a').format(timestamp);
  }

  Future<void> _openSolanaExplorer(String signature) async {
    final url = Uri.parse(
      'https://explorer.solana.com/tx/$signature?cluster=mainnet-beta',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final activityType = activity['activityType'] as String? ?? 'query';
    final agentName = activity['agentName'] as String? ?? 'Unknown Agent';
    final category = activity['category'] as String? ?? 'General';
    final amount = (activity['amount'] as num?)?.toDouble() ?? 0.0;
    final signature = activity['signature'] as String? ?? '';
    final userPrompt = activity['userPrompt'] as String? ?? '';
    final responseSummary = activity['responseSummary'] as String? ?? '';

    final timestampRaw = activity['timestamp'];
    final timestamp = timestampRaw is DateTime
        ? timestampRaw
        : DateTime.tryParse(timestampRaw.toString()) ?? DateTime.now();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.all(Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Row(
              children: [
                // Activity type icon
                Container(
                  width: 48.w,
                  height: 48.w,
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
                  ),
                  child: Icon(
                    _getActivityIcon(activityType),
                    size: 24.sp,
                    color: scheme.primary,
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agentName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    PhosphorIcons.x(PhosphorIconsStyle.bold),
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: scheme.outline.withValues(alpha: 0.2)),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction info
                  _buildInfoSection(
                    theme,
                    scheme,
                    'Transaction Details',
                    [
                      _buildInfoRow(
                        theme,
                        scheme,
                        'Amount',
                        '\$${amount.toStringAsFixed(2)} USDC',
                      ),
                      _buildInfoRow(
                        theme,
                        scheme,
                        'Date',
                        _formatTimestamp(timestamp),
                      ),
                      _buildInfoRow(
                        theme,
                        scheme,
                        'Type',
                        _getActivityTypeLabel(activityType),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.lg.h),

                  // User prompt
                  if (userPrompt.isNotEmpty) ...[
                    _buildContentSection(
                      theme,
                      scheme,
                      'Your Prompt',
                      userPrompt,
                      PhosphorIcons.chatCircleText(PhosphorIconsStyle.regular),
                      onCopy: () =>
                          _copyToClipboard(context, userPrompt, 'Prompt'),
                    ),
                    SizedBox(height: AppSpacing.lg.h),
                  ],

                  // Agent response
                  if (responseSummary.isNotEmpty) ...[
                    _buildContentSection(
                      theme,
                      scheme,
                      'Agent Response',
                      responseSummary,
                      PhosphorIcons.robot(PhosphorIconsStyle.regular),
                      onCopy: () => _copyToClipboard(
                          context, responseSummary, 'Response'),
                    ),
                    SizedBox(height: AppSpacing.lg.h),
                  ],

                  // Signature
                  if (signature.isNotEmpty) ...[
                    _buildSignatureSection(
                      theme,
                      scheme,
                      signature,
                      onCopy: () =>
                          _copyToClipboard(context, signature, 'Signature'),
                      onViewExplorer: () => _openSolanaExplorer(signature),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom actions
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: AppButton.primary(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Close',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    ColorScheme scheme,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Container(
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    ColorScheme scheme,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14.sp,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(
    ThemeData theme,
    ColorScheme scheme,
    String title,
    String content,
    IconData icon, {
    VoidCallback? onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: scheme.primary),
            SizedBox(width: 8.w),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            const Spacer(),
            if (onCopy != null)
              IconButton(
                onPressed: onCopy,
                icon: Icon(
                  PhosphorIcons.copy(PhosphorIconsStyle.regular),
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(
    ThemeData theme,
    ColorScheme scheme,
    String signature, {
    VoidCallback? onCopy,
    VoidCallback? onViewExplorer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.fingerprint(PhosphorIconsStyle.regular),
              size: 18.sp,
              color: scheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Transaction Signature',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                signature,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  fontFamily: 'monospace',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.sm.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onCopy != null)
                    TextButton.icon(
                      onPressed: onCopy,
                      icon: Icon(
                        PhosphorIcons.copy(PhosphorIconsStyle.regular),
                        size: 16.sp,
                      ),
                      label: const Text('Copy'),
                    ),
                  if (onViewExplorer != null)
                    TextButton.icon(
                      onPressed: onViewExplorer,
                      icon: Icon(
                        PhosphorIcons.arrowSquareOut(
                            PhosphorIconsStyle.regular),
                        size: 16.sp,
                      ),
                      label: const Text('View on Explorer'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
      default:
        return PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
    }
  }

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
      default:
        return 'Activity';
    }
  }
}
