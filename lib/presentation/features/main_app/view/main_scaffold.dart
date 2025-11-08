import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../shared/widgets/app_background.dart';
import '../../activity/view/activity_page.dart';
import '../../agents/view/agents_page.dart';
import '../../home/view/home_page.dart';
import '../../settings/view/settings_page.dart';
import '../controller/main_tab_index_controller.dart';

/// Main scaffold with floating bottom navigation for AxyN.
///
/// Implements bottom tab navigation with 4 tabs:
/// - DISCOVER - Browse and search AI agents marketplace
/// - MY AGENTS - View hired agents and quick access
/// - ACTIVITY - Transaction history and agent interactions
/// - PROFILE - Wallet, settings, and agent registration
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainTabIndexProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Tab screens
    final screens = [
      const HomePage(), // DISCOVER (Marketplace)
      const FundsPage(), // MY AGENTS (Hired agents) - TODO: Rename to MyAgentsPage
      const InventoryPage(), // ACTIVITY (History) - TODO: Rename to ActivityPage
      const SettingsPage(), // PROFILE
    ];

    return Scaffold(
      extendBody: true,
      body: AppBackground(
        child: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(16.sp, 0, 16.sp, 0.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.surface.withValues(alpha: 0.8),
                      scheme.surface.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32.r),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.1),
                    width: 1.53.r,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    ref.read(mainTabIndexProvider.notifier).setIndex(index);
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: Colors.transparent,
                  indicatorShape: const CircleBorder(),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final color = states.contains(WidgetState.selected)
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.6);
                    return theme.textTheme.labelMedium!
                        .copyWith(color: color, fontWeight: FontWeight.w600);
                  }),
                  height: 64.h,
                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return scheme.primary.withValues(alpha: 0.1);
                    }
                    return null;
                  }),
                  destinations: [
                    NavigationDestination(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.house,
                      ),
                      selectedIcon: PhosphorIcon(PhosphorIconsFill.house,
                          color: scheme.onSurface),
                      label: 'DISCOVER',
                    ),
                    NavigationDestination(
                      icon: const PhosphorIcon(PhosphorIconsRegular.sparkle),
                      selectedIcon: PhosphorIcon(PhosphorIconsFill.sparkle,
                          color: scheme.onSurface),
                      label: 'MY AGENTS',
                    ),
                    NavigationDestination(
                      icon: const PhosphorIcon(
                          PhosphorIconsRegular.clockCounterClockwise),
                      selectedIcon: PhosphorIcon(
                          PhosphorIconsFill.clockCounterClockwise,
                          color: scheme.onSurface),
                      label: 'ACTIVITY',
                    ),
                    NavigationDestination(
                      icon: const PhosphorIcon(PhosphorIconsRegular.userCircle),
                      selectedIcon: PhosphorIcon(
                        PhosphorIconsFill.userCircle,
                        color: scheme.onSurface,
                      ),
                      label: 'PROFILE',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
