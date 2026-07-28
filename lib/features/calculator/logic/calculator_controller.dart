import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/calculation_history_storage.dart';
import '../models/calculation_history.dart';

class CalculatorController extends ChangeNotifier {
  CalculatorController({CalculationHistoryStorage? historyStorage})
    : _historyStorage = historyStorage ?? CalculationHistoryStorage() {
    _storageQueue = _loadHistory();
  }

  static const int _maximumInputLength = 16;
  static const int _maximumHistoryItems = 50;

  final CalculationHistoryStorage _historyStorage;

  late Future<void> _storageQueue;

  String _displayValue = '0';
  String _expression = '';

  double? _firstOperand;
  double? _lastSecondOperand;

  String? _operator;
  String? _lastOperator;

  bool _shouldResetDisplay = false;
  bool _hasError = false;
  bool _isDisposed = false;

  int _historyRevision = 0;

  final List<CalculationHistory> _history = [];

  String get displayValue => _displayValue;

  String get expression => _expression;

  String? get selectedOperator => _operator;

  bool get hasError => _hasError;

  List<CalculationHistory> get history {
    return List<CalculationHistory>.unmodifiable(_history.reversed);
  }

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
    if (!_isDigit(digit)) {
      return;
    }

    if (_shouldResetDisplay || _displayValue == '0') {
      _displayValue = digit;
      _shouldResetDisplay = false;
    } else if (_displayValue == '-0') {
      _displayValue = '-$digit';
    } else if (_displayValue.replaceAll('-', '').length < _maximumInputLength) {
      _displayValue += digit;
    }

    _updateExpressionPreview();
    _notifySafely();
  }

  void inputDecimal() {
    if (_shouldResetDisplay) {
      _displayValue = '0.';
      _shouldResetDisplay = false;
    } else if (!_displayValue.contains('.')) {
      _displayValue += '.';
    }

    _updateExpressionPreview();
    _notifySafely();
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
    _notifySafely();
  }

  void inputOperator(String newOperator) {
    if (!_isOperator(newOperator)) {
      return;
    }

    final currentValue = double.tryParse(_displayValue);

    if (currentValue == null) {
      return;
    }

    // Replace the selected operator before entering the second operand.
    if (_operator != null && _shouldResetDisplay) {
      _operator = newOperator;
      _expression = '${_formatNumber(_firstOperand!)} $newOperator';

      _notifySafely();
      return;
    }

    // Calculate the pending operation before continuing with a new operator.
    if (_operator != null && _firstOperand != null) {
      final calculatedValue = _performCalculation(
        _firstOperand!,
        currentValue,
        _operator!,
      );

      if (calculatedValue == null) {
        _setError('Cannot divide by zero');
        return;
      }

      if (!calculatedValue.isFinite) {
        _setError('Result is too large');
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

    _notifySafely();
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

    // Repeat the previous equals operation.
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
      _setError('Cannot divide by zero');
      return;
    }

    if (!result.isFinite) {
      _setError('Result is too large');
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

    if (_history.length > _maximumHistoryItems) {
      _history.removeRange(0, _history.length - _maximumHistoryItems);
    }

    _historyRevision++;
    _queueHistorySave();

    _lastOperator = operator;
    _lastSecondOperand = secondOperand;

    _firstOperand = null;
    _operator = null;

    _shouldResetDisplay = true;
    _hasError = false;

    _notifySafely();
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

    if (!percentageValue.isFinite) {
      _setError('Result is too large');
      return;
    }

    _displayValue = _formatNumber(percentageValue);
    _shouldResetDisplay = false;

    _updateExpressionPreview();
    _notifySafely();
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
    _notifySafely();
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
      _notifySafely();
    }
  }

  void clearHistory() {
    _history.clear();
    _historyRevision++;

    _notifySafely();
    _queueStorageOperation(_historyStorage.clearHistory);
  }

  void useHistoryResult(String result) {
    if (double.tryParse(result) == null) {
      return;
    }

    _displayValue = result;
    _expression = '';

    _firstOperand = null;
    _lastSecondOperand = null;

    _operator = null;
    _lastOperator = null;

    _shouldResetDisplay = true;
    _hasError = false;

    _notifySafely();
  }

  Future<void> _loadHistory() async {
    final revisionBeforeLoading = _historyRevision;

    try {
      final savedHistory = await _historyStorage.loadHistory();

      // Do not restore old data if history changed while loading.
      if (revisionBeforeLoading != _historyRevision) {
        await _historyStorage.saveHistory(
          List<CalculationHistory>.from(_history),
        );
        return;
      }

      final validHistory = savedHistory.length > _maximumHistoryItems
          ? savedHistory.sublist(savedHistory.length - _maximumHistoryItems)
          : savedHistory;

      _history
        ..clear()
        ..addAll(validHistory);

      _notifySafely();
    } catch (_) {
      // Storage failure must not stop calculator functionality.
    }
  }

  void _queueHistorySave() {
    final historySnapshot = List<CalculationHistory>.from(_history);

    _queueStorageOperation(() => _historyStorage.saveHistory(historySnapshot));
  }

  void _queueStorageOperation(Future<void> Function() operation) {
    _storageQueue = _storageQueue.then((_) => operation()).catchError((
      Object _,
    ) {
      // Ignore local storage failures.
    });
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

  void _setError(String message) {
    _displayValue = 'Error';
    _expression = message;

    _firstOperand = null;
    _lastSecondOperand = null;

    _operator = null;
    _lastOperator = null;

    _shouldResetDisplay = true;
    _hasError = true;

    _notifySafely();
  }

  String _formatNumber(double value) {
    if (!value.isFinite) {
      return 'Error';
    }

    if (value == 0) {
      return '0';
    }

    final absoluteValue = value.abs();

    if (absoluteValue >= 1000000000000000 || absoluteValue < 0.0000000001) {
      return value
          .toStringAsExponential(8)
          .replaceFirst(RegExp(r'\.?0+e'), 'e')
          .replaceFirst('e+', 'e');
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

  bool _isOperator(String value) {
    return value == '+' || value == '−' || value == '×' || value == '÷';
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
