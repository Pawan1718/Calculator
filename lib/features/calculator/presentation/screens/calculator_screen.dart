import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../logic/calculator_controller.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_display.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late final CalculatorController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CalculatorController();
    _controller.addListener(_onCalculatorChanged);
  }

  void _onCalculatorChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleButtonPress(String value) {
    HapticFeedback.selectionClick();
    _controller.onButtonPressed(value);
  }

  Future<void> _copyResult() async {
    await Clipboard.setData(ClipboardData(text: _controller.displayValue));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Result copied'),
          duration: Duration(seconds: 1),
        ),
      );
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final history = _controller.history;

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.65,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Calculation History',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (history.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _controller.clearHistory();
                                setModalState(() {});
                              },
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: history.isEmpty
                          ? const Center(
                              child: Text(
                                'No calculations yet',
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: history.length,
                              separatorBuilder: (context, index) {
                                return const Divider(height: 1);
                              },
                              itemBuilder: (context, index) {
                                final item = history[index];

                                return ListTile(
                                  onTap: () {
                                    _controller.useHistoryResult(item.result);

                                    Navigator.pop(bottomSheetContext);
                                  },
                                  title: Text(
                                    item.expression,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: AppTheme.secondaryTextColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.result,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Copy result',
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: item.result),
                                      );
                                    },
                                    icon: const Icon(Icons.copy_rounded),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onCalculatorChanged);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            final horizontalPadding = constraints.maxWidth < 360 ? 12.0 : 20.0;

            final verticalPadding = isLandscape ? 8.0 : 12.0;

            if (isLandscape) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: _buildDisplaySection()),
                    const SizedBox(width: 20),
                    Expanded(flex: 6, child: _buildKeyboard()),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                children: [
                  Expanded(flex: 4, child: _buildDisplaySection()),
                  Expanded(flex: 6, child: _buildKeyboard()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDisplaySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'History',
              onPressed: _showHistory,
              icon: const Icon(Icons.history_rounded),
            ),
            IconButton(
              tooltip: 'Copy result',
              onPressed: _controller.hasError ? null : _copyResult,
              icon: const Icon(Icons.copy_rounded),
            ),
          ],
        ),
        Expanded(
          child: CalculatorDisplay(
            expression: _controller.expression,
            result: _controller.displayValue,
            hasError: _controller.hasError,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyboard() {
    return Column(
      children: [
        _buildButtonRow(
          children: [
            CalculatorButton(
              label: 'AC',
              type: CalculatorButtonType.function,
              onPressed: () => _handleButtonPress('AC'),
            ),
            CalculatorButton(
              label: '⌫',
              type: CalculatorButtonType.function,
              onPressed: () => _handleButtonPress('DELETE'),
            ),
            CalculatorButton(
              label: '%',
              type: CalculatorButtonType.function,
              onPressed: () => _handleButtonPress('%'),
            ),
            CalculatorButton(
              label: '÷',
              type: CalculatorButtonType.operator,
              isSelected: _controller.selectedOperator == '÷',
              onPressed: () => _handleButtonPress('÷'),
            ),
          ],
        ),
        _buildButtonRow(
          children: [
            CalculatorButton(
              label: '7',
              onPressed: () => _handleButtonPress('7'),
            ),
            CalculatorButton(
              label: '8',
              onPressed: () => _handleButtonPress('8'),
            ),
            CalculatorButton(
              label: '9',
              onPressed: () => _handleButtonPress('9'),
            ),
            CalculatorButton(
              label: '×',
              type: CalculatorButtonType.operator,
              isSelected: _controller.selectedOperator == '×',
              onPressed: () => _handleButtonPress('×'),
            ),
          ],
        ),
        _buildButtonRow(
          children: [
            CalculatorButton(
              label: '4',
              onPressed: () => _handleButtonPress('4'),
            ),
            CalculatorButton(
              label: '5',
              onPressed: () => _handleButtonPress('5'),
            ),
            CalculatorButton(
              label: '6',
              onPressed: () => _handleButtonPress('6'),
            ),
            CalculatorButton(
              label: '−',
              type: CalculatorButtonType.operator,
              isSelected: _controller.selectedOperator == '−',
              onPressed: () => _handleButtonPress('−'),
            ),
          ],
        ),
        _buildButtonRow(
          children: [
            CalculatorButton(
              label: '1',
              onPressed: () => _handleButtonPress('1'),
            ),
            CalculatorButton(
              label: '2',
              onPressed: () => _handleButtonPress('2'),
            ),
            CalculatorButton(
              label: '3',
              onPressed: () => _handleButtonPress('3'),
            ),
            CalculatorButton(
              label: '+',
              type: CalculatorButtonType.operator,
              isSelected: _controller.selectedOperator == '+',
              onPressed: () => _handleButtonPress('+'),
            ),
          ],
        ),
        _buildButtonRow(
          addBottomSpacing: false,
          children: [
            CalculatorButton(
              label: '+/-',
              type: CalculatorButtonType.function,
              onPressed: () => _handleButtonPress('+/-'),
            ),
            CalculatorButton(
              label: '0',
              onPressed: () => _handleButtonPress('0'),
            ),
            CalculatorButton(
              label: '.',
              onPressed: () => _handleButtonPress('.'),
            ),
            CalculatorButton(
              label: '=',
              type: CalculatorButtonType.equal,
              onPressed: () => _handleButtonPress('='),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonRow({
    required List<Widget> children,
    bool addBottomSpacing = true,
  }) {
    final spacedChildren = <Widget>[];

    for (var index = 0; index < children.length; index++) {
      spacedChildren.add(children[index]);

      if (index < children.length - 1) {
        spacedChildren.add(const SizedBox(width: AppConstants.buttonSpacing));
      }
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: addBottomSpacing ? AppConstants.buttonSpacing : 0,
        ),
        child: Row(children: spacedChildren),
      ),
    );
  }
}
