import 'package:calculator/app/calculator_app.dart';
import 'package:calculator/features/calculator/presentation/widgets/calculator_display.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Finder displayText(String value) {
    return find.descendant(
      of: find.byType(CalculatorDisplay),
      matching: find.text(value),
    );
  }

  testWidgets('calculator screen loads successfully', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    expect(displayText('0'), findsOneWidget);
    expect(find.text('AC'), findsOneWidget);
    expect(find.text('='), findsOneWidget);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('+/-'), findsOneWidget);
  });

  testWidgets('addition works from calculator UI', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('2'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('='));

    await tester.pumpAndSettle();

    expect(displayText('5'), findsOneWidget);
    expect(find.text('2 + 3 ='), findsOneWidget);
  });

  testWidgets('AC clears calculator value', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('8'));
    await tester.pump();

    expect(displayText('8'), findsOneWidget);

    await tester.tap(find.text('AC'));
    await tester.pumpAndSettle();

    expect(displayText('0'), findsOneWidget);
  });

  testWidgets('history bottom sheet opens', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    expect(find.text('Calculation History'), findsOneWidget);
    expect(find.text('No calculations yet'), findsOneWidget);
  });

  testWidgets('history stores completed calculation', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('4'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('6'));
    await tester.tap(find.text('='));

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('4 + 6 = Result 10'), findsOneWidget);
  });

  testWidgets('theme menu opens successfully', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('System theme'));
    await tester.pumpAndSettle();

    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });
}
