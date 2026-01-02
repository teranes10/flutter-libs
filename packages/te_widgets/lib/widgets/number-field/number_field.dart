import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

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
class TNumberField<T extends num> extends StatefulWidget
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

  /// Creates a numeric input field.
  const TNumberField({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
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
  });

  @override
  State<TNumberField<T>> createState() => _TNumberFieldState<T>();
}

class _TNumberFieldState<T extends num> extends State<TNumberField<T>>
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
    print('vv: $value, $oldValue : $currentValue');
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

    if (T != double) return;

    if (hasFocus) {
      textController.text = currentValue?.toString() ?? '';
    } else if (wTheme.decimals != null) {
      textController.text = currentValue?.toStringAsFixed(wTheme.decimals!) ?? '';
    }
  }

  void _onValueChanged(String text) {
    final parsedValue = wTheme.parseValue<T>(text);
    notifyValueChanged(parsedValue);
  }

  void _changeValueBy(num delta) {
    final base = currentValue ?? (T == int ? 0 : 0.0) as T;
    final newValue = T == int ? (base.toInt() + delta.toInt()) as T : (base.toDouble() + delta.toDouble()) as T;

    textController.text = wTheme.formatValue(newValue);
    notifyValueChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final type = getValueType().type;
    final disabled = widget.disabled;

    return buildContainer(
      showClearButton: currentValue != null,
      onClear: () {
        textController.clear();
        notifyValueChanged(null);
      },
      postWidget: wTheme.stepperBuilder?.call(context, _changeValueBy, !disabled, !disabled),
      child: buildTextField(
        keyboardType: type.keyboardType,
        inputFormatters: type.getInputFormatters(wTheme.decimals),
        onValueChanged: _onValueChanged,
      ),
    );
  }
}
