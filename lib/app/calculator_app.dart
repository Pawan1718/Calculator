import 'package:flutter/material.dart';

import '../features/calculator/presentation/screens/calculator_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();

    _themeController = ThemeController();
    _themeController.addListener(_onThemeChanged);
    _themeController.loadThemeMode();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _themeController.removeListener(_onThemeChanged);
    _themeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitmint Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeController.themeMode,
      home: CalculatorScreen(themeController: _themeController),
    );
  }
}
