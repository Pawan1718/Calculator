import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/constants/app_constants.dart';
import '../../logic/calculator_controller.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_display.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  State<CalculatorScreen> createState() {
    return _CalculatorScreenState();
  }
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late final CalculatorController _controller;
  late final FocusNode _keyboardFocusNode;

  @override
  void initState() {
    super.initState();

    _controller = CalculatorController();
    _controller.addListener(_onCalculatorChanged);

    _keyboardFocusNode = FocusNode(debugLabel: 'CalculatorKeyboardFocus');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  void _onCalculatorChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleButtonPress(String value) {
    HapticFeedback.selectionClick();
    _controller.onButtonPressed(value);
    _keyboardFocusNode.requestFocus();
  }

  KeyEventResult _handleKeyboardEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final logicalKey = event.logicalKey;
    final character = event.character;

    if (character != null && RegExp(r'^[0-9]$').hasMatch(character)) {
      _handleButtonPress(character);
      return KeyEventResult.handled;
    }

    if (character == '.') {
      _handleButtonPress('.');
      return KeyEventResult.handled;
    }

    if (character == '+') {
      _handleButtonPress('+');
      return KeyEventResult.handled;
    }

    if (character == '-' || character == '−') {
      _handleButtonPress('−');
      return KeyEventResult.handled;
    }

    if (character == '*' || character == '×') {
      _handleButtonPress('×');
      return KeyEventResult.handled;
    }

    if (character == '/' || character == '÷') {
      _handleButtonPress('÷');
      return KeyEventResult.handled;
    }

    if (character == '%') {
      _handleButtonPress('%');
      return KeyEventResult.handled;
    }

    if (character == '=') {
      _handleButtonPress('=');
      return KeyEventResult.handled;
    }

    if (logicalKey == LogicalKeyboardKey.enter ||
        logicalKey == LogicalKeyboardKey.numpadEnter) {
      _handleButtonPress('=');
      return KeyEventResult.handled;
    }

    if (logicalKey == LogicalKeyboardKey.backspace ||
        logicalKey == LogicalKeyboardKey.delete) {
      _handleButtonPress('DELETE');
      return KeyEventResult.handled;
    }

    if (logicalKey == LogicalKeyboardKey.escape) {
      _handleButtonPress('AC');
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Future<void> _copyResult() async {
    if (_controller.hasError) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: _controller.displayValue));

    if (!mounted) {
      return;
    }

    _showMessage('Result copied');
  }

  Future<void> _copyHistoryResult(String result) async {
    await Clipboard.setData(ClipboardData(text: result));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    _showMessage('History result copied');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
  }

  Future<void> _showClearHistoryConfirmation(
    BuildContext bottomSheetContext,
  ) async {
    final shouldClear = await showDialog<bool>(
      context: bottomSheetContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear history?'),
          content: const Text(
            'All saved calculations will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !mounted) {
      return;
    }

    _controller.clearHistory();

    if (bottomSheetContext.mounted) {
      Navigator.pop(bottomSheetContext);
    }

    _showMessage('History cleared');
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface(context),
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (bottomSheetContext) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            final history = _controller.history;
            final screenHeight = MediaQuery.sizeOf(context).height;

            return SizedBox(
              height: screenHeight * 0.68,
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
                          TextButton.icon(
                            onPressed: () {
                              _showClearHistoryConfirmation(bottomSheetContext);
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Clear'),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: history.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  size: 48,
                                  color: AppTheme.secondaryText(context),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No calculations yet',
                                  style: TextStyle(
                                    color: AppTheme.secondaryText(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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

                              return Semantics(
                                button: true,
                                label:
                                    '${item.expression} Result ${item.result}',
                                hint: 'Tap to reuse this result',
                                child: ListTile(
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    20,
                                    8,
                                    8,
                                    8,
                                  ),
                                  onTap: () {
                                    _controller.useHistoryResult(item.result);
                                    Navigator.pop(bottomSheetContext);
                                    _keyboardFocusNode.requestFocus();
                                  },
                                  title: Text(
                                    item.expression,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: AppTheme.secondaryText(context),
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.result,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryText(context),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Copy result',
                                    onPressed: () {
                                      _copyHistoryResult(item.result);
                                    },
                                    icon: const Icon(Icons.copy_rounded),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onCalculatorChanged);
    _controller.dispose();

    _keyboardFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyboardEvent,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;

              final horizontalPadding = constraints.maxWidth < 360
                  ? 12.0
                  : 20.0;

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
      ),
    );
  }

  Widget _buildDisplaySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupMenuButton<ThemeMode>(
              tooltip: widget.themeController.label,
              icon: Icon(widget.themeController.icon),
              onSelected: (themeMode) {
                widget.themeController.setThemeMode(themeMode);
                _keyboardFocusNode.requestFocus();
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<ThemeMode>(
                    value: ThemeMode.system,
                    child: _buildThemeMenuItem(
                      context: context,
                      mode: ThemeMode.system,
                      icon: Icons.brightness_auto_rounded,
                      label: 'System',
                    ),
                  ),
                  PopupMenuItem<ThemeMode>(
                    value: ThemeMode.light,
                    child: _buildThemeMenuItem(
                      context: context,
                      mode: ThemeMode.light,
                      icon: Icons.light_mode_rounded,
                      label: 'Light',
                    ),
                  ),
                  PopupMenuItem<ThemeMode>(
                    value: ThemeMode.dark,
                    child: _buildThemeMenuItem(
                      context: context,
                      mode: ThemeMode.dark,
                      icon: Icons.dark_mode_rounded,
                      label: 'Dark',
                    ),
                  ),
                ];
              },
            ),
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
          child: Semantics(
            liveRegion: true,
            label:
                'Expression ${_controller.expression.isEmpty ? "empty" : _controller.expression}. '
                'Result ${_controller.displayValue}',
            child: CalculatorDisplay(
              expression: _controller.expression,
              result: _controller.displayValue,
              hasError: _controller.hasError,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeMenuItem({
    required BuildContext context,
    required ThemeMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.themeController.themeMode == mode;

    return Row(
      children: [
        Icon(
          icon,
          color: isSelected
              ? AppTheme.primaryColor
              : Theme.of(context).iconTheme.color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryText(context),
            ),
          ),
        ),
        if (isSelected)
          const Icon(Icons.check_rounded, color: AppTheme.primaryColor),
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
