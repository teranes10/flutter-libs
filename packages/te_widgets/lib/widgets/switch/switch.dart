import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TSwitch extends StatefulWidget with TInputValueMixin<bool>, TFocusMixin, TInputValidationMixin<bool> {
  @override
  final bool? value;

  @override
  final ValueNotifier<bool>? valueNotifier;

  @override
  final ValueChanged<bool>? onValueChanged;

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

  // Switch specific properties
  final bool disabled;
  final Color? color;
  final TInputSize? size;

  const TSwitch({
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
  });

  @override
  State<TSwitch> createState() => _TSwitchState();
}

class _TSwitchState<T> extends State<TSwitch>
    with TInputValueStateMixin<bool, TSwitch>, TFocusStateMixin<TSwitch>, TInputValidationStateMixin<bool, TSwitch> {
  (double, double, double) _getSwitchSize() {
    switch (widget.size) {
      case TInputSize.sm:
        return (36, 22, 0.7);
      case TInputSize.md:
      case null:
        return (42, 25, 0.8);
      case TInputSize.lg:
        return (52, 32, 1.0);
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

  void _onSwitchChanged(bool? newValue) {
    newValue = !(currentValue ?? false);
    notifyValueChanged(newValue);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final exTheme = context.exTheme;
    final mColor = widget.color ?? exTheme.primary;
    final wTheme = context.getWidgetTheme(TColorType.solid, mColor);
    final (width, height, scale) = _getSwitchSize();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.disabled ? null : () => _onSwitchChanged(null),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: widget.disabled ? 0.6 : 1.0,
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Switch(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashRadius: 0,
                      value: currentValue ?? false,
                      onChanged: widget.disabled ? null : _onSwitchChanged,
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.white,
                      activeTrackColor: wTheme.container,
                      inactiveTrackColor: theme.surfaceDim,
                      trackOutlineWidth: WidgetStateProperty.all(0.1),
                      trackOutlineColor: WidgetStateProperty.all(theme.outlineVariant),
                    ),
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
