import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// Animated "thinking" indicator shown while agent is processing
///
/// Features:
/// - Animated dots to show activity
/// - Elapsed time display for long-running requests
/// - Warning after 30 seconds (indicates cold start or slow agent)
class AgentThinkingIndicator extends StatefulWidget {
  const AgentThinkingIndicator({
    required this.agentName,
    super.key,
  });

  final String agentName;

  @override
  State<AgentThinkingIndicator> createState() => _AgentThinkingIndicatorState();
}

class _AgentThinkingIndicatorState extends State<AgentThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late DateTime _startTime;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Update elapsed time every second
    _updateElapsedTime();
  }

  Future<void> _updateElapsedTime() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _elapsedSeconds = DateTime.now().difference(_startTime).inSeconds;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bool isSlowResponse = _elapsedSeconds > 30;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSlowResponse
                  ? scheme.tertiaryContainer
                  : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Agent avatar placeholder
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    size: 16,
                    color: scheme.primary,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),

                // Animated thinking dots
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.3;
                        final scale = ((_controller.value + delay) % 1.0);
                        final opacity =
                            scale < 0.5 ? scale * 2 : (1 - scale) * 2;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          child: Opacity(
                            opacity: 0.3 + (opacity * 0.7),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSlowResponse
                                    ? scheme.onTertiaryContainer
                                    : scheme.onPrimaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                if (_elapsedSeconds > 0) ...[
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_elapsedSeconds}s',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSlowResponse
                          ? scheme.onTertiaryContainer
                          : scheme.onPrimaryContainer,
                      fontFeatures: [
                        const FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ],

                if (isSlowResponse) ...[
                  SizedBox(width: AppSpacing.sm),
                  Tooltip(
                    message: 'The agent might be starting up (cold start)',
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
