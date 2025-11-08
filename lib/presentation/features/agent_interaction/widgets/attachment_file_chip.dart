import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';

/// Chip widget showing attached file with remove button
class AttachmentFileChip extends StatelessWidget {
  const AttachmentFileChip({
    required this.fileName,
    required this.fileSize,
    required this.onRemove,
    super.key,
  });

  final String fileName;
  final int fileSize;
  final VoidCallback onRemove;

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(right: AppSpacing.xs),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            PhosphorIconsFill.file,
            size: 16.sp,
            color: scheme.primary,
          ),
          SizedBox(width: AppSpacing.xs),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(fileSize),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10.sp,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(
                PhosphorIconsBold.x,
                size: 12.sp,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
