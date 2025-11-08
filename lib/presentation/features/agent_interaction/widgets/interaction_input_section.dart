import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/presentation/features/agent_interaction/widgets/attachment_file_chip.dart';

/// Input section with text field, attachment preview, microphone, and send buttons
class InteractionInputSection extends StatefulWidget {
  const InteractionInputSection({
    required this.controller,
    required this.isWaitingForResponse,
    required this.attachedFiles,
    required this.onSendMessage,
    required this.onAttachmentTap,
    required this.onMicrophoneTap,
    required this.onRemoveFile,
    required this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final bool isWaitingForResponse;
  final List<PlatformFile> attachedFiles;
  final VoidCallback onSendMessage;
  final VoidCallback onAttachmentTap;
  final VoidCallback onMicrophoneTap;
  final void Function(PlatformFile) onRemoveFile;
  final FocusNode focusNode;

  @override
  State<InteractionInputSection> createState() =>
      _InteractionInputSectionState();
}

class _InteractionInputSectionState extends State<InteractionInputSection> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasContent = _hasText || widget.attachedFiles.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // File attachments preview
            if (widget.attachedFiles.isNotEmpty)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: AppSpacing.xs.h),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: widget.attachedFiles.map((file) {
                    return AttachmentFileChip(
                      fileName: file.name,
                      fileSize: file.size,
                      onRemove: () => widget.onRemoveFile(file),
                    );
                  }).toList(),
                ),
              ),

            // Input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text field with plus icon inside
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    enabled: !widget.isWaitingForResponse,
                    focusNode: widget.focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                      filled: true,

                      fillColor:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28.r),
                        borderSide: BorderSide(
                          color: scheme.outline.withValues(alpha: 0.2),
                          width: 2.sp,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28.r),
                        borderSide: BorderSide(
                          color: scheme.outline.withValues(alpha: 0.2),
                          width: 2.sp,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28.r),
                        borderSide: BorderSide(
                          color: scheme.primary,
                          width: 2.sp,
                        ),
                      ),

                      contentPadding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.lg,
                        top: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                      // Plus icon inside text field
                      prefixIcon: IconButton(
                        onPressed: widget.isWaitingForResponse
                            ? null
                            : widget.onAttachmentTap,
                        icon: PhosphorIcon(
                          PhosphorIconsBold.toolbox,
                          color: widget.isWaitingForResponse
                              ? scheme.onSurface.withValues(alpha: 0.5)
                              : scheme.primary,
                          size: 22.sp,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => widget.onSendMessage(),
                  ),
                ),

                // Microphone or Send button
                if (hasContent)
                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color: widget.isWaitingForResponse
                          ? scheme.surfaceContainerHighest
                          : scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: widget.onSendMessage,
                      icon: widget.isWaitingForResponse
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  scheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            )
                          : PhosphorIcon(
                              PhosphorIconsBold.paperPlaneTilt,
                              color: scheme.onPrimary,
                              size: 20.sp,
                            ),
                    ),
                  )
                else
                  // Microphone button
                  IconButton(
                    onPressed: widget.isWaitingForResponse
                        ? null
                        : widget.onMicrophoneTap,
                    icon: PhosphorIcon(
                      PhosphorIconsBold.microphone,
                      color: widget.isWaitingForResponse
                          ? scheme.onSurface.withValues(alpha: 0.1)
                          : scheme.onSurface.withValues(alpha: 0.3),
                      size: 24.sp,
                    ),
                    padding: EdgeInsets.all(8.w),
                    constraints: BoxConstraints(
                      minWidth: 40.w,
                      minHeight: 40.w,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
