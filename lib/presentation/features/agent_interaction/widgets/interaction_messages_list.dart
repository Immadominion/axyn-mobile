import 'package:flutter/material.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/domain/entities/agent_interaction_message.dart';
import 'package:axyn_mobile/presentation/features/agent_interaction/widgets/agent_message_bubble.dart';
import 'package:axyn_mobile/presentation/features/agent_interaction/widgets/payment_confirmation_banner.dart';
import 'package:axyn_mobile/presentation/features/agent_interaction/widgets/user_message_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Message list displaying conversation history
class InteractionMessagesList extends StatelessWidget {
  const InteractionMessagesList({
    required this.messages,
    required this.scrollController,
    required this.agentName,
    required this.isWaitingForResponse,
    required this.scheme,
    required this.theme,
    super.key,
  });

  final List<AgentInteractionMessage> messages;
  final ScrollController scrollController;
  final String agentName;
  final bool isWaitingForResponse;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Add 1 to itemCount if waiting for response (for loading bubble)
    final itemCount = messages.length + (isWaitingForResponse ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(AppSpacing.sm.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Show loading bubble at the end if waiting for response
        if (isWaitingForResponse && index == messages.length) {
          return AgentMessageBubble(
            content: '', // Empty content, will show loading indicator
            timestamp: DateTime.now(),
            agentName: agentName,
            scheme: scheme,
            theme: theme,
            isLoading: true,
          );
        }

        final message = messages[index];

        switch (message.type) {
          case AgentInteractionMessageType.user:
            return UserMessageBubble(
              content: message.content ?? '',
              timestamp: message.timestamp,
              scheme: scheme,
              theme: theme,
            );
          case AgentInteractionMessageType.agent:
            return AgentMessageBubble(
              content: message.content ?? '',
              timestamp: message.timestamp,
              agentName: agentName,
              scheme: scheme,
              theme: theme,
            );
          case AgentInteractionMessageType.payment:
            return PaymentConfirmationBanner(
              amount: message.amount ?? 0,
              scheme: scheme,
              theme: theme,
            );
          case AgentInteractionMessageType.error:
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Text(
                  message.content ?? 'Something went wrong',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
