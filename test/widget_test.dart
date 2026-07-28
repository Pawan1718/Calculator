import 'package:calculator/app/calculator_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calculator screen loads successfully', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('AC'), findsOneWidget);
    expect(find.text('='), findsOneWidget);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('+/-'), findsOneWidget);
  });

  testWidgets('addition works from calculator UI', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('2'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('='));

    await tester.pumpAndSettle();

    expect(find.text('5'), findsOneWidget);
    expect(find.text('2 + 3 ='), findsOneWidget);
  });

  testWidgets('AC clears calculator value', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('8'));
    await tester.tap(find.text('AC'));

    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('history bottom sheet opens', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    expect(find.text('Calculation History'), findsOneWidget);
    expect(find.text('No calculations yet'), findsOneWidget);
  });
}
