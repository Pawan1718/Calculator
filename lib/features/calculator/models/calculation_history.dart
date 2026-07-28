class CalculationHistory {
  const CalculationHistory({
    required this.expression,
    required this.result,
    required this.createdAt,
  });

  final String expression;
  final String result;
  final DateTime createdAt;
}
