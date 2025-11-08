import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/core/router/routes.dart';
import 'package:axyn_mobile/core/services/onboarding_service.dart';
import 'package:axyn_mobile/shared/widgets/app_background.dart';
import 'package:axyn_mobile/shared/widgets/app_button.dart';

/// Onboarding carousel with 3 swipeable screens
class OnboardingCarousel extends ConsumerStatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  ConsumerState<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends ConsumerState<OnboardingCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed and navigate to authentication
      _completeOnboarding();
    }
  }

  void _skip() {
    // Mark onboarding as completed and navigate to authentication
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final onboardingService = ref.read(onboardingServiceProvider);
    await onboardingService.completeOnboarding();
    if (mounted) {
      context.go(AppRoutePaths.authentication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button

              if (_currentPage == 2)
                const SizedBox()
              else
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: scheme.onBackground.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              // Page view
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: const [
                    _OnboardingPage1(),
                    _OnboardingPage2(),
                    _OnboardingPage3(),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Next/Get Started button
              AppButton.primary(
                label: _currentPage == 2 ? 'Get Started' : 'Next',
                onPressed: _nextPage,
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6.h,
                    dotWidth: 6.w,
                    activeDotColor: scheme.primary,
                    dotColor: scheme.onBackground.withOpacity(0.2),
                    expansionFactor: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Screen 1: Accept Crypto Payments Easily
class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hero SVG
          Image.asset(
            'assets/images/onboarding-1.png',
            width: 280.w,
            height: 280.h,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            'Discover & hire AI agents for any task.',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: scheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}

// Screen 2: Track Inventory & Sales
class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hero SVG
          Image.asset(
            'assets/images/onboarding-2.png',
            width: 280.w,
            height: 280.h,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            'Pay-per-task, not per-month. Powered by x402.',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: scheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}

// Screen 3: Built on Solana
class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hero SVG
          Image.asset(
            'assets/images/onboarding-3.png',
            width: 280.w,
            height: 280.h,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            'Blazing speed, ultra-low fees. Built on Solana',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: scheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
