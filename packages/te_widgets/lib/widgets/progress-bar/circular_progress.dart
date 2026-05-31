import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A circular progress indicator that displays completion status.
///
/// `TCircularProgress` provides a customizable circular indicator with:
/// - Support for current value (0.0 to 1.0)
/// - Indeterminate state for unknown progress
/// - Optional percentage text in the center
/// - Customizable size and stroke width
/// - Themed colors
///
/// ## Basic Usage
///
/// ```dart
/// TCircularProgress(
///   value: 0.7,
/// )
/// ```
///
/// ## Indeterminate
///
/// ```dart
/// TCircularProgress(
///   indeterminate: true,
/// )
/// ```
class TCircularProgress extends StatelessWidget {
  /// The current progress value, from 0.0 to 1.0.
  ///
  /// Ignored if [indeterminate] is true.
  final double value;

  /// Whether the progress is in an unknown state.
  final bool indeterminate;

  /// The size (diameter) of the circular progress indicator.
  ///
  /// Defaults to 40.0.
  final double size;

  /// The width of the progress line.
  ///
  /// Defaults to 4.0.
  final double strokeWidth;

  /// The color of the progress line.
  ///
  /// Defaults to [AppColors.primary].
  final Color? color;

  /// The color of the track (background circle).
  ///
  /// Defaults to [AppColors.surfaceContainerHighest].
  final Color? backgroundColor;

  /// Whether to display the percentage text in the center.
  final bool showPercentage;

  /// Optional label text displayed below the progress indicator.
  final String? label;

  /// Creates a circular progress indicator.
  const TCircularProgress({
    super.key,
    this.value = 0.0,
    this.indeterminate = false,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.color,
    this.backgroundColor,
    this.showPercentage = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progressColor = color ?? colors.primary;
    final trackColor = backgroundColor ?? colors.surfaceContainerHighest;

    Widget indicator;

    if (indeterminate) {
      indicator = SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          backgroundColor: trackColor,
        ),
      );
    } else {
      indicator = Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              backgroundColor: trackColor,
            ),
          ),
          if (showPercentage)
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
        ],
      );
    }

    if (label == null) {
      return indicator;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(height: 8),
        Text(
          label!,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}
