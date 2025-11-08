import 'package:flutter/material.dart';

/// AxyN Brand Colors
/// - Primary: Mint (#89f8cb)
/// - Secondary: Lavender (#dac0ff)
/// - Accent: Light Blue (#a5dae0)

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  // Primary: Mint green (brand hero color)
  primary: Color(0xFF89F8CB),
  onPrimary: Color(0xFF003826),
  primaryContainer: Color(0xFFB3FCDB),
  onPrimaryContainer: Color(0xFF00210F),
  // Secondary: Lavender (brand accent)
  secondary: Color(0xFFDAC0FF),
  onSecondary: Color(0xFF3B1C63),
  secondaryContainer: Color(0xFFECDCFF),
  onSecondaryContainer: Color(0xFF230A42),
  // Tertiary: Light blue (brand secondary accent)
  tertiary: Color(0xFFA5DAE0),
  onTertiary: Color(0xFF003640),
  tertiaryContainer: Color(0xFFCAEFF5),
  onTertiaryContainer: Color(0xFF001F25),
  // Error states
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  // Backgrounds & surfaces
  background: Color(0xFFFAFDFB),
  onBackground: Color(0xFF191C1B),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF191C1B),
  surfaceVariant: Color(0xFFDFE3E1),
  onSurfaceVariant: Color(0xFF424947),
  // Outlines & dividers
  outline: Color(0xFF727975),
  outlineVariant: Color(0xFFC2C7C5),
  shadow: Colors.black,
  scrim: Colors.black,
  // Inverse colors
  inverseSurface: Color(0xFF2E312F),
  onInverseSurface: Color(0xFFEFF1EF),
  inversePrimary: Color(0xFF89F8CB),
  surfaceTint: Color(0xFF89F8CB),
);

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  // Primary: Mint green (glows in dark mode)
  primary: Color(0xFF89F8CB),
  onPrimary: Color(0xFF003826),
  primaryContainer: Color(0xFF005236),
  onPrimaryContainer: Color(0xFFB3FCDB),
  // Secondary: Lavender (softer in dark)
  secondary: Color(0xFFDAC0FF),
  onSecondary: Color(0xFF3B1C63),
  secondaryContainer: Color(0xFF532E7B),
  onSecondaryContainer: Color(0xFFECDCFF),
  // Tertiary: Light blue (cooler tone)
  tertiary: Color(0xFFA5DAE0),
  onTertiary: Color(0xFF003640),
  tertiaryContainer: Color(0xFF004F5B),
  onTertiaryContainer: Color(0xFFCAEFF5),
  // Error states
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  // Backgrounds & surfaces (true black for OLED)
  background: Color(0xFF000000),
  onBackground: Color(0xFFE1E3E1),
  surface: Color(0xFF0A0A0A),
  onSurface: Color(0xFFE1E3E1),
  surfaceVariant: Color(0xFF3F4947),
  onSurfaceVariant: Color(0xFFBFC9C5),
  // Outlines & dividers
  outline: Color(0xFF899390),
  outlineVariant: Color(0xFF3F4947),
  shadow: Colors.black,
  scrim: Colors.black,
  // Inverse colors
  inverseSurface: Color(0xFFE1E3E1),
  onInverseSurface: Color(0xFF2E312F),
  inversePrimary: Color(0xFF006C47),
  surfaceTint: Color(0xFF89F8CB),
);
