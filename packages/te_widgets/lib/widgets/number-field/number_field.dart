import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Layout style for [TNumberField] stepper buttons.
enum TNumberStepperStyle {
  /// Both − and + after the value: `5 −+` (default).
  trailing,

  /// − before and + after the value: `− 5 +`.
  flanking,
}

/// A numeric input field with formatting and validation support.
///
/// `TNumberField` provides a specialized input for numeric values with:
/// - Support for both integer and decimal numbers
/// - Automatic formatting with decimal places
/// - Optional stepper buttons for increment/decrement
/// - Validation rules for min/max values and ranges
/// - Value binding with ValueNotifier
///
/// ## Basic Usage
///
/// ```dart
/// TNumberField<double>(
///   label: 'Price',
///   placeholder: 'Enter price',
///   onValueChanged: (value) => print('Price: \$value'),
/// )
/// ```
///
/// ## Integer Field
///
/// ```dart
/// TNumberField<int>(
///   label: 'Quantity',
///   placeholder: 'Enter quantity',
///   rules: [
///     Validations.minValue(1, 'Minimum 1'),
///     Validations.maxValue(100, 'Maximum 100'),
///   ],
/// )
/// ```
///
/// ## Flanking Stepper (− 5 +)
///
/// ```dart
/// TNumberField<int>(
///   label: 'Quantity',
///   value: 5,
///   stepperStyle: TNumberStepperStyle.flanking,
/// )
/// ```
///
/// ## With Decimal Places
///
/// ```dart
/// TNumberField<double>(
///   label: 'Amount',
///   theme: TNumberFieldTheme(decimals: 2),
///   onValueChanged: (value) => print('Amount: \$value'),
/// )
/// ```
///
/// Type parameter:
/// - [T]: The numeric type (int or double)
///
/// See also:
/// - [TTextField] for text input
/// - [Validations] for numeric validation rules
class TNumberField<T extends num?> extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<T>, TInputValidationMixin<T> {
  /// The label text displayed above the field.
  @override
  final String? label;

  /// An optional tag displayed next to the label.
  @override
  final String? tag;

  /// Helper text displayed below the field.
  @override
  final String? helperText;

  /// Placeholder text shown when the field is empty.
  @override
  final String? placeholder;

  /// The info text (optional).
  @override
  final String? info;

  /// Whether this field is required.
  @override
  final bool isRequired;

  /// Whether the field is disabled.
  @override
  final bool disabled;

  /// Whether the field should auto-focus.
  @override
  final bool autoFocus;

  /// Whether the field is read-only.
  @override
  final bool readOnly;

  /// Whether to show a clear button when the field has a value.
  @override
  final bool clearable;

  /// Custom theme for this number field.
  @override
  final TNumberFieldTheme? theme;

  /// Callback fired when the field is tapped.
  @override
  final VoidCallback? onTap;

  /// Custom focus node.
  @override
  final FocusNode? focusNode;

  /// Custom text editing controller.
  @override
  final TextEditingController? textController;

  /// The initial numeric value.
  @override
  final T? value;

  /// A ValueNotifier for two-way binding.
  @override
  final ValueNotifier<T?>? valueNotifier;

  /// Callback fired when the value changes.
  @override
  final ValueChanged<T?>? onValueChanged;

  /// Validation rules for the numeric value.
  @override
  final List<String? Function(T?)>? rules;

  /// Debounce duration for validation.
  @override
  final Duration? validationDebounce;

  /// Layout of the − / + stepper buttons.
  ///
  /// Defaults to [TNumberStepperStyle.trailing] (`5 −+`).
  /// Use [TNumberStepperStyle.flanking] for `− 5 +`.
  final TNumberStepperStyle stepperStyle;

  /// Minimum value allowed when using steppers or typing.
  ///
  /// When set, decrement stops at this value (e.g. `0` prevents negatives).
  final num? min;

  /// Maximum value allowed when using steppers or typing.
  final num? max;

  /// Creates a numeric input field.
  const TNumberField({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
    this.info,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.clearable = false,
    this.theme,
    this.onTap,
    this.focusNode,
    this.textController,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
    this.stepperStyle = TNumberStepperStyle.trailing,
    this.min,
    this.max,
  });

  @override
  State<TNumberField<T>> createState() => _TNumberFieldState<T>();
}

