import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/presentation/features/home/modals/payment_success_screen.dart';
import 'package:axyn_mobile/presentation/features/home/providers/payment_flow_providers.dart';
import 'package:axyn_mobile/shared/widgets/app_button.dart';

/// Modal for displaying QR code and waiting for payment.
///
/// Features:
/// - Large QR code (center)
/// - Payment amount (above QR)
/// - Selected token (above QR)
/// - "Waiting for payment..." status text
/// - Sound toggle icon (top-right)
/// - Countdown timer (optional)
/// - "Cancel" button (bottom)
class QrPaymentModal extends StatefulWidget {
  const QrPaymentModal({
    super.key,
    required this.amount,
    required this.token,
  });

  final double amount;
  final TokenType token;

  @override
  State<QrPaymentModal> createState() => _QrPaymentModalState();
}

class _QrPaymentModalState extends State<QrPaymentModal> {
  bool _soundEnabled = true;
  Timer? _mockPaymentTimer;

  @override
  void initState() {
    super.initState();
    // Mock payment received after 5 seconds (for demo purposes)
    _mockPaymentTimer = Timer(const Duration(seconds: 5), _onPaymentReceived);
  }

  @override
  void dispose() {
    _mockPaymentTimer?.cancel();
    super.dispose();
  }

  void _onPaymentReceived() {
    if (!mounted) return;

    Navigator.of(context).pop();
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          amount: widget.amount,
          token: widget.token,
          signature: 'mock_signature_${DateTime.now().millisecondsSinceEpoch}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final tokenLabel = widget.token == TokenType.usdc ? 'USDC' : 'USDT';

    // Mock Solana address for QR code
    final mockAddress = 'DemoAddress${widget.amount}${tokenLabel}123456789';

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with sound toggle
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scan to Pay',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _soundEnabled = !_soundEnabled;
                    });
                  },
                  icon: PhosphorIcon(
                    _soundEnabled
                        ? PhosphorIconsRegular.speakerHigh
                        : PhosphorIconsRegular.speakerSlash,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.primaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Amount and token display
                  Text(
                    '\$${widget.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tokenLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: mockAddress,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Waiting status with pulsing animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(scheme.primary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Waiting for payment...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Instructions
                  Text(
                    'Customer should scan this QR code with their Solana wallet',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cancel button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SafeArea(
              child: AppButton.secondary(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
                expanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
