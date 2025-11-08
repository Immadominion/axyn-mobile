import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/domain/entities/agent_listing.dart';
import 'package:axyn_mobile/shared/widgets/app_modal_sheet.dart';

/// Show agent share modal with options to share link or copy.
Future<void> showAgentShareModal({
  required BuildContext context,
  required AgentListing agent,
}) {
  return showAppModalSheet<void>(
    context: context,
    builder: (sheetContext) => _AgentShareContent(agent: agent),
  );
}

/// Agent share modal content widget.
class _AgentShareContent extends StatelessWidget {
  const _AgentShareContent({required this.agent});

  final AgentListing agent;

  // TODO: Replace with actual deep link once backend is ready
  String get shareLink => 'https://axyn.ai/agent/${agent.id}';

  String get shareText =>
      'Check out ${agent.name} on AxyN!\n\n${agent.description}\n\nPrice: ${agent.priceDisplay}\nRating: ${agent.ratingDisplay}⭐\n\n$shareLink';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Share Agent',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Agent info
          Text(
            agent.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl),

          // Share link box
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    shareLink,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: shareLink));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Link copied to clipboard'),
                          backgroundColor: scheme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          margin: EdgeInsets.all(AppSpacing.lg),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: PhosphorIcon(
                      PhosphorIconsBold.copy,
                      size: 16.sp,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          // Share button
          FilledButton(
            onPressed: () async {
              await Share.share(
                shareText,
                subject: 'Check out ${agent.name} on AxyN',
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIconsBold.shareNetwork,
                  color: scheme.onPrimary,
                  size: 20.sp,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Share via...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: Text(
              'Cancel',
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
