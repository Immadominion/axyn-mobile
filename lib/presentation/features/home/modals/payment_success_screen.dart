import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/presentation/features/home/providers/payment_flow_providers.dart';
import 'package:axyn_mobile/shared/widgets/app_button.dart';

/// Fullscreen modal showing payment success with animation.
///
/// Features:
/// - Success checkmark animation
/// - "Payment Received!" text
/// - Transaction details (amount, token, timestamp, signature)
/// - Two buttons: "View Receipt" and "New Transaction"
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.token,
    required this.signature,
  });

  final double amount;
  final TokenType token;
  final String signature;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copySignature() {
    Clipboard.setData(ClipboardData(text: widget.signature));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction signature copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokenLabel = widget.token == TokenType.usdc ? 'USDC' : 'USDT';

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success checkmark animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 72,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Payment Received text
              Text(
                'Payment Received!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Transaction details card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Amount',
                      value: '\$${widget.amount.toStringAsFixed(2)}',
                      isHighlighted: true,
                    ),
                    const Divider(height: AppSpacing.lg),
                    _DetailRow(
                      label: 'Token',
                      value: tokenLabel,
                    ),
                    const Divider(height: AppSpacing.lg),
                    _DetailRow(
                      label: 'Time',
                      value: _formatTime(DateTime.now()),
                    ),
                    const Divider(height: AppSpacing.lg),
                    _DetailRow(
                      label: 'Signature',
                      value: _truncateSignature(widget.signature),
                      onTap: _copySignature,
                      icon: PhosphorIconsRegular.copy,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action buttons
              Column(
                children: [
                  AppButton.primary(
                    label: 'New Transaction',
                    onPressed: () {
                      Navigator.of(context)
                        ..pop() // Close success screen
                        ..pop(); // Close QR modal (if still in stack)
                    },
                    icon: PhosphorIconsRegular.plus,
                    expanded: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton.secondary(
                    label: 'View Receipt',
                    onPressed: () {
                      // TODO: Implement receipt view
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Receipt feature coming soon'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: PhosphorIconsRegular.receipt,
                    expanded: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _truncateSignature(String sig) {
    if (sig.length <= 16) return sig;
    return '${sig.substring(0, 8)}...${sig.substring(sig.length - 8)}';
  }
}

/// Detail row in transaction details card.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final String value;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final PhosphorIconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? scheme.primary : scheme.onSurface,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              PhosphorIcon(
                icon!,
                size: 16,
                color: scheme.primary,
              ),
            ],
          ],
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
