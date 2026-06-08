import 'package:flutter/material.dart';
import 'package:te_widgets/extensions/build_context_x.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';

/// A range slider input for selecting a range of values.
class TRangeSlider extends StatefulWidget with TInputValueMixin<RangeValues>, TFocusMixin, TInputValidationMixin<RangeValues> {
  @override
  final RangeValues? value;

  @override
  final ValueNotifier<RangeValues?>? valueNotifier;

  @override
  final ValueChanged<RangeValues?>? onValueChanged;

  @override
  final FocusNode? focusNode;

  @override
  final String? label;

  @override
  final bool isRequired;

  @override
  final List<String? Function(RangeValues?)>? rules;

  @override
  final Duration? validationDebounce;

  final double min;
  final double max;
  final int? divisions;
  final int precision;
  final Color? color;
  final bool disabled;

  const TRangeSlider({
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
    this.precision = 0,
    this.color,
    this.disabled = false,
  });

  @override
  State<TRangeSlider> createState() => _TRangeSliderState();
}

class _TRangeSliderState extends State<TRangeSlider>
    with
        TInputValueStateMixin<RangeValues, TRangeSlider>,
        TFocusStateMixin<TRangeSlider>,
        TInputValidationStateMixin<RangeValues, TRangeSlider> {
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
          child: RangeSlider(
            values: currentValue ?? RangeValues(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            labels: RangeLabels(
              (currentValue?.start ?? widget.min).toStringAsFixed(widget.precision),
              (currentValue?.end ?? widget.max).toStringAsFixed(widget.precision),
            ),
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
