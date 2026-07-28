import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF00D084);
  static const Color backgroundColor = Color(0xFF0F1115);
  static const Color surfaceColor = Color(0xFF191C22);
  static const Color numberButtonColor = Color(0xFF24272E);
  static const Color functionButtonColor = Color(0xFF343840);
  static const Color operatorButtonColor = primaryColor;
  static const Color primaryTextColor = Color(0xFFF7F8FA);
  static const Color secondaryTextColor = Color(0xFF9DA3AE);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceColor,
        onPrimary: Color(0xFF07150F),
        onSurface: primaryTextColor,
      ),
      fontFamily: 'Roboto',
      splashFactory: InkRipple.splashFactory,
    );
  }
}
