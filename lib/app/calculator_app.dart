import 'package:flutter/material.dart';

import '../features/calculator/presentation/screens/calculator_screen.dart';
import 'theme/app_theme.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitmint Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const CalculatorScreen(),
    );
  }
}
