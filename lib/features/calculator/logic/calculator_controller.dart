import 'package:flutter/foundation.dart';

import '../models/calculation_history.dart';

class CalculatorController extends ChangeNotifier {
  String _displayValue = '0';
  String _expression = '';

  double? _firstOperand;
  double? _lastSecondOperand;

  String? _operator;
  String? _lastOperator;

  bool _shouldResetDisplay = false;
  bool _hasError = false;

  final List<CalculationHistory> _history = [];

  String get displayValue => _displayValue;
  String get expression => _expression;
  String? get selectedOperator => _operator;
  bool get hasError => _hasError;

  List<CalculationHistory> get history => List.unmodifiable(_history.reversed);

  void onButtonPressed(String value) {
    if (_hasError && value != 'AC') {
      clear(notify: false);
    }

    if (_isDigit(value)) {
      inputDigit(value);
      return;
    }

    switch (value) {
      case '.':
        inputDecimal();
        break;

      case '+':
      case '−':
      case '×':
      case '÷':
        inputOperator(value);
        break;

      case '=':
        calculateResult();
        break;

      case '%':
        calculatePercentage();
        break;

      case '+/-':
        toggleSign();
        break;

      case 'DELETE':
        deleteLastCharacter();
        break;

      case 'AC':
        clear();
        break;
    }
  }

  void inputDigit(String digit) {
    if (_shouldResetDisplay || _displayValue == '0') {
      _displayValue = digit;
      _shouldResetDisplay = false;
    } else if (_displayValue == '-0') {
      _displayValue = '-$digit';
    } else if (_displayValue.replaceAll('-', '').length < 16) {
      _displayValue += digit;
    }

    _updateExpressionPreview();
    notifyListeners();
  }

  void inputDecimal() {
    if (_shouldResetDisplay) {
      _displayValue = '0.';
      _shouldResetDisplay = false;
    } else if (!_displayValue.contains('.')) {
      _displayValue += '.';
    }

    _updateExpressionPreview();
    notifyListeners();
  }

  void toggleSign() {
    if (_hasError || _displayValue == '0') {
      return;
    }

    if (_displayValue.startsWith('-')) {
      _displayValue = _displayValue.substring(1);
    } else {
      _displayValue = '-$_displayValue';
    }

    _updateExpressionPreview();
    notifyListeners();
  }

  void inputOperator(String newOperator) {
    final currentValue = double.tryParse(_displayValue);

    if (currentValue == null) {
      return;
    }

    // Operator change before entering second number.
    if (_operator != null && _shouldResetDisplay) {
      _operator = newOperator;
      _expression = '${_formatNumber(_firstOperand!)} $newOperator';

      notifyListeners();
      return;
    }

    // Continuous operation.
    if (_operator != null && _firstOperand != null) {
      final calculatedValue = _performCalculation(
        _firstOperand!,
        currentValue,
        _operator!,
      );

      if (calculatedValue == null) {
        _setError();
        return;
      }

      _firstOperand = calculatedValue;
      _displayValue = _formatNumber(calculatedValue);
    } else {
      _firstOperand = currentValue;
    }

    _operator = newOperator;
    _lastOperator = null;
    _lastSecondOperand = null;

    _shouldResetDisplay = true;
    _expression = '${_formatNumber(_firstOperand!)} $newOperator';

    notifyListeners();
  }

  void calculateResult() {
    if (_firstOperand != null && _operator != null) {
      final secondOperand = double.tryParse(_displayValue);

      if (secondOperand == null) {
        return;
      }

      _calculateAndStore(
        firstOperand: _firstOperand!,
        secondOperand: secondOperand,
        operator: _operator!,
      );

      return;
    }

    // Repeat last equals operation.
    if (_lastOperator != null && _lastSecondOperand != null) {
      final currentValue = double.tryParse(_displayValue);

      if (currentValue == null) {
        return;
      }

      _calculateAndStore(
        firstOperand: currentValue,
        secondOperand: _lastSecondOperand!,
        operator: _lastOperator!,
      );
    }
  }

