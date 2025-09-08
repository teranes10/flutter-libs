import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TCheckboxGroup<T> extends StatefulWidget
    with TInputFieldMixin, TInputValueMixin<List<T>>, TFocusMixin, TInputValidationMixin<List<T>> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool isRequired, disabled;
  @override
  final TInputSize? size;
  @override
  final Color? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final Widget? preWidget, postWidget;
  @override
  final VoidCallback? onTap;
  @override
  final List<String? Function(List<T>?)>? rules;
  @override
  final List<String>? errors;
  @override
  final Duration? validationDebounce;
  @override
  final bool? skipValidation;
  @override
  final List<T>? value;
  @override
  final ValueNotifier<List<T>>? valueNotifier;
  @override
  final ValueChanged<List<T>>? onValueChanged;
  @override
  final FocusNode? focusNode;

  final List<TCheckboxGroupItem<T>> items;
  final bool block;
  final bool vertical;

  const TCheckboxGroup({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.isRequired = false,
    this.disabled = false,
    this.size,
    this.color,
    this.boxDecoration,
    this.preWidget,
    this.postWidget,
    this.onTap,
    this.rules,
    this.errors,
    this.validationDebounce,
    this.skipValidation,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    this.items = const [],
    this.block = true,
    this.vertical = false,
  });

  @override
  State<TCheckboxGroup<T>> createState() => _TCheckboxGroupState<T>();
}

class _TCheckboxGroupState<T> extends State<TCheckboxGroup<T>>
    with
        TInputFieldStateMixin<TCheckboxGroup<T>>,
        TInputValueStateMixin<List<T>, TCheckboxGroup<T>>,
        TFocusStateMixin<TCheckboxGroup<T>>,
        TInputValidationStateMixin<List<T>, TCheckboxGroup<T>> {
  late Set<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _initializeSelectedValues();
  }

  @override
  void didUpdateWidget(TCheckboxGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _initializeSelectedValues();
    }
  }

  void _initializeSelectedValues() {
    final current = currentValue ?? widget.value ?? <T>[];
    _selectedValues = Set<T>.from(current);
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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final exTheme = context.exTheme;

    return buildContainer(theme, exTheme, block: widget.block, isMultiline: true, child: _buildCheckboxes());
  }

  Widget _buildCheckboxes() {
    final items = widget.items.map((item) {
      final isChecked = _selectedValues.contains(item.value);

      return TCheckbox(
        label: item.label,
        color: item.color ?? widget.color,
        size: widget.size,
        value: isChecked,
        onValueChanged: (checked) => _onItemChanged(item.value, checked ?? false),
      );
    }).toList();

    return widget.vertical
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: items)
        : Wrap(spacing: 16, runSpacing: 8, alignment: WrapAlignment.start, children: items);
  }
}
