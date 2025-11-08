import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/shared/widgets/app_button.dart';

/// Modal for withdrawing funds from merchant account.
///
/// Features:
/// - Selected token display
/// - Current balance (prominent)
/// - Amount input field
/// - Quick amount buttons (25%, 50%, 75%, MAX)
/// - Recipient address field (with paste button)
/// - Platform fee display (1.25%)
/// - Withdraw button
class WithdrawModal extends StatefulWidget {
  const WithdrawModal({
    super.key,
    required this.token,
    required this.balance,
  });

  final String token;
  final double balance;

  @override
  State<WithdrawModal> createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<WithdrawModal> {
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  double _amount = 0;

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    setState(() {
      _amount = amount;
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  void _withdraw() {
    // TODO: Implement withdraw logic
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Withdrawing \$${_amount.toStringAsFixed(2)} ${widget.token}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final fee = _amount * 0.0125; // 1.25% platform fee
    final netAmount = _amount - fee;
    final canWithdraw = _amount > 0 &&
        _amount <= widget.balance &&
        _recipientController.text.isNotEmpty;

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

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Withdraw ${widget.token}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: PhosphorIcon(PhosphorIconsRegular.x),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current balance
                  Text(
                    'Available Balance',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '\$${widget.balance.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Amount input
                  Text(
                    'Amount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amount = double.tryParse(value) ?? 0;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Quick amount buttons
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAmountButton(
                          label: '25%',
                          onTap: () => _setAmount(widget.balance * 0.25),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuickAmountButton(
                          label: '50%',
                          onTap: () => _setAmount(widget.balance * 0.50),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuickAmountButton(
                          label: '75%',
                          onTap: () => _setAmount(widget.balance * 0.75),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuickAmountButton(
                          label: 'MAX',
                          onTap: () => _setAmount(widget.balance),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Recipient address
                  Text(
                    'Recipient Address',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _recipientController,
                    decoration: InputDecoration(
                      hintText: 'Solana address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null) {
                            _recipientController.text = data!.text!;
                          }
                        },
                        icon: PhosphorIcon(PhosphorIconsRegular.clipboard),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Fee breakdown
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Amount',
                              style: theme.textTheme.bodyLarge,
                            ),
                            Text(
                              '\$${_amount.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Platform Fee (1.25%)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '-\$${fee.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'You\'ll receive',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${netAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SafeArea(
              child: Column(
                children: [
                  AppButton.primary(
                    label: 'Withdraw',
                    onPressed: canWithdraw ? _withdraw : null,
                    expanded: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton.secondary(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                    expanded: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick amount button for percentage selection.
class _QuickAmountButton extends StatelessWidget {
  const _QuickAmountButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
