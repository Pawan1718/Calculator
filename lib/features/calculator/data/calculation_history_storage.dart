import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/calculation_history.dart';

class CalculationHistoryStorage {
  static const String _historyKey = 'calculator_history';

  Future<List<CalculationHistory>> loadHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final storedHistory = preferences.getStringList(_historyKey);

    if (storedHistory == null || storedHistory.isEmpty) {
      return [];
    }

    final history = <CalculationHistory>[];

    for (final encodedItem in storedHistory) {
      try {
        final decodedItem = jsonDecode(encodedItem);

        if (decodedItem is Map<String, dynamic>) {
          history.add(CalculationHistory.fromJson(decodedItem));
        } else if (decodedItem is Map) {
          history.add(
            CalculationHistory.fromJson(Map<String, dynamic>.from(decodedItem)),
          );
        }
      } catch (_) {
        // Ignore corrupted history entries.
      }
    }

    return history;
  }

  Future<void> saveHistory(List<CalculationHistory> history) async {
    final preferences = await SharedPreferences.getInstance();

    final encodedHistory = history
        .map((item) => jsonEncode(item.toJson()))
        .toList(growable: false);

    await preferences.setStringList(_historyKey, encodedHistory);
  }

  Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_historyKey);
  }
}
