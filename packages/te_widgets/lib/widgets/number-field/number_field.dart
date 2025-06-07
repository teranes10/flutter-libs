import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';

class TNumberField<T extends num> extends StatefulWidget with TInputFieldMixin, TInputValueMixin<T>, TFocusMixin, TInputValidationMixin<T> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool? isRequired, disabled;
  @override
  final TInputSize? size;
  @override
  final TInputColor? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final Widget? preWidget, postWidget;
  @override
  final List<String? Function(T?)>? rules;
  @override
  final List<String>? errors;
  @override
  final Duration? validationDebounce;
  @override
  final T? value;
  @override
  final ValueNotifier<T>? valueNotifier;
  @override
  final ValueChanged<T>? onValueChanged;
  @override
  final FocusNode? focusNode;

  // NumberField specific properties
  final T? min, max, increment, decrement;
  final int? decimals;
  final bool showSteppers;

  const TNumberField({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.isRequired,
    this.disabled,
    this.size,
    this.color,
    this.boxDecoration,
    this.preWidget,
    this.postWidget,
    this.rules,
    this.errors,
    this.validationDebounce,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    this.min,
    this.max,
    this.increment,
    this.decrement,
    this.decimals,
    this.showSteppers = true,
  });

  @override
  State<TNumberField<T>> createState() => _TNumberFieldState<T>();
}

class _TNumberFieldState<T extends num> extends State<TNumberField<T>>
    with TInputValueStateMixin<T, TNumberField<T>>, TFocusStateMixin<TNumberField<T>>, TInputValidationStateMixin<T, TNumberField<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(currentValue));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void onExternalValueChanged(T value) {
    super.onExternalValueChanged(value);
    _controller.text = _formatValue(value);
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);

    if (T != double) return;

    final raw = _controller.text.trim();
    final parsed = double.tryParse(raw) ?? 0.0;
    final isZero = parsed == 0.0;
    final hasDecimals = parsed % 1 != 0;
    String formattedValue = '';
    if (!isZero) {
      formattedValue = hasFocus ? (hasDecimals ? parsed.toString() : parsed.toInt().toString()) : parsed.toStringAsFixed(2);
    }

    _controller.text = formattedValue;
  }

  void _onValueChanged(String text) {
    final parsed = _parseValue(text);
    if (parsed != currentValue) {
      final constrained = _applyConstraints(parsed);
      if (constrained != null) notifyValueChanged(constrained);
    }
  }

  String _formatValue(T? value) {
    if (value == null) return '';

    if (T == int) {
      return value.toInt().toString();
    } else {
      if (widget.decimals != null) {
        return value.toStringAsFixed(widget.decimals!);
      }

      if (value is double && value == value.toInt()) {
        return value.toInt().toString();
      }
      return value.toString();
    }
  }

  T? _parseValue(String text) {
    if (text.trim().isEmpty) return null;

    try {
      if (T == int) {
        final parsed = int.tryParse(text);
        return parsed as T?;
      } else {
        final parsed = double.tryParse(text);
        return parsed as T?;
      }
    } catch (e) {
      return null;
    }
  }

  T? _applyConstraints(T? value) {
    if (value == null) return null;

    T constrained = value;

    if (widget.min != null && value.compareTo(widget.min!) < 0) {
      constrained = widget.min!;
    }
    if (widget.max != null && value.compareTo(widget.max!) > 0) {
      constrained = widget.max!;
    }

    return constrained;
  }

  void _changeValueBy(num delta) {
    final base = currentValue ?? (T == int ? 0 : 0.0) as T;
    final newValue = T == int ? (base.toInt() + delta.toInt()) as T : (base.toDouble() + delta.toDouble()) as T;

    final constrained = _applyConstraints(newValue);
    if (constrained != null) {
      _controller.text = _formatValue(constrained);
      notifyValueChanged(constrained);
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    if (T == int) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
        _IntegerInputFormatter(),
      ];
    } else {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
        _DecimalInputFormatter(decimals: widget.decimals),
      ];
    }
  }

  TextInputType _getKeyboardType() {
    if (T == int) {
      return const TextInputType.numberWithOptions(signed: true, decimal: false);
    } else {
      return const TextInputType.numberWithOptions(signed: true, decimal: true);
    }
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onPressed, bool enabled) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(2),
      mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget? _buildPostWidget() {
    if (!widget.showSteppers) return null;

    final disabled = widget.disabled == true;
    final canIncrease = !disabled && (widget.max == null || currentValue == null || currentValue!.compareTo(widget.max!) < 0);
    final canDecrease = !disabled && (widget.min == null || currentValue == null || currentValue!.compareTo(widget.min!) > 0);

    final steppers = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepperButton(
          Icons.remove,
          () => _changeValueBy(-(widget.decrement ?? (T == int ? 1 : 1.0))),
          canDecrease,
        ),
        const SizedBox(width: 4),
        _buildStepperButton(
          Icons.add,
          () => _changeValueBy(widget.increment ?? (T == int ? 1 : 1.0)),
          canIncrease,
        ),
      ],
    );

    return steppers;
  }

  @override
  Widget build(BuildContext context) {
    return widget.buildContainer(
      isFocused: isFocused,
      hasErrors: hasErrors,
      errorsNotifier: errorsNotifier,
      postWidget: _buildPostWidget(),
      child: TextField(
        controller: _controller,
        focusNode: focusNode,
        enabled: widget.disabled != true,
        keyboardType: _getKeyboardType(),
        inputFormatters: _getInputFormatters(),
        textInputAction: TextInputAction.next,
        cursorHeight: widget.fontSize + 2,
        textAlignVertical: TextAlignVertical.center,
        style: widget.getTextStyle(),
        decoration: widget.getInputDecoration(),
        onChanged: _onValueChanged,
      ),
    );
  }
}

class _IntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final regex = RegExp(r'^-?\d*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    return newValue;
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  final int? decimals;

  _DecimalInputFormatter({this.decimals});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final regex = RegExp(r'^-?\d*\.?\d*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    if (decimals != null && newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      if (parts.length == 2 && parts[1].length > decimals!) {
        return oldValue;
      }
    }

    return newValue;
  }
}