  void _calculateAndStore({
    required double firstOperand,
    required double secondOperand,
    required String operator,
  }) {
    final result = _performCalculation(firstOperand, secondOperand, operator);

    if (result == null) {
      _setError();
      return;
    }

    final completedExpression =
        '${_formatNumber(firstOperand)} '
        '$operator '
        '${_formatNumber(secondOperand)} =';

    final formattedResult = _formatNumber(result);

    _expression = completedExpression;
    _displayValue = formattedResult;

    _history.add(
      CalculationHistory(
        expression: completedExpression,
        result: formattedResult,
        createdAt: DateTime.now(),
      ),
    );

    if (_history.length > 50) {
      _history.removeAt(0);
    }

    _lastOperator = operator;
    _lastSecondOperand = secondOperand;

    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = true;

    notifyListeners();
  }

  void calculatePercentage() {
    final currentValue = double.tryParse(_displayValue);

    if (currentValue == null) {
      return;
    }

    double percentageValue;

    if (_firstOperand != null && _operator != null) {
      switch (_operator) {
        case '+':
        case '−':
          percentageValue = _firstOperand! * currentValue / 100;
          break;

        case '×':
        case '÷':
          percentageValue = currentValue / 100;
          break;

        default:
          percentageValue = currentValue / 100;
      }
    } else {
      percentageValue = currentValue / 100;
    }

    _displayValue = _formatNumber(percentageValue);
    _shouldResetDisplay = false;

    _updateExpressionPreview();
    notifyListeners();
  }

  void deleteLastCharacter() {
    if (_shouldResetDisplay || _hasError) {
      return;
    }

    if (_displayValue.length <= 1) {
      _displayValue = '0';
    } else {
      _displayValue = _displayValue.substring(0, _displayValue.length - 1);

      if (_displayValue == '-' || _displayValue.isEmpty) {
        _displayValue = '0';
      }
    }

    _updateExpressionPreview();
    notifyListeners();
  }

  void clear({bool notify = true}) {
    _displayValue = '0';
    _expression = '';

    _firstOperand = null;
    _lastSecondOperand = null;

    _operator = null;
    _lastOperator = null;

    _shouldResetDisplay = false;
    _hasError = false;

    if (notify) {
      notifyListeners();
    }
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void useHistoryResult(String result) {
    if (double.tryParse(result) == null) {
      return;
    }

    _displayValue = result;
    _expression = '';

    _firstOperand = null;
    _operator = null;

    _shouldResetDisplay = true;
    _hasError = false;

    notifyListeners();
  }

  double? _performCalculation(
    double firstOperand,
    double secondOperand,
    String operator,
  ) {
    switch (operator) {
      case '+':
        return firstOperand + secondOperand;

      case '−':
        return firstOperand - secondOperand;

      case '×':
        return firstOperand * secondOperand;

      case '÷':
        if (secondOperand == 0) {
          return null;
        }

        return firstOperand / secondOperand;

      default:
        return null;
    }
  }

  void _updateExpressionPreview() {
    if (_firstOperand != null && _operator != null) {
      _expression =
          '${_formatNumber(_firstOperand!)} '
          '$_operator '
          '$_displayValue';
    }
  }

  void _setError() {
    _displayValue = 'Error';
    _expression = 'Cannot divide by zero';

    _firstOperand = null;
    _operator = null;

    _shouldResetDisplay = true;
    _hasError = true;

    notifyListeners();
  }

  String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    var formattedValue = value.toStringAsFixed(10);

    formattedValue = formattedValue.replaceFirst(RegExp(r'0+$'), '');

    formattedValue = formattedValue.replaceFirst(RegExp(r'\.$'), '');

    return formattedValue;
  }

  bool _isDigit(String value) {
    return RegExp(r'^[0-9]$').hasMatch(value);
  }
}
