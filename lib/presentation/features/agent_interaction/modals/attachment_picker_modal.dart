import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/shared/widgets/app_modal_sheet.dart';

/// File types that can be attached to agent messages
/// Based on most common AI agent file support (Claude, GPT, etc.)
enum AttachmentFileType {
  image('Image', PhosphorIconsRegular.image,
      ['jpg', 'jpeg', 'png', 'gif', 'webp']),
  document(
      'Document', PhosphorIconsRegular.fileText, ['pdf', 'doc', 'docx', 'txt']),
  spreadsheet(
      'Spreadsheet', PhosphorIconsRegular.table, ['xlsx', 'xls', 'csv']),
  audio('Audio', PhosphorIconsRegular.waveform,
      ['mp3', 'm4a', 'wav', 'aac', 'ogg']);

  const AttachmentFileType(this.label, this.icon, this.extensions);

  final String label;
  final IconData icon;
  final List<String> extensions;
}

/// Modal for selecting file type to attach to message
///
/// Displays a grid of file type options that agents commonly need
void showAttachmentPickerModal({
  required BuildContext context,
  required void Function(AttachmentFileType) onFileTypePicked,
}) {
  showAppModalSheet<void>(
    context: context,
    builder: (context) => _AttachmentPickerContent(
      onFileTypePicked: onFileTypePicked,
    ),
  );
}

class _AttachmentPickerContent extends StatelessWidget {
  const _AttachmentPickerContent({
    required this.onFileTypePicked,
  });

  final void Function(AttachmentFileType) onFileTypePicked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attach File',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Select the type of file you want to attach',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),

        // File type list
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: AttachmentFileType.values.map((fileType) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _FileTypeCard(
                  fileType: fileType,
                  onTap: () {
                    Navigator.of(context).pop();
                    onFileTypePicked(fileType);
                  },
                  scheme: scheme,
                  theme: theme,
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

/// Individual file type card
class _FileTypeCard extends StatelessWidget {
  const _FileTypeCard({
    required this.fileType,
    required this.onTap,
    required this.scheme,
    required this.theme,
  });

  final AttachmentFileType fileType;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: PhosphorIcon(
                fileType.icon,
                size: 24.sp,
                color: scheme.primary,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileType.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    fileType.extensions.map((e) => e.toUpperCase()).join(', '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            PhosphorIcon(
              PhosphorIconsRegular.caretRight,
              size: 20.sp,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
