import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../application/agents/agent_interaction_controller.dart';
import '../../../../application/agents/agent_proxy_provider.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/services/x402_service.dart';
import '../../../../domain/entities/agent_interaction_message.dart';
import '../../../../domain/entities/agent_listing.dart';
import '../modals/attachment_picker_modal.dart';
import '../modals/voice_recording_modal.dart';
import '../widgets/interaction_app_bar.dart';
import '../widgets/interaction_empty_state.dart';
import '../widgets/interaction_input_section.dart';
import '../widgets/interaction_messages_list.dart';

/// Agent Interaction Page - Chat interface for Type A agents
///
/// Features:
/// - Chat-style message interface
/// - Payment confirmation per message (x402)
/// - Agent response streaming
/// - Message history
/// - Input field with send button
class AgentInteractionPage extends ConsumerStatefulWidget {
  const AgentInteractionPage({
    required this.agent,
    super.key,
  });

  final AgentListing agent;

  @override
  ConsumerState<AgentInteractionPage> createState() =>
      _AgentInteractionPageState();
}

class _AgentInteractionPageState extends ConsumerState<AgentInteractionPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<PlatformFile> _attachedFiles = [];
  bool _isWaitingForResponse = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    final hasContent = message.isNotEmpty || _attachedFiles.isNotEmpty;

    if (!hasContent || _isWaitingForResponse) return;

    final conversationController =
        ref.read(agentInteractionControllerProvider.notifier);

    // Store attachments before clearing
    final attachmentsToSend = List<PlatformFile>.from(_attachedFiles);

    // Add user message
    setState(() {
      _messageController.clear();
      _attachedFiles.clear(); // Clear files after storing
      _focusNode.unfocus();
    });

    conversationController.addUserMessage(
      agentId: widget.agent.id,
      content: message.isEmpty ? '[File attachment]' : message,
    );

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      // Step 1: Make initial request to agent (will receive 402)
      AppLogger.d('[AgentInteraction] Calling agent ${widget.agent.id}');

      final proxyDatasource = ref.read(agentProxyDatasourceProvider);
      final x402Service = ref.read(x402ServiceProvider);

      dynamic response;
      String? paymentSignature;
      String? paymentNonce;

      try {
        // Initial call without payment
        response = await proxyDatasource.callAgent(
          agentId: widget.agent.id,
          message: message,
          attachedFiles: attachmentsToSend,
        );
      } on X402PaymentRequired catch (paymentDetails) {
        // Step 2: Got 402 - payment required
        AppLogger.d(
          '[AgentInteraction] Payment required: \$${paymentDetails.amountUsd}',
        );

        // Auto-approve small payments or show confirmation dialog
        final shouldApprove = x402Service.shouldAutoApprove(
          paymentDetails.amountUsd,
        );

        if (!shouldApprove && mounted) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Payment'),
              content: Text(
                'Pay \$${paymentDetails.amountUsd.toStringAsFixed(4)} USDC to ${widget.agent.name}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Pay'),
                ),
              ],
            ),
          );

          if (confirmed != true) {
            if (mounted) {
              conversationController.addErrorMessage(
                agentId: widget.agent.id,
                content: 'Payment cancelled',
              );

              setState(() {
                _isWaitingForResponse = false;
              });
            }
            return;
          }
        }

        // Step 3: Sign USDC payment using Privy
        AppLogger.d('[AgentInteraction] Signing payment...');
        final paymentService = ref.read(paymentServiceProvider);

        paymentSignature = await paymentService.payAgent(
          recipientAddress: paymentDetails.recipient,
          amountUsd: paymentDetails.amountUsd,
          agentName: widget.agent.name,
          network: paymentDetails.network, // Use network from backend
        );
        paymentNonce = paymentDetails.nonce;

        AppLogger.d('[AgentInteraction] Payment signed: $paymentSignature');

        // Show payment confirmation banner after successful payment
        if (mounted) {
          conversationController.addPaymentMessage(
            agentId: widget.agent.id,
            amount: paymentDetails.amountUsd,
          );

          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());

          // Now show loading indicator AFTER payment is confirmed
          setState(() {
            _isWaitingForResponse = true;
          });
        }

        // Step 4: Retry with payment proof
        response = await proxyDatasource.callAgent(
          agentId: widget.agent.id,
          message: message,
          paymentSignature: paymentSignature,
          paymentNonce: paymentNonce,
          attachedFiles: attachmentsToSend,
        );
      }

      // Step 5: Display agent response
      if (mounted) {
        final agentResponseData = response.agentResponse;
        final responseContent = _formatAgentResponseContent(agentResponseData);

        setState(() {
          _isWaitingForResponse = false;
        });

        conversationController.addAgentMessage(
          agentId: widget.agent.id,
          content: responseContent,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        AppLogger.d('[AgentInteraction] Response displayed successfully');
      }
    } catch (e, stack) {
      AppLogger.e('[AgentInteraction] Error: $e');
      AppLogger.e('[AgentInteraction] Stack: $stack');

      if (mounted) {
        // Categorize error for user-friendly message
        String errorMessage;
        String errorTitle;

        if (e.toString().contains('Connection refused') ||
            e.toString().contains('Failed host lookup')) {
          errorTitle = 'Connection Error';
          errorMessage =
              'Cannot reach the agent. Please check your internet connection.';
        } else if (e.toString().contains('timeout') ||
            e.toString().contains('receive timeout')) {
          errorTitle = 'Timeout';
          errorMessage =
              'The agent is taking too long to respond. It might be starting up (HuggingFace Spaces can have cold starts). Please try again.';
        } else if (e.toString().contains('Payment')) {
          errorTitle = 'Payment Error';
          errorMessage = 'Payment failed. Please check your USDC balance.';
        } else if (e.toString().contains('502') ||
            e.toString().contains('503') ||
            e.toString().contains('504')) {
          errorTitle = 'Agent Unavailable';
          errorMessage =
              'The agent service is temporarily unavailable. Please try again in a moment.';
        } else {
          errorTitle = 'Error';
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        conversationController.addErrorMessage(
          agentId: widget.agent.id,
          content: '$errorTitle: $errorMessage',
        );

        setState(() {
          _isWaitingForResponse = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        // Show snackbar with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade700,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Set message back and trigger send
                _messageController.text = message;
                _sendMessage();
              },
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  String _formatAgentResponseContent(dynamic data) {
    if (data == null) {
      return '';
    }

    if (data is String) {
      final parsed = _tryParseJsonString(data);
      if (parsed != null) {
        return _formatAgentResponseContent(parsed);
      }
      return data;
    }

    if (data is Map<String, dynamic>) {
      for (final key in const ['text', 'response', 'content', 'message']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          final parsed = _tryParseJsonString(value);
          if (parsed != null) {
            return _formatAgentResponseContent(parsed);
          }
          return value;
        }
      }

      final choices = data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final firstChoice = choices.first;
        if (firstChoice is Map<String, dynamic>) {
          final message = firstChoice['message'];
          if (message is Map<String, dynamic> && message['content'] is String) {
            return message['content'] as String;
          }
        }
      }

      if (data['transcription'] is String) {
        final transcription = data['transcription'] as String;
        final languageCode = data['language'];
        final languageLabel =
            languageCode is String ? _languageLabel(languageCode) : null;
        if (languageLabel != null) {
          return '**Language:** $languageLabel\n\n$transcription';
        }
        return transcription;
      }

      final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
      return '```json\n$prettyJson\n```';
    }

    if (data is List) {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
      return '```json\n$prettyJson\n```';
    }

    return data.toString();
  }

  String? _languageLabel(String code) {
    const languageNames = {
      'ig': 'Igbo',
      'en': 'English',
      'ha': 'Hausa',
      'yo': 'Yoruba',
    };

    return languageNames[code] ?? code;
  }

  dynamic _tryParseJsonString(String value) {
    final trimmed = value.trim();
    if (!(trimmed.startsWith('{') && trimmed.endsWith('}')) &&
        !(trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      return null;
    }

    try {
      return jsonDecode(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleAttachmentTap() async {
    showAttachmentPickerModal(
      context: context,
      onFileTypePicked: (fileType) async {
        // Pick file based on selected type
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: fileType.extensions,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          setState(() {
            _attachedFiles.add(result.files.first);
          });
        }
      },
    );
  }

  void _handleRemoveFile(PlatformFile file) {
    setState(() {
      _attachedFiles.remove(file);
    });
  }

  Future<void> _handleMicrophoneTap() async {
    final audioFile = await showVoiceRecordingModal(context: context);

    if (audioFile != null) {
      // Convert File to PlatformFile for attachment
      final platformFile = PlatformFile(
        name: audioFile.path.split('/').last,
        size: await audioFile.length(),
        path: audioFile.path,
      );

      setState(() {
        _attachedFiles.add(platformFile);
      });

      AppLogger.d(
          '[AgentInteraction] Voice recording attached: ${platformFile.name}');
    }
  }

  void _handleInfoTap() {
    // TODO: Show agent info modal with details, pricing, examples
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    ref.listen<List<AgentInteractionMessage>>(
      agentConversationProvider(widget.agent.id),
      (previous, next) {
        if (previous == null || next.length > previous.length) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }
      },
    );
    final messages = ref.watch(agentConversationProvider(widget.agent.id));

    return GestureDetector(
      onTap: _focusNode.unfocus,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: InteractionAppBar(
          agent: widget.agent,
          onInfoTap: _handleInfoTap,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.7,
                child: Container(
                  // Use a raster asset that can be repeated. Convert the SVG to a small PNG
                  // (e.g. assets/images/backgrounds/doodle.png) and add it to pubspec.yaml.
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/backgrounds/doodle.png'),
                      repeat: ImageRepeat.repeat,
                      // Increase scale to make each tile appear smaller. Tweak to taste.
                      scale: 7.0,
                      alignment: Alignment.topLeft,
                      fit: BoxFit.none,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                // Messages list
                Expanded(
                  child: messages.isEmpty
                      ? InteractionEmptyState(agent: widget.agent)
                      : InteractionMessagesList(
                          messages: messages,
                          scrollController: _scrollController,
                          agentName: widget.agent.name,
                          isWaitingForResponse: _isWaitingForResponse,
                          scheme: scheme,
                          theme: theme,
                        ),
                ),

                // Input section
                InteractionInputSection(
                  controller: _messageController,
                  isWaitingForResponse: _isWaitingForResponse,
                  attachedFiles: _attachedFiles,
                  onSendMessage: _sendMessage,
                  onAttachmentTap: _handleAttachmentTap,
                  onMicrophoneTap: _handleMicrophoneTap,
                  onRemoveFile: _handleRemoveFile,
                  focusNode: _focusNode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
