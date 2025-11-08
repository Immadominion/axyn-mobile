import 'package:axyn_mobile/shared/widgets/compact_stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:axyn_mobile/application/account/user_profile_provider.dart';
import 'package:axyn_mobile/application/app_settings/theme_controller.dart';
import 'package:axyn_mobile/application/auth/session_controller.dart';
import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/core/router/routes.dart';
import 'package:axyn_mobile/presentation/features/main_app/controller/main_tab_index_controller.dart';
import 'package:axyn_mobile/presentation/features/settings/widgets/profile_header.dart';
import 'package:axyn_mobile/presentation/features/settings/widgets/settings_section_header.dart';
import 'package:axyn_mobile/presentation/features/settings/widgets/settings_tile.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// PROFILE tab - User profile and settings.
///
/// Features:
/// - User profile header (avatar, name, email, wallet)
/// - Stats overview (hired agents, total spent, member since)
/// - Become an Agent Provider link
/// - Settings sections (preferences, security, support, legal)
/// - App version and logout
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return profileAsync.when(
      data: (profile) {
        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              // Profile Header with back button
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg.w,
                        AppSpacing.lg.h,
                        AppSpacing.lg.w,
                        AppSpacing.md.h,
                      ),
                      child: Text(
                        'Profile Settings',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                    // Profile info
                    ProfileHeader(
                      displayName: profile.displayName,
                      avatarUrl: profile.avatarUrl,
                      primaryIdentity: profile.primaryIdentity,
                      onEditTap: () {
                        context.push(AppRoutePaths.editProfile);
                      },
                    ),

                    // Stats row
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CompactStat(
                            value: profile.totalAgentsHired.toString(),
                            label: 'Agents Hired',
                            scheme: scheme,
                            theme: theme,
                          ),
                          Container(
                            width: 1.w,
                            height: 24.h,
                            color: scheme.outline.withValues(alpha: 0.2),
                          ),
                          CompactStat(
                            value: '\$${profile.totalSpent.toStringAsFixed(2)}',
                            label: 'Total Spent',
                            scheme: scheme,
                            theme: theme,
                          ),
                          Container(
                            width: 1.w,
                            height: 24.h,
                            color: scheme.outline.withValues(alpha: 0.2),
                          ),
                          CompactStat(
                            value: profile.memberDuration.toString(),
                            label: 'Member',
                            scheme: scheme,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Settings List - Clean style without containers
              SliverList(
                delegate: SliverChildListDelegate([
                  // Wallet Section
                  SettingsTile(
                    icon: PhosphorIconsRegular.wallet,
                    title: 'Wallet',
                    onTap: () {
                      // TODO: Navigate to wallet details
                    },
                  ),

                  // Notification
                  SettingsTile(
                    icon: PhosphorIconsRegular.bell,
                    title: 'Notification',
                    onTap: () {
                      // TODO: Navigate to notification settings
                    },
                  ),

                  // Security
                  SettingsTile(
                    icon: PhosphorIconsRegular.shieldCheck,
                    title: 'Security',
                    onTap: () {
                      // TODO: Navigate to security settings
                    },
                  ),

                  // Language
                  SettingsTile(
                    icon: PhosphorIconsRegular.globe,
                    title: 'Language',
                    value: 'English (US)',
                    onTap: () {
                      // TODO: Show language selector
                    },
                  ),

                  // Dark Mode with toggle
                  SettingsTile(
                    icon: PhosphorIconsRegular.moon,
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: ref.watch(themeModeProvider) == ThemeMode.dark,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light,
                            );
                      },
                    ),
                  ),

                  // Help Center
                  SettingsTile(
                    icon: PhosphorIconsRegular.question,
                    title: 'Help Center',
                    onTap: () {
                      // TODO: Open help center
                    },
                  ),

                  // Invite Friends
                  SettingsTile(
                    icon: PhosphorIconsRegular.users,
                    title: 'Invite Friends',
                    onTap: () {
                      // TODO: Open invite flow
                    },
                  ),

                  // Rate us
                  SettingsTile(
                    icon: PhosphorIconsRegular.star,
                    title: 'Rate us',
                    onTap: () {
                      // TODO: Open app store rating
                    },
                  ),

                  // About Section Header
                  const SettingsSectionHeader(title: 'About'),

                  // Privacy & Policy
                  SettingsTile(
                    icon: PhosphorIconsRegular.keyhole,
                    title: 'Privacy & Policy',
                    onTap: () {
                      // TODO: Open privacy policy
                    },
                  ),

                  // Terms of Service
                  SettingsTile(
                    icon: PhosphorIconsRegular.fileText,
                    title: 'Terms of Services',
                    onTap: () {
                      // TODO: Open terms of service
                    },
                  ),

                  // About us
                  SettingsTile(
                    icon: PhosphorIconsRegular.info,
                    title: 'About us',
                    onTap: () {
                      // TODO: Open about page
                    },
                  ),

                  // Sign Out Section Header
                  const SettingsSectionHeader(title: 'Account'),

                  // Sign Out
                  SettingsTile(
                    icon: PhosphorIconsRegular.signOut,
                    title: 'Sign Out',
                    iconColor: theme.colorScheme.error,
                    titleColor: theme.colorScheme.error,
                    onTap: () => _showSignOutDialog(context, ref),
                  ),

                  // Bottom spacing for nav bar
                  SizedBox(height: 96.h),
                ]),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const Center(
        child: Text('Unable to load profile'),
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              PhosphorIconsRegular.signOut,
              color: scheme.error,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Sign Out',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out? You will need to sign in again to access your account.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: scheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: scheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      // Show loading indicator
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: scheme.primary),
                SizedBox(height: 16.h),
                Text(
                  'Signing out...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );

      try {
        // Clear session (this logs out from Privy and clears JWT)
        await ref
            .read(sessionControllerProvider.notifier)
            .clearPersistedSession(shouldLogout: true);

        // Invalidate user profile provider to clear cached data
        ref.invalidate(userProfileProvider);

        // Reset main tab index so user returns to Discover on next login
        ref.invalidate(mainTabIndexProvider);

        if (context.mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          // Use go to clear navigation stack and force router redirect
          // The router will detect unauthenticated state and redirect to auth
          context.go(AppRoutePaths.authentication);
        }
      } catch (e) {
        if (context.mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: $e'),
              backgroundColor: scheme.error,
            ),
          );
        }
      }
    }
  }
}
