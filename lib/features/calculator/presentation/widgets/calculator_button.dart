import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

enum CalculatorButtonType { number, function, operator, equal }

class CalculatorButton extends StatefulWidget {
  const CalculatorButton({
    required this.label,
    required this.onPressed,
    this.type = CalculatorButtonType.number,
    this.flex = 1,
    this.icon,
    this.isSelected = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final CalculatorButtonType type;
  final int flex;
  final IconData? icon;
  final bool isSelected;

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    if (widget.isSelected) {
      return AppTheme.primaryTextColor;
    }

    switch (widget.type) {
      case CalculatorButtonType.function:
        return AppTheme.functionButtonColor;

      case CalculatorButtonType.operator:
      case CalculatorButtonType.equal:
        return AppTheme.operatorButtonColor;

      case CalculatorButtonType.number:
        return AppTheme.numberButtonColor;
    }
  }

  Color get _foregroundColor {
    if (widget.isSelected) {
      return AppTheme.primaryColor;
    }

    switch (widget.type) {
      case CalculatorButtonType.operator:
      case CalculatorButtonType.equal:
        return const Color(0xFF07150F);

      case CalculatorButtonType.function:
      case CalculatorButtonType.number:
        return AppTheme.primaryTextColor;
    }
  }

  double get _fontSize {
    return widget.label.length > 2 ? 19 : 27;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Semantics(
        button: true,
        selected: widget.isSelected,
        label: widget.label,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(
                AppConstants.buttonBorderRadius,
              ),
              boxShadow: widget.type == CalculatorButtonType.equal
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) {
                  setState(() {
                    _isPressed = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _isPressed = false;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _isPressed = false;
                  });
                },
                child: Center(
                  child: widget.icon != null
                      ? Icon(widget.icon, size: 27, color: _foregroundColor)
                      : Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontWeight: FontWeight.w600,
                            color: _foregroundColor,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
