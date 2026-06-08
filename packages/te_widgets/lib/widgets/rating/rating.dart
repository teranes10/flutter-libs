import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A rating component for selecting a value using stars.
class TRating extends StatefulWidget with TInputValueMixin<double>, TFocusMixin, TInputValidationMixin<double> {
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

  final int itemCount;
  final double itemSize;
  final Color? color;
  final Color? unratedColor;
  final IconData ratedIcon;
  final IconData unratedIcon;
  final bool disabled;
  final bool allowHalfRating;

  const TRating({
    super.key,
    this.value = 0,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    this.label,
    this.isRequired = false,
    this.rules,
    this.validationDebounce,
    this.itemCount = 5,
    this.itemSize = 24.0,
    this.color,
    this.unratedColor,
    this.ratedIcon = Icons.star,
    this.unratedIcon = Icons.star_border,
    this.disabled = false,
    this.allowHalfRating = false,
  });

  @override
  State<TRating> createState() => _TRatingState();
}

class _TRatingState extends State<TRating>
    with TInputValueStateMixin<double, TRating>, TFocusStateMixin<TRating>, TInputValidationStateMixin<double, TRating> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ratedColor = widget.color ?? Colors.amber;
    final unratedColor = widget.unratedColor ?? colors.surfaceContainerHighest;

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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.itemCount, (index) {
            final ratingValue = index + 1.0;
            final isRated = (currentValue ?? 0) >= ratingValue;
            final isHalfRated = !isRated && (currentValue ?? 0) >= (ratingValue - 0.5) && widget.allowHalfRating;

            return GestureDetector(
              onTap: widget.disabled
                  ? null
                  : () {
                      notifyValueChanged(ratingValue);
                      setState(() {});
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Icon(
                  isHalfRated ? Icons.star_half : (isRated ? widget.ratedIcon : widget.unratedIcon),
                  color: (isRated || isHalfRated) ? ratedColor : unratedColor,
                  size: widget.itemSize,
                ),
              ),
            );
          }),
        ),
        if (errorsNotifier.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorsNotifier.value.first,
              style: TextStyle(color: colors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