class _TNumberFieldState<T extends num?> extends State<TNumberField<T>>
    with
        TInputFieldStateMixin<TNumberField<T>>,
        TFocusStateMixin<TNumberField<T>>,
        TTextFieldStateMixin<TNumberField<T>>,
        TInputValueStateMixin<T, TNumberField<T>>,
        TInputValidationStateMixin<T, TNumberField<T>> {
  @override
  TNumberFieldTheme get wTheme => widget.theme ?? context.theme.numberFieldTheme;
  @override
  void onValueChanged(T? value, {bool initial = false, T? oldValue}) {
    super.onValueChanged(value, initial: initial, oldValue: oldValue);

    final wasEmpty = oldValue == null;
    final isEmpty = value != null;

    if (wasEmpty != isEmpty) {
      setState(() {});
    }
  }

  @override
  void onExternalValueChanged(T? value) {
    super.onExternalValueChanged(value);
    textController.text = wTheme.formatValue(value);
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);

    if (hasFocus) {
      if (T.toString().contains('double') && currentValue != null) {
        textController.text = currentValue!.toString();
      }
    } else {
      textController.text = wTheme.formatValue(currentValue);
    }
  }

  void _onValueChanged(String text) {
    final parsedValue = wTheme.parseValue<T>(text);
    final isInt = T.toString().contains('int');
    final value = (parsedValue == null && null is! T) ? (isInt ? 0 : 0.0) as T : parsedValue;
    final clamped = _clamp(value);
    if (clamped != value && clamped != null) {
      textController.text = wTheme.formatValue(clamped);
    }
    notifyValueChanged(clamped);
  }

  T? _clamp(T? value) {
    if (value == null) return null;
    final isInt = T.toString().contains('int');
    num result = value;
    if (widget.min != null && result < widget.min!) result = widget.min!;
    if (widget.max != null && result > widget.max!) result = widget.max!;
    return (isInt ? result.toInt() : result.toDouble()) as T;
  }

  void _changeValueBy(num delta) {
    final typeStr = T.toString();
    final isInt = typeStr.contains('int');
    final base = currentValue ?? (isInt ? 0 : 0.0) as T;
    final raw = isInt ? (base!.toInt() + delta.toInt()) as T : (base!.toDouble() + delta.toDouble()) as T;
    final newValue = _clamp(raw);

    textController.text = wTheme.formatValue(newValue);
    notifyValueChanged(newValue);
    setState(() {});
  }

  bool get _canDecrease {
    if (widget.disabled) return false;
    if (widget.min == null) return true;
    final base = currentValue ?? 0;
    return base > widget.min!;
  }

  bool get _canIncrease {
    if (widget.disabled) return false;
    if (widget.max == null) return true;
    final base = currentValue ?? 0;
    return base < widget.max!;
  }

  @override
  Widget build(BuildContext context) {
    final type = getValueType().type;

    if (widget.stepperStyle == TNumberStepperStyle.flanking) {
      return buildWrapper(child: _buildFlankingStepper(context, type));
    }

    return buildTextField(
      keyboardType: type.keyboardType,
      inputFormatters: type.getInputFormatters(wTheme.decimals),
      onValueChanged: _onValueChanged,
      hasValue: currentValue != null,
      onClear: () {
        textController.clear();
        notifyValueChanged(null);
      },
      beforePostWidget: wTheme.stepperBuilder?.call(context, _changeValueBy, _canIncrease, _canDecrease),
    );
  }

  Widget _buildFlankingStepper(BuildContext context, BaseValueType type) {
    final states = this.states;
    final borderRadius = wTheme.borderRadius.resolve(states);
    final borderColor = wTheme.borderColor.resolve(states);
    final borderWidth = wTheme.borderWidth.resolve(states);
    final background = wTheme.backgroundColor.resolve(states);
    final textStyle = wTheme.textStyle.resolve(states).copyWith(fontSize: wTheme.fieldFontSize);
    final decrease = wTheme.decreaseButtonBuilder;
    final increase = wTheme.increaseButtonBuilder;

    return Align(
      alignment: Alignment.centerLeft,
      child: Opacity(
        opacity: widget.disabled ? 0.5 : 1,
        child: Container(
          height: wTheme.fieldHeight,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (decrease != null)
                decrease(() => _changeValueBy(-wTheme.decrement), _canDecrease),
              SizedBox(
                width: 48,
                child: TextField(
                  controller: textController,
                  focusNode: focusNode,
                  enabled: !widget.disabled,
                  readOnly: widget.readOnly,
                  autofocus: widget.autoFocus,
                  textAlign: TextAlign.center,
                  style: textStyle,
                  keyboardType: type.keyboardType,
                  inputFormatters: type.getInputFormatters(wTheme.decimals),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: _onValueChanged,
                ),
              ),
              if (increase != null)
                increase(() => _changeValueBy(wTheme.increment), _canIncrease),
            ],
          ),
        ),
      ),
    );
  }
}
