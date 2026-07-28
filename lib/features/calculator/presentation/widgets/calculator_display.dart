import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    required this.expression,
    required this.result,
    this.hasError = false,
    super.key,
  });

  final String expression;
  final String result;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resultFontSize = constraints.maxWidth < 350 ? 48.0 : 60.0;
        final expressionFontSize = constraints.maxWidth < 350 ? 19.0 : 23.0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 22),
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: double.infinity,
                height: 38,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      expression.isEmpty ? ' ' : expression,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: expressionFontSize,
                        fontWeight: FontWeight.w400,
                        color: hasError
                            ? Colors.redAccent
                            : AppTheme.secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.97,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: FittedBox(
                    key: ValueKey(result),
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      result,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: resultFontSize,
                        fontWeight: FontWeight.w600,
                        color: hasError
                            ? Colors.redAccent
                            : AppTheme.primaryTextColor,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
