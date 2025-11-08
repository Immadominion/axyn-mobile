import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';

/// Agent message bubble - left-aligned with avatar
///
/// Features:
/// - Markdown rendering (bold, italic, code blocks, lists)
/// - Syntax highlighting for code blocks
/// - Clickable links
/// - Loading state support
class AgentMessageBubble extends StatelessWidget {
  const AgentMessageBubble({
    required this.content,
    required this.timestamp,
    required this.agentName,
    required this.scheme,
    required this.theme,
    this.isLoading = false,
    super.key,
  });

  final String content;
  final DateTime timestamp;
  final String agentName;
  final ColorScheme scheme;
  final ThemeData theme;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agent avatar
          Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/icons/axyn.png',
                width: 24.w,
                height: 24.w,
              )),
          SizedBox(width: AppSpacing.sm.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.sm.h,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading)
                    _buildLoadingIndicator()
                  else
                    _buildMarkdownContent(),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('HH:mm').format(timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      children: [
        SizedBox(
          width: 12.w,
          height: 12.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(scheme.secondary),
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Text(
          'Thinking...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent() {
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
          height: 1.4,
        ),
        code: theme.textTheme.bodySmall?.copyWith(
          color: scheme.primary,
          fontFamily: 'monospace',
          backgroundColor: scheme.primaryContainer.withValues(alpha: 0.3),
        ),
        codeblockDecoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.3),
          ),
        ),
        codeblockPadding: EdgeInsets.all(AppSpacing.sm.w),
        blockquote: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: scheme.outline,
              width: 2,
            ),
          ),
        ),
        h1: theme.textTheme.headlineMedium?.copyWith(
          color: scheme.onSurface,
        ),
        h2: theme.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
        h3: theme.textTheme.titleMedium?.copyWith(
          color: scheme.onSurface,
        ),
        listBullet: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.primary,
        ),
        a: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
