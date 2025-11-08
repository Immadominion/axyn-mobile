import 'package:flutter/material.dart';

class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color background = selected
        ? scheme.primary
        : scheme.surfaceContainerHighest.withValues(alpha: 0.72);
    final Color foreground =
        selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 16 : 18, color: foreground),
            SizedBox(width: compact ? 6 : 8),
          ],
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      showCheckmark: false,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 6 : 10,
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? background
              : scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      backgroundColor: background,
      selectedColor: background,
      pressElevation: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
