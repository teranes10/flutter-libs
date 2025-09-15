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
  final Duration? validationDebounce;

  // Switch specific properties
  final bool autoFocus;
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
    this.validationDebounce,
    this.autoFocus = false,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final mColor = widget.color ?? theme.primary;
    final wTheme = context.getWidgetTheme(TVariant.solid, mColor);
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
                      focusNode: focusNode,
                      autofocus: widget.autoFocus,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashRadius: 0,
                      value: currentValue ?? false,
                      onChanged: widget.disabled ? null : _onSwitchChanged,
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.white,
                      activeTrackColor: wTheme.container,
                      inactiveTrackColor: colors.surfaceDim,
                      trackOutlineWidth: WidgetStateProperty.all(0.1),
                      trackOutlineColor: WidgetStateProperty.all(colors.outlineVariant),
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
