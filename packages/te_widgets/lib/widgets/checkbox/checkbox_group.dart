import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

/// A group of checkboxes for multiple selection.
///
/// `TCheckboxGroup` provides a multi-select input with:
/// - Multiple checkbox selection
/// - Keyboard navigation support
/// - Validation support
/// - Vertical or horizontal layout
/// - Value binding with ValueNotifier
///
/// ## Basic Usage
///
/// ```dart
/// TCheckboxGroup<String>(
///   label: 'Select options',
///   items: [
///     TCheckboxGroupItem(value: 'option1', label: 'Option 1'),
///     TCheckboxGroupItem(value: 'option2', label: 'Option 2'),
///     TCheckboxGroupItem(value: 'option3', label: 'Option 3'),
///   ],
///   onValueChanged: (values) => print('Selected: \$values'),
/// )
/// ```
///
/// ## With Validation
///
/// ```dart
/// TCheckboxGroup<String>(
///   label: 'Select at least one',
///   isRequired: true,
///   items: items,
///   rules: [
///     (values) => values == null || values.isEmpty
///         ? 'Please select at least one option'
///         : null,
///   ],
/// )
/// ```
///
/// Type parameter:
/// - [T]: The type of values for the checkboxes
///
/// See also:
/// - [TCheckbox] for single checkbox
/// - [TRadioGroup] for single selection
class TCheckboxGroup<T> extends StatefulWidget
    with TInputFieldMixin, TInputValueMixin<List<T>>, TFocusMixin, TInputValidationMixin<List<T>> {
  @override
  final String? label, tag, helperText;
  @override
  final bool isRequired, disabled;
  @override
  final TInputFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final List<T>? value;
  @override
  final ValueNotifier<List<T>?>? valueNotifier;
  @override
  final ValueChanged<List<T>?>? onValueChanged;
  @override
  final List<String? Function(List<T>?)>? rules;
  @override
  final Duration? validationDebounce;

  /// The list of checkbox items.
  final List<TCheckboxGroupItem<T>> items;

  /// Custom color for the checkboxes.
  final Color? color;

  /// Whether to display in block mode.
  final bool block;

  /// Whether to display vertically.
  final bool vertical;

  /// Whether to auto-focus the first checkbox.
  final bool autoFocus;

  /// Creates a checkbox group.
  const TCheckboxGroup({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.isRequired = false,
    this.disabled = false,
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
  });

  @override
  State<TCheckboxGroup<T>> createState() => _TCheckboxGroupState<T>();
}

class _TCheckboxGroupState<T> extends State<TCheckboxGroup<T>>
    with
        TInputFieldStateMixin<TCheckboxGroup<T>>,
        TFocusStateMixin<TCheckboxGroup<T>>,
        TInputValueStateMixin<List<T>, TCheckboxGroup<T>>,
        TInputValidationStateMixin<List<T>, TCheckboxGroup<T>> {
  Set<T> _selectedValues = <T>{};
  late List<FocusNode> _checkboxFocusNodes;
  late List<VoidCallback> _focusListeners;
  late FocusScopeNode _scopeNode;
  int _focusedIndex = -1;

  @override
  void initState() {
    super.initState();
    _checkboxFocusNodes = [];
    _focusListeners = [];

    for (int i = 0; i < widget.items.length; i++) {
      final focusNode = FocusNode(debugLabel: 'Checkbox_$i');

      void listener() => _onCheckboxFocusChanged(i);
      focusNode.addListener(listener);

      _checkboxFocusNodes.add(focusNode);
      _focusListeners.add(listener);
    }

    _scopeNode = FocusScopeNode(debugLabel: 'CheckboxGroup_Scope');
  }

  @override
  void didUpdateWidget(covariant TCheckboxGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.length != oldWidget.items.length) {
      for (int i = 0; i < _checkboxFocusNodes.length; i++) {
        _checkboxFocusNodes[i].removeListener(_focusListeners[i]);
        _checkboxFocusNodes[i].dispose();
      }

      _checkboxFocusNodes.clear();
      _focusListeners.clear();

      for (int i = 0; i < widget.items.length; i++) {
        final focusNode = FocusNode(debugLabel: 'Checkbox_$i');

        void listener() => _onCheckboxFocusChanged(i);
        focusNode.addListener(listener);

        _checkboxFocusNodes.add(focusNode);
        _focusListeners.add(listener);
      }

      _focusedIndex = -1;
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _checkboxFocusNodes.length; i++) {
      _checkboxFocusNodes[i].removeListener(_focusListeners[i]);
      _checkboxFocusNodes[i].dispose();
    }

    _checkboxFocusNodes.clear();
    _focusListeners.clear();

    _scopeNode.dispose();
    super.dispose();
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);
    if (hasFocus && !_isAnyCheckboxFocused()) {
      _focusFirstItem();
    }
  }

  @override
  void onExternalValueChanged(List<T>? value) {
    super.onExternalValueChanged(value);
    final current = currentValue ?? widget.value ?? <T>[];
    _selectedValues = Set<T>.from(current);
    setState(() {});
  }

  bool _isAnyCheckboxFocused() {
    return _checkboxFocusNodes.any((node) => node.hasFocus);
  }

  void _focusFirstItem() {
    if (_checkboxFocusNodes.isNotEmpty && !widget.disabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkboxFocusNodes.first.requestFocus();
        }
      });
    }
  }

  void _onCheckboxFocusChanged(int index) {
    if (_checkboxFocusNodes[index].hasFocus) {
      if (!isFocused) {
        focusNode.requestFocus();
      }

      setState(() {
        _focusedIndex = index;
      });
    }
  }

  void _onItemChanged(T value, bool checked) {
    if (widget.disabled) return;

    setState(() {
      if (checked) {
        _selectedValues.add(value);
      } else {
        _selectedValues.remove(value);
      }
    });

    final newValue = _selectedValues.toList();
    notifyValueChanged(newValue);
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
        final currentValue = _selectedValues.contains(item.value);
        _onItemChanged(item.value, !currentValue);
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
        isMultiline: true,
        child: Focus(
          focusNode: focusNode,
          autofocus: widget.autoFocus,
          skipTraversal: true,
          canRequestFocus: !widget.disabled,
          child: FocusScope(
            node: _scopeNode,
            onKeyEvent: _handleKeyEvent,
            child: _buildCheckboxes(widget.color ?? context.theme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxes(Color color) {
    final items = <Widget>[];

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final isChecked = _selectedValues.contains(item.value);
      final focusNode = _checkboxFocusNodes[i];

      items.add(TCheckbox(
        focusNode: focusNode,
        label: item.label,
        color: item.color ?? color,
        size: wTheme.size,
        value: isChecked,
        onValueChanged: (checked) => {_onItemChanged(item.value, checked ?? false)},
      ));
    }

    return widget.vertical
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: items)
        : Wrap(spacing: 16, runSpacing: 8, alignment: WrapAlignment.start, children: items);
  }
}
