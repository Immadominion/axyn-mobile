import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/domain/entities/agent_listing.dart';

/// Banner with gradient and avatar
class AgentBannerSection extends StatelessWidget {
  const AgentBannerSection({
    required this.agent,
    required this.scheme,
    super.key,
  });

  final AgentListing agent;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner gradient
          Container(
            height: 120.h,
            margin: EdgeInsets.only(left: 24.h, right: 24.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary,
                  scheme.secondary,
                  scheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(-1, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),

          // Avatar positioned over banner
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.sm * -.1,
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/backgrounds/ic_launcher_bg.png',
                  ),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.surface,
                  width: 4,
                ),
              ),
              child: Image.asset('assets/images/icons/axyn-large.png'),
            ),
          ),
        ],
      ),
    );
  }
}
