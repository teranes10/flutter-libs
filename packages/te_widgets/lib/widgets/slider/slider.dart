import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A slider input for selecting a single value from a range.
class TSlider extends StatefulWidget with TInputValueMixin<double>, TFocusMixin, TInputValidationMixin<double> {
  @override
  final double? value;

  @override
  final ValueNotifier<double?>? valueNotifier;

  @override
  final ValueChanged<double?>? onValueChanged;

  @override
  final FocusNode? focusNode;

  @override
  final String? label;

  @override
  final bool isRequired;

  @override
  final List<String? Function(double?)>? rules;

  @override
  final Duration? validationDebounce;

  final double min;
  final double max;
  final int? divisions;
  final String? labelFormatter;
  final int precision;
  final Color? color;
  final bool disabled;

  const TSlider({
    super.key,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    this.label,
    this.isRequired = false,
    this.rules,
    this.validationDebounce,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.labelFormatter,
    this.precision = 0,
    this.color,
    this.disabled = false,
  });

  @override
  State<TSlider> createState() => _TSliderState();
}

class _TSliderState extends State<TSlider>
    with TInputValueStateMixin<double, TSlider>, TFocusStateMixin<TSlider>, TInputValidationStateMixin<double, TSlider> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final mColor = widget.color ?? theme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: mColor,
            inactiveTrackColor: mColor.withAlpha(50),
            thumbColor: mColor,
            overlayColor: mColor.withAlpha(30),
            valueIndicatorColor: mColor,
          ),
          child: Slider(
            value: currentValue ?? widget.min,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: widget.labelFormatter != null
                ? widget.labelFormatter!.replaceAll('{value}', (currentValue ?? widget.min).toStringAsFixed(widget.precision))
                : (currentValue ?? widget.min).toStringAsFixed(widget.precision),
            onChanged: widget.disabled
                ? null
                : (val) {
                    notifyValueChanged(val);
                    setState(() {});
                  },
          ),
        ),
        if (errorsNotifier.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              errorsNotifier.value.first,
              style: TextStyle(color: colors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
