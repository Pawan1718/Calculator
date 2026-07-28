import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF00D084);

  static const Color darkBackgroundColor = Color(0xFF0F1115);
  static const Color darkSurfaceColor = Color(0xFF191C22);
  static const Color darkNumberButtonColor = Color(0xFF24272E);
  static const Color darkFunctionButtonColor = Color(0xFF343840);
  static const Color darkPrimaryTextColor = Color(0xFFF7F8FA);
  static const Color darkSecondaryTextColor = Color(0xFF9DA3AE);

  static const Color lightBackgroundColor = Color(0xFFF4F6F8);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightNumberButtonColor = Color(0xFFFFFFFF);
  static const Color lightFunctionButtonColor = Color(0xFFE3E7EA);
  static const Color lightPrimaryTextColor = Color(0xFF15181C);
  static const Color lightSecondaryTextColor = Color(0xFF687078);

  // Backward-compatible dark values.
  static const Color backgroundColor = darkBackgroundColor;
  static const Color surfaceColor = darkSurfaceColor;
  static const Color numberButtonColor = darkNumberButtonColor;
  static const Color functionButtonColor = darkFunctionButtonColor;
  static const Color operatorButtonColor = primaryColor;
  static const Color primaryTextColor = darkPrimaryTextColor;
  static const Color secondaryTextColor = darkSecondaryTextColor;

  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      surface: darkSurfaceColor,
      error: Color(0xFFFF6B6B),
      onPrimary: Color(0xFF07150F),
      onSecondary: Color(0xFF07150F),
      onSurface: darkPrimaryTextColor,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      splashFactory: InkRipple.splashFactory,
      iconTheme: const IconThemeData(color: darkPrimaryTextColor),
      dividerColor: const Color(0xFF2A2E35),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkSurfaceColor,
        contentTextStyle: TextStyle(color: darkPrimaryTextColor),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurfaceColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      surface: lightSurfaceColor,
      error: Color(0xFFD32F2F),
      onPrimary: Color(0xFF07150F),
      onSecondary: Color(0xFF07150F),
      onSurface: lightPrimaryTextColor,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackgroundColor,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      splashFactory: InkRipple.splashFactory,
      iconTheme: const IconThemeData(color: lightPrimaryTextColor),
      dividerColor: const Color(0xFFDDE1E5),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: lightPrimaryTextColor,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurfaceColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
    );
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color background(BuildContext context) {
    return isDark(context) ? darkBackgroundColor : lightBackgroundColor;
  }

  static Color surface(BuildContext context) {
    return isDark(context) ? darkSurfaceColor : lightSurfaceColor;
  }

  static Color numberButton(BuildContext context) {
    return isDark(context) ? darkNumberButtonColor : lightNumberButtonColor;
  }

  static Color functionButton(BuildContext context) {
    return isDark(context) ? darkFunctionButtonColor : lightFunctionButtonColor;
  }

  static Color primaryText(BuildContext context) {
    return isDark(context) ? darkPrimaryTextColor : lightPrimaryTextColor;
  }

  static Color secondaryText(BuildContext context) {
    return isDark(context) ? darkSecondaryTextColor : lightSecondaryTextColor;
  }

  static Color buttonShadow(BuildContext context) {
    return isDark(context)
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.08);
  }
}
