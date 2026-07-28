class CalculationHistory {
  const CalculationHistory({
    required this.expression,
    required this.result,
    required this.createdAt,
  });

  final String expression;
  final String result;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      'result': result,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CalculationHistory.fromJson(Map<String, dynamic> json) {
    return CalculationHistory(
      expression: json['expression'] as String? ?? '',
      result: json['result'] as String? ?? '0',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
