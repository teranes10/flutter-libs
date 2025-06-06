import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/text-field/text_field.dart';
import 'package:te_widgets/widgets/text-field/text_field_mixin.dart';
import 'package:te_widgets/widgets/text-field/validation_mixin.dart';

class TNumberField<T extends num> extends StatefulWidget with TTextFieldMixin, TValidationMixin<T> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool? required, disabled;
  @override
  final TTextFieldSize? size;
  @override
  final TTextFieldColor? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final List<String Function(T?)>? rules;

  final T? value, min, max, increment, decrement;
  final int? decimals;
  final ValueChanged<T?>? onChanged;

  const TNumberField({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.required,
    this.disabled,
    this.size,
    this.color,
    this.boxDecoration,
    this.rules,
    this.value,
    this.min,
    this.max,
    this.increment,
    this.decrement,
    this.decimals,
    this.onChanged,
  });

  @override
  State<TNumberField> createState() => _TNumberFieldState<T>();
}

class _TNumberFieldState<T extends num> extends State<TNumberField<T>> {
  late final TextEditingController _controller;
  T? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = TextEditingController(text: _formatValue(_currentValue));
  }

  @override
  void didUpdateWidget(covariant TNumberField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value;
      _controller.text = _formatValue(_currentValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(T? value) {
    if (value == null) return '';
    if (widget.decimals != null) {
      return value.toStringAsFixed(widget.decimals!);
    }
    if (value is double && value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  T? _parseValue(String text) {
    if (text.trim().isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null) return null;

    if (T == int) return parsed.toInt() as T;
    return parsed as T;
  }

  void _onTextChanged(String value) {
    final parsed = _parseValue(value);
    setState(() => _currentValue = parsed);
    widget.onChanged?.call(_currentValue);
  }

  void _setValue(T? newValue) {
    T? constrained = newValue;

    if (newValue != null) {
      if (widget.min != null && newValue.compareTo(widget.min!) < 0) {
        constrained = widget.min;
      }
      if (widget.max != null && newValue.compareTo(widget.max!) > 0) {
        constrained = widget.max;
      }
    }

    setState(() {
      _currentValue = constrained;
      _controller.text = _formatValue(constrained);
    });

    widget.onChanged?.call(_currentValue);
  }

  void _changeValueBy(num delta) {
    final base = _currentValue ?? (T == int ? 0 : 0.0) as T;
    final newValue = T == int ? (base.toInt() + delta.toInt()) as T : (base.toDouble() + delta.toDouble()) as T;
    _setValue(newValue);
  }

  String _validateInput(String input) {
    final regex = RegExp(r'^-?\d*\.?\d*$');
    return regex.hasMatch(input) ? input : _controller.text;
  }

  Widget _numberButton(IconData icon, VoidCallback onPressed, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: enabled ? Colors.transparent : Colors.grey.shade100,
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.disabled == true;
    final canIncrease = !disabled && (widget.max == null || _currentValue == null || _currentValue! < widget.max!);
    final canDecrease = !disabled && (widget.min == null || _currentValue == null || _currentValue! > widget.min!);

    return TTextField(
      label: widget.label,
      tag: widget.tag,
      placeholder: widget.placeholder,
      helperText: widget.helperText,
      message: widget.message,
      required: widget.required,
      disabled: disabled,
      size: widget.size,
      color: widget.color,
      controller: _controller,
      formatter: _validateInput,
      rules: widget.rules?.map((rule) {
        return (String? value) => rule(_parseValue(value ?? ''));
      }).toList(),
      onChanged: _onTextChanged,
      postWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _numberButton(Icons.remove, () {
              _changeValueBy(-(widget.decrement ?? (T == int ? 1 : 1.0)));
            }, canDecrease),
            const SizedBox(width: 4),
            _numberButton(Icons.add, () {
              _changeValueBy(widget.increment ?? (T == int ? 1 : 1.0));
            }, canIncrease),
          ],
        ),
      ),
    );
  }
}
