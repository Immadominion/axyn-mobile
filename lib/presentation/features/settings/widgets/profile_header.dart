import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Profile header showing avatar, name, and primary identity
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.displayName,
    this.avatarUrl,
    this.primaryIdentity,
    this.onEditTap,
    super.key,
  });

  final String displayName;
  final String? avatarUrl;
  final String? primaryIdentity;
  final VoidCallback? onEditTap;

  String _getInitial() => displayName.substring(0, 1).toUpperCase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 24.h,
      ),
      child: Row(
        children: [
          // Avatar with optional image
          Stack(
            children: [
              if (avatarUrl != null && avatarUrl!.isNotEmpty)
                CircleAvatar(
                  radius: 32.w,
                  backgroundImage: NetworkImage(avatarUrl!),
                  onBackgroundImageError: (_, __) {
                    // Fallback handled by next widget
                  },
                  child: Container(), // Empty to show background image
                )
              else
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary,
                        scheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getInitial(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 16.w),

          // Name and Identity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Edit button
                    if (onEditTap != null)
                      IconButton(
                        icon: PhosphorIcon(
                          PhosphorIconsRegular.notePencil,
                          color: scheme.scrim,
                          size: 22.sp,
                        ),
                        onPressed: onEditTap,
                      ),
                  ],
                ),
                if (primaryIdentity != null) ...[
                  Text(
                    primaryIdentity!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
