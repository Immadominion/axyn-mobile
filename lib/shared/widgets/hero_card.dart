import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axyn_mobile/core/constants/app_sizes.dart';

/// A premium card widget with gradient background and optional glass morphism effect.
///
/// Designed for hero sections that need to stand out with AxyN brand gradients.
/// Supports:
/// - Linear gradients (mint → lavender, custom colors)
/// - Glass morphism (frosted glass effect)
/// - Configurable padding, radius, and shadows
///
/// **Usage:**
/// ```dart
/// HeroCard(
///   gradient: HeroGradients.mintToLavender,
///   child: Text('Balance: \$1,234'),
/// )
/// ```
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.borderRadius = AppRadius.lg,
    this.glassEffect = false,
    this.glassOpacity = 0.1,
    this.elevation = 0,
    this.onTap,
  }) : assert(
          gradient != null || backgroundColor != null,
          'Either gradient or backgroundColor must be provided',
        );

  /// Content to display inside the card
  final Widget child;

  /// Gradient for the card background (overrides backgroundColor)
  final Gradient? gradient;

  /// Solid background color (used if gradient is null)
  final Color? backgroundColor;

  /// Internal padding
  final EdgeInsetsGeometry padding;

  /// Corner radius
  final double borderRadius;

  /// Enable frosted glass overlay effect
  final bool glassEffect;

  /// Glass effect opacity (0.0 - 1.0)
  final double glassOpacity;

  /// Shadow elevation
  final double elevation;

  /// Optional tap callback
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget card = Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.12),
                  blurRadius: elevation * 4,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Base content
            Padding(
              padding: padding,
              child: child,
            ),

            // Glass morphism overlay
            if (glassEffect)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: glassOpacity),
                          Colors.white.withValues(alpha: glassOpacity * 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Pre-defined gradient combinations for AxyN brand
class HeroGradients {
  HeroGradients._();

  /// Mint → Lavender (primary brand gradient)
  static const LinearGradient mintToLavender = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF89F8CB), // Mint
      Color(0xFFDAC0FF), // Lavender
    ],
  );

  /// Mint → Light Blue (alternative gradient)
  static const LinearGradient mintToLightBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF89F8CB), // Mint
      Color(0xFFA5DAE0), // Light Blue
    ],
  );

  /// Lavender → Light Blue (cooler gradient)
  static const LinearGradient lavenderToLightBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFDAC0FF), // Lavender
      Color(0xFFA5DAE0), // Light Blue
    ],
  );

  /// Dark mode: Mint glow (subtle gradient for dark backgrounds)
  static const LinearGradient mintGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF005236), // Dark mint
      Color(0xFF003826), // Darker mint
    ],
  );

  /// Dark mode: Lavender glow
  static const LinearGradient lavenderGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF532E7B), // Dark lavender
      Color(0xFF3B1C63), // Darker lavender
    ],
  );

  /// Multi-stop gradient (all brand colors)
  static const LinearGradient brandSpectrum = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF89F8CB), // Mint
      Color(0xFFA5DAE0), // Light Blue
      Color(0xFFDAC0FF), // Lavender
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
