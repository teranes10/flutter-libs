import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Visual presentation of a [TNumberField].
enum TNumberFieldVariant {
  /// Standard single-line input (optionally with steppers).
  field,

  /// Handheld quantity stepper: large round -/+ buttons around a big, directly
  /// editable value. Meant for confirm-quantity steps on touch devices.
  quantity,
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

  /// Size of the input field. Defaults to theme size.
  final TInputSize? size;

  /// Whether to split the stepper buttons (minus in pre, plus in post).
  final bool? splitStepper;

  /// Presentation of the field. Defaults to [TNumberFieldVariant.field].
  final TNumberFieldVariant variant;

  /// Lowest allowed value. Steppers and the [TNumberFieldVariant.quantity]
  /// variant clamp to it.
  final num? min;

  /// Highest allowed value. Steppers and the [TNumberFieldVariant.quantity]
  /// variant clamp to it. Also enables the "Max" preset chip.
  final num? max;

  /// Quick-add chips (`+1`, `+5`, ...) shown under the quantity variant.
  final List<num> presets;

  /// Unit caption (e.g. `pcs`) shown under the quantity variant's value.
  final String? unit;

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
    this.info,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.clearable = false,
    this.size,
    this.theme,
    this.splitStepper,
    this.variant = TNumberFieldVariant.field,
    this.min,
    this.max,
    this.presets = const [],
    this.unit,
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
      if (currentValue == 0 || currentValue == 0.0) {
        textController.text = '';
      } else if (T.toString().contains('double')) {
        textController.text = currentValue?.toString() ?? '';
      }
    } else {
      _clampAndCommit();
    }
  }

  String _formatValue(T? val) {
    if (val == null) return '';
    if (T.toString().contains('double') && wTheme.decimals != null) {
      return val.toStringAsFixed(wTheme.decimals!);
    }
    final formatted = wTheme.formatValue(val);
    if (formatted.isEmpty && val == 0) {
      return '0';
    }
    return formatted;
  }

  void _clampAndCommit() {
    final isInt = T.toString().contains('int');
    final textVal = NumberRangeInputFormatter.parseNormalized(textController.text.trim());
    final valToClamp = textVal ?? currentValue;

    if (valToClamp == null) {
      if ((null is! T || widget.variant == TNumberFieldVariant.quantity) && widget.min != null) {
        final clamped = _clamp(0);
        final newValue = (isInt ? clamped.toInt() : clamped.toDouble()) as T;
        textController.text = _formatValue(newValue);
        notifyValueChanged(newValue);
        setState(() {});
      }
      return;
    }

    final clamped = _clamp(valToClamp);
    final newValue = (isInt ? clamped.toInt() : clamped.toDouble()) as T;
    if (newValue != currentValue) {
      notifyValueChanged(newValue);
    }
    textController.text = _formatValue(newValue);
    setState(() {});
  }

  void _onValueChanged(String text) {
    final parsedValue = wTheme.parseValue<T>(text);
    final isInt = T.toString().contains('int');
    T? value = (parsedValue == null && null is! T) ? (isInt ? 0 : 0.0) as T : parsedValue;

    if (widget.max != null && value != null && value > widget.max!) {
      value = (isInt ? widget.max!.toInt() : widget.max!.toDouble()) as T;
    }

    notifyValueChanged(value);
  }

  void _changeValueBy(num delta) {
    _step(delta);
    focusNode.unfocus();
  }

  /// Adds [delta] to the current value, clamped to [TNumberField.min]/[TNumberField.max].
  void _step(num delta) {
    final isInt = T.toString().contains('int');
    num next = (currentValue ?? 0) + delta;
    next = _clamp(next);
    final newValue = (isInt ? next.toInt() : next.toDouble()) as T;
    if (newValue == currentValue) return;

    textController.text = wTheme.formatValue(newValue);
    notifyValueChanged(newValue);
    TFeedback.step();
    setState(() {});
  }

  num _clamp(num value) {
    if (widget.min != null && value < widget.min!) return widget.min!;
    if (widget.max != null && value > widget.max!) return widget.max!;
    return value;
  }

  void _setTo(num value) {
    _step(value - (currentValue ?? 0));
  }

  Widget _buildQuantity(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final interactive = !widget.disabled && !widget.readOnly;
    final value = currentValue ?? 0;
    final canDecrease = interactive && (widget.min == null || value > widget.min!);
    final canIncrease = interactive && (widget.max == null || value < widget.max!);
    final type = getValueType().type;
    final isInt = T.toString().contains('int');

    final effectiveInputSize = widget.size ?? wTheme.size;
    final btnSize = TSize.fromInputSize(effectiveInputSize);
    final chipSize = (btnSize * 0.8).copyWith(
      hPad: (btnSize.minH * 0.8) * (16.0 / 48.0),
      vPad: (btnSize.minH * 0.8) * (8.0 / 48.0),
      font: (btnSize.font * 0.85).clamp(11.0, 16.0),
      radius: (btnSize.minH * 0.8) / 2,
      spacing: 6.0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                widget.label!,
                textAlign: TextAlign.start,
                style: textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
        Row(
          children: [
            _QuantityButton(
              icon: HugeIcons.strokeRoundedRemove01,
              enabled: canDecrease,
              size: btnSize,
              onStep: () => _step(-wTheme.decrement),
            ),
            Expanded(
              child: TextField(
                controller: textController,
                focusNode: focusNode,
                enabled: interactive,
                textAlign: TextAlign.center,
                keyboardType: type.keyboardType,
                textInputAction: wTheme.textInputAction ?? TextInputAction.done,
                inputFormatters: [
                  ...type.getInputFormatters(wTheme.decimals),
                  NumberRangeInputFormatter(
                    min: widget.min,
                    max: widget.max,
                    isInt: isInt,
                  ),
                ],
                onChanged: _onValueChanged,
                onSubmitted: (_) {
                  _clampAndCommit();
                  focusNode.unfocus();
                },
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.placeholder ?? '0',
                ),
              ),
            ),
            _QuantityButton(
              icon: HugeIcons.strokeRoundedAdd01,
              enabled: canIncrease,
              size: btnSize,
              onStep: () => _step(wTheme.increment),
            ),
          ],
        ),
        if (widget.unit != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(widget.unit!, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ),
        if (errors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(errors.first, textAlign: TextAlign.center, style: textTheme.bodySmall?.copyWith(color: cs.error)),
          ),
        if (interactive && (widget.presets.isNotEmpty || widget.max != null))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in widget.presets)
                  TChip(
                    text: '+${preset % 1 == 0 ? preset.toInt() : preset}',
                    size: chipSize,
                    onTap: () => _step(preset),
                  ),
                if (widget.max != null)
                  TChip(
                    text: 'Max',
                    size: chipSize,
                    onTap: () => _setTo(widget.max!),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == TNumberFieldVariant.quantity) return _buildQuantity(context);

    final type = getValueType().type;
    final isInt = T.toString().contains('int');
    final disabled = widget.disabled;
    final isSplit = widget.splitStepper ?? wTheme.splitStepper ?? false;

    return buildTextField(
      keyboardType: type.keyboardType,
      textInputAction: wTheme.textInputAction ?? TextInputAction.done,
      inputFormatters: [
        ...type.getInputFormatters(wTheme.decimals),
        NumberRangeInputFormatter(
          min: widget.min,
          max: widget.max,
          isInt: isInt,
        ),
      ],
      onValueChanged: _onValueChanged,
      onSubmitted: (_) {
        _clampAndCommit();
        focusNode.unfocus();
      },
      hasValue: currentValue != null,
      onClear: () {
        textController.clear();
        notifyValueChanged(null);
      },
      textAlign: isSplit ? TextAlign.center : TextAlign.start,
      textAlignVertical: isSplit ? TextAlignVertical.center : null,
      labelAlignment: isSplit ? FloatingLabelAlignment.center : null,
      beforePreWidget: isSplit && wTheme.decreaseButtonBuilder != null
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: wTheme.decreaseButtonBuilder!(() => _changeValueBy(-wTheme.decrement), !disabled),
            )
          : null,
      beforePostWidget: isSplit
          ? (wTheme.increaseButtonBuilder != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: wTheme.increaseButtonBuilder!(() => _changeValueBy(wTheme.increment), !disabled),
                )
              : null)
          : wTheme.stepperBuilder?.call(context, _changeValueBy, !disabled, !disabled),
    );
  }
}

/// Large round stepper button used by [TNumberFieldVariant.quantity].
///
/// Tap steps once; press-and-hold repeats and accelerates.
class _QuantityButton extends StatefulWidget {
  final dynamic icon;
  final bool enabled;
  final VoidCallback onStep;
  final TSize size;

  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onStep,
    required this.size,
  });

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
  Timer? _timer;
  int _ticks = 0;

  void _startRepeating() {
    _ticks = 0;
    _tick();
  }

  void _tick() {
    if (!widget.enabled) {
      _stopRepeating();
      return;
    }
    widget.onStep();
    _ticks++;
    _timer = Timer(Duration(milliseconds: _ticks > 12 ? 60 : 140), _tick);
  }

  void _stopRepeating() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopRepeating();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = widget.enabled;
    final size = widget.size;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? widget.onStep : null,
      onLongPressStart: enabled ? (_) => _startRepeating() : null,
      onLongPressEnd: (_) => _stopRepeating(),
      onLongPressCancel: _stopRepeating,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: size.minW,
          height: size.minH,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? cs.primaryContainer : cs.surfaceContainerHighest,
          ),
          child: TIcon.raw(
            widget.icon,
            size: size.icon,
            color: enabled ? cs.onPrimaryContainer : cs.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }
}
