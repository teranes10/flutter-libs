import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A radio button input with validation and theming support.
///
/// `TRadio` provides a customizable radio button with:
/// - Optional label text
/// - Validation support
/// - Custom colors and sizes
/// - Disabled state
/// - Value binding with ValueNotifier
///
/// ## Basic Usage
///
/// ```dart
/// TRadio<String>(
///   value: 'option1',
///   groupValue: selectedValue,
///   label: 'Option 1',
///   onValueChanged: (value) => print('Selected: $value'),
/// )
/// ```
///
/// See also:
/// - [TRadioGroup] for multiple radio buttons
/// - [TCheckbox] for multiple selection
class TRadio<T> extends StatefulWidget with TInputValueMixin<T?>, TFocusMixin, TInputValidationMixin<T?> {
  /// The value this radio button represents.
  final T radioValue;

  /// The currently selected value in the group.
  @override
  final T? value;

  /// A ValueNotifier for two-way binding.
  @override
  final ValueNotifier<T?>? valueNotifier;

  /// Callback fired when the value changes.
  @override
  final ValueChanged<T?>? onValueChanged;

  /// Custom focus node.
  @override
  final FocusNode? focusNode;

  /// Label text displayed next to the radio button.
  @override
  final String? label;

  /// Whether this radio button is required.
  @override
  final bool isRequired;

  /// Validation rules for the radio value.
  @override
  final List<String? Function(T?)>? rules;

  /// Debounce duration for validation.
  @override
  final Duration? validationDebounce;

  /// Whether the radio button should auto-focus.
  final bool autoFocus;

  /// Whether the radio button is disabled.
  final bool disabled;

  /// Custom color for the radio button.
  final Color? color;

  /// The size of the radio button.
  ///
  /// Defaults to [TInputSize.md].
  final TInputSize? size;

  /// Creates a radio button input.
  const TRadio({
    super.key,
    required this.radioValue,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    this.label,
    this.isRequired = false,
    this.rules,
    this.validationDebounce,
    this.autoFocus = false,
    this.disabled = false,
    this.color,
    this.size = TInputSize.md,
  });

  @override
  State<TRadio<T>> createState() => _TRadioState<T>();
}

class _TRadioState<T> extends State<TRadio<T>>
    with TInputValueStateMixin<T?, TRadio<T>>, TFocusStateMixin<TRadio<T>>, TInputValidationStateMixin<T?, TRadio<T>> {
  double _getRadioSize() {
    switch (widget.size) {
      case TInputSize.xs:
        return 1.0;
      case TInputSize.sm:
        return 1.1;
      case TInputSize.md:
      case null:
        return 1.2;
      case TInputSize.lg:
        return 1.3;
    }
  }

  double _getLabelFontSize() {
    switch (widget.size) {
      case TInputSize.xs:
        return 11.0;
      case TInputSize.sm:
        return 12.0;
      case TInputSize.md:
      case null:
        return 14.0;
      case TInputSize.lg:
        return 16.0;
    }
  }

  void _onRadioChanged(T? newValue) {
    if (!isFocused) {
      focusNode.requestFocus();
    }

    notifyValueChanged(newValue);
    setState(() {});
  }

  Widget buildValidationErrors(ColorScheme colors, ValueNotifier<List<String>> errorsNotifier) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: errorsNotifier,
      builder: (context, validationErrors, child) {
        if (validationErrors.isEmpty) return const SizedBox.shrink();

        return Column(
          spacing: 4.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: validationErrors.map((error) => Text('• $error', style: TextStyle(fontSize: 12.0, color: colors.error))).toList(),
        );
      },
    );
  }

  Color getBorderColor(ColorScheme colors, bool isFocused, bool hasErrors, bool disabled) {
    if (disabled) return colors.outlineVariant;
    if (hasErrors) return colors.error;
    return widget.color ?? (isFocused ? colors.primary : colors.outline);
  }

  List<BoxShadow>? getShadow(ColorScheme colors, bool isFocused) {
    return isFocused ? [BoxShadow(color: colors.shadow, blurRadius: 4.0, spreadRadius: 1.5, offset: const Offset(0, 0))] : null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final color = widget.color ?? theme.primary;
    final wTheme = context.getWidgetTheme(TVariant.solid, color);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.disabled ? null : () => _onRadioChanged(widget.radioValue),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: widget.disabled ? 0.6 : 1.0,
                child: Transform.scale(
                  scale: _getRadioSize(),
                  child: Container(
                    decoration: BoxDecoration(boxShadow: getShadow(colors, isFocused), shape: BoxShape.circle),
                    // ignore: deprecated_member_use
                    child: Radio<T>(
                      focusNode: focusNode,
                      autofocus: widget.autoFocus,
                      splashRadius: 0,
                      value: widget.radioValue,
                      // ignore: deprecated_member_use
                      groupValue: currentValue,
                      // ignore: deprecated_member_use
                      onChanged: widget.disabled ? null : _onRadioChanged,
                      activeColor: wTheme.container,
                      visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
                      side: BorderSide(color: getBorderColor(colors, isFocused, hasErrors, widget.disabled), width: 1),
                    ),
                  ),
                ),
              ),
              if (widget.label != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label!,
                  style: TextStyle(letterSpacing: 0.9, color: colors.onSurfaceVariant, fontSize: _getLabelFontSize()),
                ),
              ],
            ],
          ),
        ),
        buildValidationErrors(colors, errorsNotifier)
      ],
    );
  }
}
