import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A toggle switch input with validation support.
///
/// `TSwitch` provides a Material Design switch with:
/// - Optional label text
/// - Validation support
/// - Custom colors and sizes
/// - Disabled state
/// - Value binding with ValueNotifier
///
/// ## Basic Usage
///
/// ```dart
/// TSwitch(
///   label: 'Enable notifications',
///   value: true,
///   onValueChanged: (value) => print('Switch: \$value'),
/// )
/// ```
///
/// ## With ValueNotifier
///
/// ```dart
/// final notificationsEnabled = ValueNotifier<bool>(false);
///
/// TSwitch(
///   label: 'Notifications',
///   valueNotifier: notificationsEnabled,
/// )
/// ```
///
/// See also:
/// - [TCheckbox] for checkbox input
class TSwitch extends StatefulWidget with TInputFieldMixin, TInputValueMixin<bool>, TFocusMixin, TInputValidationMixin<bool> {
  /// The current value of the switch.
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

  /// Label text displayed next to the switch.
  @override
  final String? label;

  /// An optional tag displayed next to the label.
  @override
  final String? tag;

  /// Helper text displayed below the field.
  @override
  final String? helperText;

  /// The info text (optional).
  @override
  final String? info;

  /// Whether this switch is required.
  @override
  final bool isRequired;

  /// Validation rules for the switch value.
  @override
  final List<String? Function(bool?)>? rules;

  /// Debounce duration for validation.
  @override
  final Duration? validationDebounce;

  /// Whether the switch should auto-focus.
  final bool autoFocus;

  /// Whether the switch is disabled.
  @override
  final bool disabled;

  /// Custom color for the switch.
  final Color? color;

  /// The size of the switch.
  final TInputSize? size;

  @override
  final bool clearable = false;

  @override
  final TInputFieldTheme? theme;

  @override
  final VoidCallback? onTap = null;

  const TSwitch({
    super.key,
    this.value = false,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    this.label,
    this.tag,
    this.helperText,
    this.info,
    this.isRequired = false,
    this.rules,
    this.validationDebounce,
    this.autoFocus = false,
    this.disabled = false,
    this.color,
    this.size = TInputSize.md,
    this.theme,
  });

  @override
  State<TSwitch> createState() => _TSwitchState();
}

class _TSwitchState<T> extends State<TSwitch>
    with TInputValueStateMixin<bool, TSwitch>, TFocusStateMixin<TSwitch>, TInputValidationStateMixin<bool, TSwitch>, TInputFieldStateMixin<TSwitch> {
  (double, double, double) _getSwitchSize() {
    switch (widget.size) {
      case TInputSize.xs:
        return (26, 16, 0.5);
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

  void _onSwitchChanged(bool? newValue) {
    newValue = !(currentValue ?? false);
    notifyValueChanged(newValue);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final mColor = widget.color ?? theme.primary;
    final widgetTheme = context.getWidgetTheme(TVariant.solid, mColor);
    final (width, height, scale) = _getSwitchSize();

    final isLabelAbove = wTheme.labelPosition == TLabelPosition.aboveField;
    final showLabelOnRight = widget.label != null && !isLabelAbove;

    final switchWidget = Opacity(
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
            activeThumbColor: Colors.white,
            inactiveThumbColor: Colors.white,
            activeTrackColor: widgetTheme.container,
            inactiveTrackColor: colors.surfaceContainerHighest,
            trackOutlineWidth: WidgetStateProperty.all(0.1),
            trackOutlineColor: WidgetStateProperty.all(colors.outlineVariant),
          ),
        ),
      ),
    );

    final rowChild = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        switchWidget,
        if (showLabelOnRight) ...[
          const SizedBox(width: 8),
          Text(
            widget.label!,
            style: TextStyle(letterSpacing: 0.9, color: colors.onSurfaceVariant, fontSize: _getLabelFontSize()),
          ),
        ],
        if (widget.info != null && !isLabelAbove) ...[
          const SizedBox(width: 4),
          TTooltip(
            message: widget.info!,
            color: colors.onSurfaceVariant,
            triggerMode: TTooltipTriggerMode.adaptive,
            child: Icon(Icons.info_outline, size: 16, color: colors.onSurfaceVariant.withAlpha(200)),
          ),
        ],
      ],
    );

    final clickableContent = InkWell(
      onTap: widget.disabled ? null : () => _onSwitchChanged(null),
      child: rowChild,
    );

    return buildWrapper(child: clickableContent);
  }
}
