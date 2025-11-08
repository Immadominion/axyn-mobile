import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../domain/models/agent_type.dart';

/// Expandable agent type selector widget
/// Similar to NetworkSelector pattern but for agent types
class AgentTypeSelector extends StatefulWidget {
  const AgentTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
    super.key,
  });

  final AgentType? selectedType;
  final ValueChanged<AgentType> onTypeSelected;

  @override
  State<AgentTypeSelector> createState() => _AgentTypeSelectorState();
}

class _AgentTypeSelectorState extends State<AgentTypeSelector> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current selection display
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _isExpanded ? scheme.primary : scheme.outlineVariant,
                width: _isExpanded ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForType(widget.selectedType),
                  color: scheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedType?.label ?? 'Select Agent Type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.selectedType != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          widget.selectedType!.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  _isExpanded
                      ? PhosphorIconsRegular.caretUp
                      : PhosphorIconsRegular.caretDown,
                  color: scheme.onSurfaceVariant,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),

        // Expanded options
        if (_isExpanded) ...[
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: AgentType.values.map((type) {
                final isSelected = widget.selectedType == type;
                return InkWell(
                  onTap: () {
                    widget.onTypeSelected(type);
                    setState(() => _isExpanded = false);
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? scheme.primaryContainer.withValues(alpha: 0.3)
                          : null,
                      border: Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForType(type),
                          color: isSelected
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.label,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isSelected
                                      ? scheme.primary
                                      : scheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                type.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            PhosphorIconsFill.checkCircle,
                            color: scheme.primary,
                            size: 20.sp,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getIconForType(AgentType? type) {
    if (type == null) return PhosphorIconsRegular.robot;

    switch (type) {
      case AgentType.chat:
        return PhosphorIconsRegular.chatsCircle;
      case AgentType.audio:
        return PhosphorIconsRegular.waveform;
      case AgentType.image:
        return PhosphorIconsRegular.image;
      case AgentType.video:
        return PhosphorIconsRegular.videoCamera;
      case AgentType.data:
        return PhosphorIconsRegular.database;
    }
  }
}
