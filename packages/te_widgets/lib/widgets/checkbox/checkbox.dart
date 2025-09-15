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
  final Duration? validationDebounce;

  // Checkbox specific properties
  final bool autoFocus;
  final bool disabled;
  final Color? color;
  final TInputSize? size;
  final bool tristate;

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
