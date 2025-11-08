import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axyn_mobile/domain/entities/agent_interaction_message.dart';

final agentInteractionControllerProvider = NotifierProvider<
    AgentInteractionController, Map<String, List<AgentInteractionMessage>>>(
  AgentInteractionController.new,
);

final agentConversationProvider =
    Provider.family<List<AgentInteractionMessage>, String>((ref, agentId) {
  final conversations = ref.watch(agentInteractionControllerProvider);
  final messages = conversations[agentId];
  if (messages == null) {
    return const <AgentInteractionMessage>[];
  }

  return UnmodifiableListView(messages);
});

class AgentInteractionController
    extends Notifier<Map<String, List<AgentInteractionMessage>>> {
  @override
  Map<String, List<AgentInteractionMessage>> build() =>
      <String, List<AgentInteractionMessage>>{};

  List<AgentInteractionMessage> messagesForAgent(String agentId) =>
      UnmodifiableListView(_messagesFor(agentId));

  void addUserMessage({
    required String agentId,
    required String content,
  }) {
    _addMessage(
      agentId: agentId,
      message: AgentInteractionMessage.user(content: content),
    );
  }

  void addAgentMessage({
    required String agentId,
    required String content,
  }) {
    _addMessage(
      agentId: agentId,
      message: AgentInteractionMessage.agent(content: content),
    );
  }

  void addPaymentMessage({
    required String agentId,
    required double amount,
  }) {
    _addMessage(
      agentId: agentId,
      message: AgentInteractionMessage.payment(amount: amount),
    );
  }

  void addErrorMessage({
    required String agentId,
    required String content,
  }) {
    _addMessage(
      agentId: agentId,
      message: AgentInteractionMessage.error(content: content),
    );
  }

  void clearConversation(String agentId) {
    if (!state.containsKey(agentId)) {
      return;
    }

    final next = Map<String, List<AgentInteractionMessage>>.from(state)
      ..remove(agentId);
    state = next;
  }

  List<AgentInteractionMessage> _messagesFor(String agentId) {
    return state[agentId] ?? const <AgentInteractionMessage>[];
  }

  void _addMessage({
    required String agentId,
    required AgentInteractionMessage message,
  }) {
    final existing = List<AgentInteractionMessage>.from(_messagesFor(agentId));
    existing.add(message);

    final next = Map<String, List<AgentInteractionMessage>>.from(state)
      ..[agentId] = existing;
    state = next;
  }
}
