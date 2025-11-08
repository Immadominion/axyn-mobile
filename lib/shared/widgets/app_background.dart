import 'package:flutter/material.dart';

/// Reusable background gradient for AxyN app screens
///
/// Provides consistent brand gradient (mint → lavender) across all screens.
/// Use this as the primary background decoration for a cohesive visual identity.
///
/// Example:
/// ```dart
/// Scaffold(
///   body: AppBackground(
///     child: YourContent(),
///   ),
/// )
/// ```
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.intensity = 0.28,
  });

  final Widget child;

  /// Gradient opacity intensity (0.0 to 1.0)
  /// - Light mode: 0.16 (subtle)
  /// - Dark mode: 0.28 (more prominent)
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.primary.withOpacity(isDark ? intensity : intensity * 0.6),
            scheme.background,
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Static gradient definitions for reuse across the app
class AppGradients {
  AppGradients._();

  /// Primary brand gradient: Mint → Lavender
  static const LinearGradient mintToLavender = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF89F8CB), // Mint
      Color(0xFFDAC0FF), // Lavender
    ],
  );

  /// Alternative gradient: Mint → Light Blue
  static const LinearGradient mintToLightBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF89F8CB), // Mint
      Color(0xFFA5DAE0), // Light Blue
    ],
  );

  /// Cooler gradient: Lavender → Light Blue
  static const LinearGradient lavenderToLightBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFDAC0FF), // Lavender
      Color(0xFFA5DAE0), // Light Blue
    ],
  );

  /// Dark mode mint glow
  static LinearGradient mintGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF89F8CB).withOpacity(0.3),
      const Color(0xFF89F8CB).withOpacity(0.05),
    ],
  );

  /// Dark mode lavender glow
  static LinearGradient lavenderGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFDAC0FF).withOpacity(0.3),
      const Color(0xFFDAC0FF).withOpacity(0.05),
    ],
  );

  /// Full spectrum brand gradient
  static const LinearGradient brandSpectrum = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF89F8CB), // Mint
      Color(0xFFDAC0FF), // Lavender
      Color(0xFFA5DAE0), // Light Blue
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
