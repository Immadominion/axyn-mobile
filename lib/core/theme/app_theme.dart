import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'color_schemes.dart';
import 'typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme => FlexThemeData.light(
        colorScheme: lightColorScheme,
        typography: Typography.material2021(platform: TargetPlatform.iOS),
        useMaterial3: true,
      ).copyWith(
        textTheme: AppTypography.textTheme(lightColorScheme),
      );

  static ThemeData get darkTheme => FlexThemeData.dark(
        colorScheme: darkColorScheme,
        typography: Typography.material2021(platform: TargetPlatform.iOS),
        useMaterial3: true,
      ).copyWith(
        textTheme: AppTypography.textTheme(darkColorScheme),
      );
}
