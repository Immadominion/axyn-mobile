import 'package:flutter/material.dart';

/// Semi-transparent noise texture overlay used across authentication surfaces.
class AppNoiseOverlay extends StatelessWidget {
  /// Creates a noise texture overlay with default AxyN branding asset.
  const AppNoiseOverlay({
    super.key,
    this.assetPath = 'assets/images/backgrounds/noise-texture4.JPG',
    this.opacity = 0.09,
  });

  /// Asset path for the noise texture image.
  final String assetPath;

  /// Overall opacity for the overlay image.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0, 1),
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
