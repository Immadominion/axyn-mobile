import 'package:meta/meta.dart';

enum AgentInteractionMessageType {
  user,
  agent,
  payment,
  error,
}

/// Immutable model representing a single entry in an agent conversation.
@immutable
class AgentInteractionMessage {
  const AgentInteractionMessage({
    required this.type,
    this.content,
    this.amount,
    required this.timestamp,
  }) : assert(
          type != AgentInteractionMessageType.payment || amount != null,
          'Payment messages require an amount.',
        );

  factory AgentInteractionMessage.user({
    required String content,
    DateTime? timestamp,
  }) =>
      AgentInteractionMessage(
        type: AgentInteractionMessageType.user,
        content: content,
        timestamp: timestamp ?? DateTime.now(),
      );

  factory AgentInteractionMessage.agent({
    required String content,
    DateTime? timestamp,
  }) =>
      AgentInteractionMessage(
        type: AgentInteractionMessageType.agent,
        content: content,
        timestamp: timestamp ?? DateTime.now(),
      );

  factory AgentInteractionMessage.payment({
    required double amount,
    DateTime? timestamp,
  }) =>
      AgentInteractionMessage(
        type: AgentInteractionMessageType.payment,
        amount: amount,
        timestamp: timestamp ?? DateTime.now(),
      );

  factory AgentInteractionMessage.error({
    required String content,
    DateTime? timestamp,
  }) =>
      AgentInteractionMessage(
        type: AgentInteractionMessageType.error,
        content: content,
        timestamp: timestamp ?? DateTime.now(),
      );

  final AgentInteractionMessageType type;
  final String? content;
  final double? amount;
  final DateTime timestamp;
}
