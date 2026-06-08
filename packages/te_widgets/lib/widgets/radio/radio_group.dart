import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

/// A group of radio buttons for single selection.
///
/// `TRadioGroup` provides a single-select input with:
/// - Single radio button selection
/// - Keyboard navigation support
/// - Validation support
/// - Vertical or horizontal layout
/// - Value binding with ValueNotifier
///
/// ## Basic Usage
///
/// ```dart
/// TRadioGroup<String>(
///   label: 'Select an option',
///   items: [
///     TRadioGroupItem(value: 'option1', label: 'Option 1'),
///     TRadioGroupItem(value: 'option2', label: 'Option 2'),
///     TRadioGroupItem(value: 'option3', label: 'Option 3'),
///   ],
///   onValueChanged: (value) => print('Selected: $value'),
/// )
/// ```
///
/// Type parameter:
/// - [T]: The type of values for the radio buttons
///
/// See also:
/// - [TRadio] for single radio button
/// - [TCheckboxGroup] for multiple selection
class TRadioGroup<T> extends StatefulWidget with TInputFieldMixin, TInputValueMixin<T?>, TFocusMixin, TInputValidationMixin<T?> {
  @override
  final String? label, tag, helperText, info;
  @override
  final bool isRequired, disabled;
  @override
  final bool clearable;
  @override
  final TInputFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final T? value;
  @override
  final ValueNotifier<T?>? valueNotifier;
  @override
  final ValueChanged<T?>? onValueChanged;
  @override
  final List<String? Function(T?)>? rules;
  @override
  final Duration? validationDebounce;

  /// The list of radio group items.
  final List<TRadioGroupItem<T>> items;

  /// Custom color for the radio buttons.
  final Color? color;

  /// Whether to display in block mode.
  final bool block;

  /// Whether to display vertically.
  final bool vertical;

  /// Whether to auto-focus the first radio button.
  final bool autoFocus;

  final double spacing;
  final double runSpacing;

  /// Creates a radio group.
  const TRadioGroup({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.info,
    this.isRequired = false,
    this.disabled = false,
    this.clearable = false,
    this.theme,
    this.onTap,
    this.focusNode,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
    this.items = const [],
    this.color,
    this.block = true,
    this.vertical = false,
    this.autoFocus = false,
    this.spacing = 16,
    this.runSpacing = 8,
  });

  @override
  State<TRadioGroup<T>> createState() => _TRadioGroupState<T>();
}

class _TRadioGroupState<T> extends State<TRadioGroup<T>>
    with
        TInputFieldStateMixin<TRadioGroup<T>>,
        TFocusStateMixin<TRadioGroup<T>>,
        TInputValueStateMixin<T?, TRadioGroup<T>>,
        TInputValidationStateMixin<T?, TRadioGroup<T>> {
  late List<FocusNode> _radioFocusNodes;
  late List<VoidCallback> _focusListeners;
  late FocusScopeNode _scopeNode;
  int _focusedIndex = -1;

  @override
  void initState() {
    super.initState();
    _radioFocusNodes = [];
    _focusListeners = [];

    for (int i = 0; i < widget.items.length; i++) {
      final focusNode = FocusNode(debugLabel: 'Radio_$i');

      void listener() => _onRadioFocusChanged(i);
      focusNode.addListener(listener);

      _radioFocusNodes.add(focusNode);
      _focusListeners.add(listener);
    }

    _scopeNode = FocusScopeNode(debugLabel: 'RadioGroup_Scope');
  }

  @override
  void didUpdateWidget(covariant TRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.length != oldWidget.items.length) {
      for (int i = 0; i < _radioFocusNodes.length; i++) {
        _radioFocusNodes[i].removeListener(_focusListeners[i]);
        _radioFocusNodes[i].dispose();
      }

      _radioFocusNodes.clear();
      _focusListeners.clear();

      for (int i = 0; i < widget.items.length; i++) {
        final focusNode = FocusNode(debugLabel: 'Radio_$i');

        void listener() => _onRadioFocusChanged(i);
        focusNode.addListener(listener);

        _radioFocusNodes.add(focusNode);
        _focusListeners.add(listener);
      }

      _focusedIndex = -1;
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _radioFocusNodes.length; i++) {
      _radioFocusNodes[i].removeListener(_focusListeners[i]);
      _radioFocusNodes[i].dispose();
    }

    _radioFocusNodes.clear();
    _focusListeners.clear();

    _scopeNode.dispose();
    super.dispose();
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);
    if (hasFocus && !_isAnyRadioFocused()) {
      _focusFirstItem();
    }
  }

  bool _isAnyRadioFocused() {
    return _radioFocusNodes.any((node) => node.hasFocus);
  }

  void _focusFirstItem() {
    if (_radioFocusNodes.isNotEmpty && !widget.disabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _radioFocusNodes.first.requestFocus();
        }
      });
    }
  }

  void _onRadioFocusChanged(int index) {
    if (_radioFocusNodes[index].hasFocus) {
      if (!isFocused) {
        focusNode.requestFocus();
      }

      setState(() {
        _focusedIndex = index;
      });
    }
  }

  void _onItemChanged(T? value) {
    if (widget.disabled) return;

    notifyValueChanged(value);
    setState(() {});
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowRight) {
      _scopeNode.nextFocus();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.arrowLeft) {
      _scopeNode.previousFocus();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter) {
      if (_focusedIndex >= 0 && _focusedIndex < widget.items.length) {
        final item = widget.items[_focusedIndex];
        _onItemChanged(item.value);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) {
        focusNode.unfocus();
      },
      child: buildContainer(
        block: widget.block,
        expands: true,
        floatingLabelAlways: true,
        hasValue: currentValue != null,
        onClear: () {
          notifyValueChanged(null);
          setState(() {});
        },
        child: Focus(
          focusNode: focusNode,
          autofocus: widget.autoFocus,
          skipTraversal: true,
          canRequestFocus: !widget.disabled,
          child: FocusScope(
            node: _scopeNode,
            onKeyEvent: _handleKeyEvent,
            child: _buildRadios(widget.color ?? context.theme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildRadios(Color color) {
    final items = <Widget>[];

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final focusNode = _radioFocusNodes[i];

      items.add(TRadio<T>(
        focusNode: focusNode,
        label: item.label,
        color: item.color ?? color,
        size: wTheme.size,
        radioValue: item.value,
        value: currentValue,
        onValueChanged: (value) => _onItemChanged(value),
      ));
    }

    return widget.vertical
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: widget.runSpacing,
              children: items,
            ),
          )
        : Wrap(
            spacing: widget.spacing,
            runSpacing: widget.runSpacing,
            alignment: WrapAlignment.start,
            children: items,
          );
  }
}
