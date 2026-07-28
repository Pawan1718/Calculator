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
  State<CalculatorButton> createState() {
    return _CalculatorButtonState();
  }
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _isPressed = false;

  Color _backgroundColor(BuildContext context) {
    if (widget.isSelected) {
      return AppTheme.primaryText(context);
    }

    switch (widget.type) {
      case CalculatorButtonType.function:
        return AppTheme.functionButton(context);

      case CalculatorButtonType.operator:
      case CalculatorButtonType.equal:
        return AppTheme.primaryColor;

      case CalculatorButtonType.number:
        return AppTheme.numberButton(context);
    }
  }

  Color _foregroundColor(BuildContext context) {
    if (widget.isSelected) {
      return AppTheme.primaryColor;
    }

    switch (widget.type) {
      case CalculatorButtonType.operator:
      case CalculatorButtonType.equal:
        return const Color(0xFF07150F);

      case CalculatorButtonType.function:
      case CalculatorButtonType.number:
        return AppTheme.primaryText(context);
    }
  }

  double get _fontSize {
    return widget.label.length > 2 ? 19 : 27;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _backgroundColor(context);
    final foregroundColor = _foregroundColor(context);

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
              color: backgroundColor,
              borderRadius: BorderRadius.circular(
                AppConstants.buttonBorderRadius,
              ),
              border: AppTheme.isDark(context)
                  ? null
                  : Border.all(color: Colors.black.withValues(alpha: 0.04)),
              boxShadow: [
                if (widget.type == CalculatorButtonType.equal)
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  )
                else if (!AppTheme.isDark(context))
                  BoxShadow(
                    color: AppTheme.buttonShadow(context),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
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
                      ? Icon(widget.icon, size: 27, color: foregroundColor)
                      : Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontWeight: FontWeight.w600,
                            color: foregroundColor,
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
