import 'package:calculator/features/calculator/logic/calculator_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorController', () {
    late CalculatorController controller;

    setUp(() {
      controller = CalculatorController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial value should be zero', () {
      expect(controller.displayValue, '0');
      expect(controller.expression, '');
    });

    test('should enter multiple digits', () {
      controller.onButtonPressed('1');
      controller.onButtonPressed('2');
      controller.onButtonPressed('3');

      expect(controller.displayValue, '123');
    });

    test('should calculate addition', () {
      controller.onButtonPressed('1');
      controller.onButtonPressed('0');
      controller.onButtonPressed('+');
      controller.onButtonPressed('5');
      controller.onButtonPressed('=');

      expect(controller.displayValue, '15');
      expect(controller.expression, '10 + 5 =');
    });

    test('should calculate subtraction', () {
      controller.onButtonPressed('9');
      controller.onButtonPressed('−');
      controller.onButtonPressed('4');
      controller.onButtonPressed('=');

      expect(controller.displayValue, '5');
    });

    test('should calculate multiplication', () {
      controller.onButtonPressed('6');
      controller.onButtonPressed('×');
      controller.onButtonPressed('7');
      controller.onButtonPressed('=');

      expect(controller.displayValue, '42');
    });

    test('should calculate division', () {
      controller.onButtonPressed('8');
      controller.onButtonPressed('÷');
      controller.onButtonPressed('2');
      controller.onButtonPressed('=');

      expect(controller.displayValue, '4');
    });

    test('should handle division by zero', () {
      controller.onButtonPressed('8');
      controller.onButtonPressed('÷');
      controller.onButtonPressed('0');
      controller.onButtonPressed('=');

      expect(controller.displayValue, 'Error');
      expect(controller.expression, 'Cannot divide by zero');
    });

    test('should prevent duplicate decimal points', () {
      controller.onButtonPressed('1');
      controller.onButtonPressed('.');
      controller.onButtonPressed('.');
      controller.onButtonPressed('5');

      expect(controller.displayValue, '1.5');
    });

    test('should calculate percentage', () {
      controller.onButtonPressed('5');
      controller.onButtonPressed('0');
      controller.onButtonPressed('%');

      expect(controller.displayValue, '0.5');
    });

    test('should delete last digit', () {
      controller.onButtonPressed('1');
      controller.onButtonPressed('2');
      controller.onButtonPressed('3');
      controller.onButtonPressed('DELETE');

      expect(controller.displayValue, '12');
    });

    test('should clear complete calculation', () {
      controller.onButtonPressed('5');
      controller.onButtonPressed('+');
      controller.onButtonPressed('5');
      controller.onButtonPressed('AC');

      expect(controller.displayValue, '0');
      expect(controller.expression, '');
    });

    test('should support continuous calculations', () {
      controller.onButtonPressed('5');
      controller.onButtonPressed('+');
      controller.onButtonPressed('5');
      controller.onButtonPressed('×');
      controller.onButtonPressed('2');
      controller.onButtonPressed('=');

      expect(controller.displayValue, '20');
    });

    test('should toggle positive value to negative', () {
      controller.onButtonPressed('5');
      controller.onButtonPressed('+/-');

      expect(controller.displayValue, '-5');
    });

    test('should toggle negative value to positive', () {
      controller.onButtonPressed('8');
      controller.onButtonPressed('+/-');
      controller.onButtonPressed('+/-');

      expect(controller.displayValue, '8');
    });

    test('should replace selected operator', () {
      controller.onButtonPressed('5');
      controller.onButtonPressed('+');
      controller.onButtonPressed('×');
      controller.onButtonPressed('2');
      controller.onButtonPressed('=');

      expect(controller.displayValue, '10');
    });

    test('should repeat equals calculation', () {
      controller.onButtonPressed('5');
      controller.onButtonPressed('+');
      controller.onButtonPressed('2');
      controller.onButtonPressed('=');
      controller.onButtonPressed('=');

      expect(controller.displayValue, '9');
    });

    test('should save calculation history', () {
      controller.onButtonPressed('4');
      controller.onButtonPressed('+');
      controller.onButtonPressed('6');
      controller.onButtonPressed('=');

      expect(controller.history.length, 1);
      expect(controller.history.first.result, '10');
    });

    test('should clear calculation history', () {
      controller.onButtonPressed('4');
      controller.onButtonPressed('+');
      controller.onButtonPressed('6');
      controller.onButtonPressed('=');

      controller.clearHistory();

      expect(controller.history, isEmpty);
    });

    test('should reuse history result', () {
      controller.useHistoryResult('25');

      expect(controller.displayValue, '25');
      expect(controller.expression, '');
    });

    test('addition percentage should use first operand', () {
      controller.onButtonPressed('2');
      controller.onButtonPressed('0');
      controller.onButtonPressed('0');
      controller.onButtonPressed('+');
      controller.onButtonPressed('1');
      controller.onButtonPressed('0');
      controller.onButtonPressed('%');
      controller.onButtonPressed('=');

      expect(controller.displayValue, '220');
    });
  });
}
