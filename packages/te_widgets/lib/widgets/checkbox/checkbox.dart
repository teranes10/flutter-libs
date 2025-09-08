import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TCheckbox extends StatefulWidget with TInputValueMixin<bool?>, TFocusMixin, TInputValidationMixin<bool?> {
  @override
  final bool? value;

  @override
  final ValueNotifier<bool?>? valueNotifier;

  @override
  final ValueChanged<bool?>? onValueChanged;

  @override
  final FocusNode? focusNode;

  @override
  final String? label;

  @override
  final bool isRequired;

  @override
  final List<String? Function(bool?)>? rules;

  @override
  final List<String>? errors;

  @override
  final Duration? validationDebounce;

  @override
  final bool? skipValidation;

  // Checkbox specific properties
  final bool disabled;
  final Color? color;
  final TInputSize? size;
  final bool tristate;

  const TCheckbox({
    super.key,
    this.value = false,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    this.label,
    this.isRequired = false,
    this.rules,
    this.errors,
    this.validationDebounce,
    this.skipValidation,
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
        return 0.9;
      case TInputSize.md:
      case null:
        return 1.0;
      case TInputSize.lg:
        return 1.2;
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final exTheme = context.exTheme;
    final mColor = widget.color ?? exTheme.primary;
    final wTheme = context.getWidgetTheme(TColorType.solid, mColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.disabled ? null : () => _onCheckboxChanged(null),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: widget.disabled ? 0.6 : 1.0,
                child: Transform.scale(
                  scale: _getCheckboxSize(),
                  child: Checkbox(
                    splashRadius: 0,
                    value: widget.value,
                    onChanged: widget.disabled ? null : _onCheckboxChanged,
                    activeColor: wTheme.container,
                    checkColor: wTheme.onContainer,
                    tristate: widget.tristate,
                    visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    side: BorderSide(color: hasErrors ? theme.error : (currentValue != false ? mColor : theme.outline), width: 1),
                  ),
                ),
              ),
              if (widget.label != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label!,
                  style: TextStyle(letterSpacing: 0.9, color: theme.onSurfaceVariant, fontSize: _getLabelFontSize()),
                ),
              ],
            ],
          ),
        ),
        buildValidationErrors(theme, errorsNotifier)
      ],
    );
  }
}
