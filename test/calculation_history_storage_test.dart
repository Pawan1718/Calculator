import 'package:calculator/features/calculator/data/calculation_history_storage.dart';
import 'package:calculator/features/calculator/models/calculation_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CalculationHistoryStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = CalculationHistoryStorage();
  });

  test('should save and load calculation history', () async {
    final createdAt = DateTime(2026, 7, 28, 10, 30);

    await storage.saveHistory([
      CalculationHistory(
        expression: '5 + 5 =',
        result: '10',
        createdAt: createdAt,
      ),
    ]);

    final history = await storage.loadHistory();

    expect(history.length, 1);
    expect(history.first.expression, '5 + 5 =');
    expect(history.first.result, '10');
    expect(history.first.createdAt, createdAt);
  });

  test('should clear saved calculation history', () async {
    await storage.saveHistory([
      CalculationHistory(
        expression: '8 × 2 =',
        result: '16',
        createdAt: DateTime.now(),
      ),
    ]);

    await storage.clearHistory();

    final history = await storage.loadHistory();

    expect(history, isEmpty);
  });

  test('should ignore corrupted history entries', () async {
    SharedPreferences.setMockInitialValues({
      'calculator_history': [
        'invalid-json',
        '{"expression":"2 + 3 =","result":"5","createdAt":"2026-07-28T10:00:00.000"}',
      ],
    });

    final history = await storage.loadHistory();

    expect(history.length, 1);
    expect(history.first.result, '5');
  });
}
