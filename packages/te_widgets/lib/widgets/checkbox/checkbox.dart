import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A checkbox input with validation and theming support.
///
/// `TCheckbox` provides a customizable checkbox with:
/// - Optional label text
/// - Validation support
/// - Tristate mode (true/false/null)
/// - Custom colors and sizes
/// - Disabled state
/// - Value binding with ValueNotifier
///
/// ## Basic Usage
///
/// ```dart
/// TCheckbox(
///   label: 'Accept terms and conditions',
///   onValueChanged: (value) => print('Checked: \$value'),
/// )
/// ```
///
/// ## With Validation
///
/// ```dart
/// TCheckbox(
///   label: 'I agree to the terms',
///   isRequired: true,
///   rules: [
///     (value) => value == true ? null : 'You must accept the terms',
///   ],
/// )
/// ```
///
/// ## Tristate Checkbox
///
/// ```dart
/// TCheckbox(
///   label: 'Select all',
///   tristate: true,
///   onValueChanged: (value) {
///     // value can be true, false, or null
///     print('State: \$value');
///   },
/// )
/// ```
///
/// See also:
/// - [TCheckboxGroup] for multiple checkboxes
/// - [TRadio] for single selection
class TCheckbox extends StatefulWidget with TInputValueMixin<bool?>, TFocusMixin, TInputValidationMixin<bool?> {
  /// The current value of the checkbox.
  @override
  final bool? value;

  /// A ValueNotifier for two-way binding.
  @override
  final ValueNotifier<bool?>? valueNotifier;

  /// Callback fired when the value changes.
  @override
  final ValueChanged<bool?>? onValueChanged;

  /// Custom focus node.
  @override
  final FocusNode? focusNode;

  /// Label text displayed next to the checkbox.
  @override
  final String? label;

  /// Whether this checkbox is required.
  @override
  final bool isRequired;

  /// Validation rules for the checkbox value.
  @override
  final List<String? Function(bool?)>? rules;

  /// Debounce duration for validation.
  @override
  final Duration? validationDebounce;

  /// Whether the checkbox should auto-focus.
  final bool autoFocus;

  /// Whether the checkbox is disabled.
  final bool disabled;

  /// Custom color for the checkbox.
  final Color? color;

  /// The size of the checkbox.
  ///
  /// Defaults to [TInputSize.md].
  final TInputSize? size;

  /// Whether to enable tristate mode.
  ///
  /// When true, the checkbox can have three states: true, false, or null.
  /// Defaults to false.
  final bool tristate;

  /// Creates a checkbox input.
  const TCheckbox({
    super.key,
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
    this.tristate = false,
  });

  @override
  State<TCheckbox> createState() => _TCheckboxState();
}

class _TCheckboxState<T> extends State<TCheckbox>
    with TInputValueStateMixin<bool?, TCheckbox>, TFocusStateMixin<TCheckbox>, TInputValidationStateMixin<bool?, TCheckbox> {
  double _getCheckboxSize() {
    switch (widget.size) {
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
      case TInputSize.sm:
        return 12.0;
      case TInputSize.md:
      case null:
        return 14.0;
      case TInputSize.lg:
        return 16.0;
    }
  }

  void _onCheckboxChanged(bool? newValue) {
    if (!isFocused) {
      focusNode.requestFocus();
    }

    if (widget.tristate) {
      final currentBool = currentValue;
      if (currentBool == null) {
        newValue = false;
      } else if (currentBool == false) {
        newValue = true;
      } else {
        newValue = null;
      }
    } else {
      newValue = !(currentValue ?? false);
    }

    notifyValueChanged(newValue);
    setState(() {});
  }

  Widget buildValidationErrors(ColorScheme colors, ValueNotifier<List<String>> errorsNotifier) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: errorsNotifier,
      builder: (context, validationErrors, child) {
        if (validationErrors.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: validationErrors.map((error) => Text('• $error', style: TextStyle(fontSize: 12.0, color: colors.error))).toList(),
          ),
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
          onTap: widget.disabled ? null : () => _onCheckboxChanged(null),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: widget.disabled ? 0.6 : 1.0,
                child: Transform.scale(
                  scale: _getCheckboxSize(),
                  child: Container(
                    decoration: BoxDecoration(boxShadow: getShadow(colors, isFocused), borderRadius: BorderRadius.circular(7)),
                    child: Checkbox(
                      focusNode: focusNode,
                      autofocus: widget.autoFocus,
                      splashRadius: 0,
                      value: currentValue ?? (widget.tristate ? null : false),
                      onChanged: widget.disabled ? null : _onCheckboxChanged,
                      activeColor: wTheme.container,
                      checkColor: wTheme.onContainer,
                      tristate: widget.tristate,
                      visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
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
