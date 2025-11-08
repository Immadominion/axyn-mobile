import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/core/utils/currency_formatter.dart';

/// Amount input section with manual entry and quick presets.
///
/// Features:
/// - Large amount display
/// - Manual text input (tappable to edit)
/// - Quick amount presets ($5, $10, $20, $50, $100)
/// - Clear button
class AmountInputSection extends StatefulWidget {
  const AmountInputSection({
    super.key,
    required this.amountCents,
    required this.onAmountChanged,
    required this.focusNode,
  });

  final int amountCents;
  final ValueChanged<int> onAmountChanged;
  final FocusNode focusNode;

  @override
  State<AmountInputSection> createState() => _AmountInputSectionState();
}

class _AmountInputSectionState extends State<AmountInputSection> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(AmountInputSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amountCents != widget.amountCents && !_isEditing) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final dollars = widget.amountCents / 100;
    _controller.text = dollars == 0 ? '' : dollars.toStringAsFixed(2);
  }

  void _handleAmountSubmit() {
    setState(() => _isEditing = false);

    final text = _controller.text.trim();
    if (text.isEmpty) {
      widget.onAmountChanged(0);
      return;
    }

    final double? value = double.tryParse(text);
    if (value != null && value >= 0) {
      final cents = (value * 100).round();
      widget.onAmountChanged(cents);
    } else {
      _updateControllerText();
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
    final amount = widget.amountCents / 100;

    return Column(
      children: [
        // Amount display / input
        GestureDetector(
          onTap: () {
            setState(() => _isEditing = true);
            widget.focusNode.requestFocus();
            _controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controller.text.length,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isEditing)
                Flexible(
                  child: Text(
                    CurrencyFormatter.usd(amount),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: amount > 0
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Flexible(
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: _controller,
                      focusNode: widget.focusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: widget.focusNode.hasFocus ? '' : '\$0.00',
                        hintStyle: theme.textTheme.displayMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.3),
                          fontWeight: FontWeight.bold,
                        ),
                        prefixText: '\$',
                        prefixStyle: theme.textTheme.displayMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSubmitted: (_) => _handleAmountSubmit(),
                    ),
                  ),
                ),
              if (amount > 0 && !_isEditing) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.x,
                    size: 24,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () => widget.onAmountChanged(0),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
