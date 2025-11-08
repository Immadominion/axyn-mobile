import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/domain/entities/agent_listing.dart';

/// App bar for agent interaction page showing agent name and status
class InteractionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const InteractionAppBar({
    required this.agent,
    required this.onInfoTap,
    super.key,
  });

  final AgentListing agent;
  final VoidCallback onInfoTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppBar(
      backgroundColor: scheme.surface,
      leading: IconButton(
        icon: PhosphorIcon(
          PhosphorIconsRegular.arrowLeft,
          color: scheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agent.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: agent.isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                agent.isOnline ? 'Online' : 'Offline',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: PhosphorIcon(
            PhosphorIconsRegular.info,
            color: scheme.onSurface,
          ),
          onPressed: onInfoTap,
        ),
      ],
    );
  }
}
