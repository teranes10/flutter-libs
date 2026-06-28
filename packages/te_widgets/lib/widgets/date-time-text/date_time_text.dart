import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

/// A small text widget that displays a [DateTime] formatted as relative time
/// (e.g., "5 seconds ago", "yesterday") and wraps it in a [TTooltip] showing
/// the full descriptive date-time format.
class TDateTimeText extends StatelessWidget {
  /// The date time to display.
  final DateTime dateTime;

  /// Optional style for the text widget.
  final TextStyle? style;

  /// The format used for the descriptive tooltip.
  /// Defaults to `'EEEE, MMMM d, yyyy h:mm:ss a'` (e.g. Thursday, June 18, 2026 7:42:42 PM).
  final String tooltipDateFormat;

  /// Optional custom tooltip message. If provided, overrides the default formatted date-time.
  final String? customTooltipMessage;

  /// Position of the tooltip relative to the text.
  final TTooltipPosition tooltipPosition;

  const TDateTimeText({
    super.key,
    required this.dateTime,
    this.style,
    this.tooltipDateFormat = 'MMMM d, yyyy h:mm:ss a',
    this.customTooltipMessage,
    this.tooltipPosition = TTooltipPosition.auto,
  });

  @override
  Widget build(BuildContext context) {
    final relativeText = dateTime.formatAgo();
    final tooltipText = customTooltipMessage ?? DateFormat(tooltipDateFormat).format(dateTime);

    return TTooltip(
      triggerMode: TTooltipTriggerMode.adaptive,
      message: tooltipText,
      position: tooltipPosition,
      child: Text(relativeText, style: style),
    );
  }
}
