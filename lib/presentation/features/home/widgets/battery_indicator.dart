import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Battery indicator widget with dynamic icon based on balance.
///
/// Shows different battery levels and colors based on USDC balance thresholds.
/// Designed for x402 micropayment economy where API calls cost 0.001-0.01 USDC.
class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({
    required this.balance,
    required this.scheme,
    this.size = 24,
    super.key,
  });

  final double balance;
  final ColorScheme scheme;
  final double size;

  // Balance thresholds based on x402 pricing research:
  // - Most calls cost 0.001-0.01 USDC
  // - $5 = 500-5000 calls (full battery)
  // - $1 = 100-1000 calls (good)
  // - $0.10 = 10-100 calls (low)
  // - $10+ = Power user (gold)
  static const double _powerUserThreshold = 10.0;
  static const double _fullThreshold = 5.0;
  static const double _highThreshold = 2.0;
  static const double _mediumThreshold = 1.0;
  static const double _lowThreshold = 0.10;

  PhosphorIconData _getBatteryIcon() {
    if (balance >= _fullThreshold) {
      return PhosphorIconsBold.batteryVerticalFull;
    } else if (balance >= _highThreshold) {
      return PhosphorIconsBold.batteryVerticalHigh;
    } else if (balance >= _mediumThreshold) {
      return PhosphorIconsBold.batteryVerticalMedium;
    } else if (balance >= _lowThreshold) {
      return PhosphorIconsBold.batteryVerticalLow;
    } else {
      return PhosphorIconsBold.batteryVerticalEmpty;
    }
  }

  Color _getBatteryColor() {
    if (balance >= _powerUserThreshold) {
      return const Color(0xFFFFD700); // Gold for power users
    } else if (balance >= _fullThreshold) {
      return const Color(0xFF4CAF50); // Green - full
    } else if (balance >= _mediumThreshold) {
      return scheme.primary; // Primary color - good
    } else if (balance >= _lowThreshold) {
      return const Color(0xFFFF9800); // Orange - low
    } else {
      return const Color(0xFFF44336); // Red - critical
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhosphorIcon(
      _getBatteryIcon(),
      size: size.sp,
      color: _getBatteryColor(),
    );
  }
}
