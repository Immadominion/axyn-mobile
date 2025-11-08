import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigitPressed,
    this.onBackspace,
    this.onClear,
  });

  final ValueChanged<int> onDigitPressed;
  final VoidCallback? onBackspace;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    const List<List<int>> rows = <List<int>>[
      <int>[1, 2, 3],
      <int>[4, 5, 6],
      <int>[7, 8, 9],
    ];

    final theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = AppSpacing.md;
        final double maxWidth = constraints.maxWidth;
        final double keyWidth = (maxWidth - spacing * 2) / 3;

        return Column(
          children: [
            for (final row in rows) ...[
              Row(
                children: [
                  for (int i = 0; i < row.length; i++) ...[
                    _KeypadButton(
                      width: keyWidth,
                      label: '${row[i]}',
                      onTap: () => onDigitPressed(row[i]),
                      scheme: scheme,
                    ),
                    if (i != row.length - 1) SizedBox(width: spacing),
                  ],
                ],
              ),
              SizedBox(height: spacing),
            ],
            Row(
              children: [
                _KeypadButton(
                  width: keyWidth,
                  label: 'Clear',
                  onTap: onClear,
                  scheme: scheme,
                  emphasis: KeypadButtonEmphasis.subtle,
                ),
                SizedBox(width: spacing),
                _KeypadButton(
                  width: keyWidth,
                  label: '0',
                  onTap: () => onDigitPressed(0),
                  scheme: scheme,
                ),
                SizedBox(width: spacing),
                _KeypadButton(
                  width: keyWidth,
                  icon: PhosphorIconsFill.arrowLeft,
                  onTap: onBackspace,
                  scheme: scheme,
                  semanticsLabel: 'Delete',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

enum KeypadButtonEmphasis { standard, subtle }

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.width,
    required this.scheme,
    this.label,
    this.onTap,
    this.icon,
    this.semanticsLabel,
    this.emphasis = KeypadButtonEmphasis.standard,
  });

  final double width;
  final ColorScheme scheme;
  final String? label;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? semanticsLabel;
  final KeypadButtonEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color foreground = switch (emphasis) {
      KeypadButtonEmphasis.standard => scheme.onSurface,
      KeypadButtonEmphasis.subtle => scheme.onSurfaceVariant,
    };

    final Color background = switch (emphasis) {
      KeypadButtonEmphasis.standard => scheme.surfaceContainerHigh,
      KeypadButtonEmphasis.subtle => scheme.surfaceContainerHighest,
    };

    final Widget child;
    if (icon != null) {
      child = Icon(icon, size: 24, color: foreground);
    } else {
      child = Text(
        label ?? '',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      );
    }

    return SizedBox(
      width: width,
      child: Semantics(
        button: true,
        label: semanticsLabel ?? label,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Material(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: enabled ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                ),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
