import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Position of the percentage or value text relative to the linear progress bar.
enum TProgressValuePosition {
  /// Top right corner above the progress bar, opposite the label (default).
  topRight,

  /// Top left corner above the progress bar, next to the label.
  topLeft,

  /// Inline after the progress bar horizontally on the same line.
  afterProgress,

  /// Inline before the progress bar horizontally on the same line.
  beforeProgress,

  /// Bottom right below the progress bar.
  bottomRight,

  /// Bottom left below the progress bar.
  bottomLeft,

  /// Centered inside the progress bar (ideal for larger bar heights).
  inside,
}

/// A progress bar widget that displays completion status.
///
/// `TProgressBar` provides a customizable progress indicator with:
/// - Support for current value (0.0 to 1.0)
/// - Indeterminate state for unknown progress
/// - Flowing animation for visual feedback
/// - Flexible percentage/value position ([TProgressValuePosition])
/// - Custom labels and sizes
/// - Animated value transitions
///
/// ## Basic Usage
///
/// ```dart
/// TProgressBar(
///   value: 0.7,
///   label: 'Uploading...',
/// )
/// ```
///
/// ## With Value Position
///
/// ```dart
/// TProgressBar(
///   value: 0.5,
///   showPercentage: true,
///   valuePosition: TProgressValuePosition.afterProgress,
/// )
/// ```
class TProgressBar extends StatefulWidget {
  /// The current progress value, from 0.0 to 1.0.
  ///
  /// Ignored if [indeterminate] is true.
  final double value;

  /// Whether the progress is in an unknown state.
  ///
  /// When true, the bar displays a continuous flowing animation.
  final bool indeterminate;

  /// Whether to show a continuous flowing/shimmer animation on the bar.
  final bool flowing;

  /// The height of the progress bar.
  ///
  /// Defaults to 8.0.
  final double height;

  /// The color of the progress bar.
  ///
  /// Defaults to [AppColors.primary].
  final Color? color;

  /// Optional function to dynamically compute the color based on progress [value] (0.0 to 1.0) and [percentage] (0.0 to 100.0).
  final Color? Function(double value, double percentage)? colorBuilder;

  /// The color of the track (background).
  ///
  /// Defaults to [AppColors.surfaceContainerHighest].
  final Color? backgroundColor;

  /// Optional label text displayed above or next to the progress bar.
  final String? label;

  /// Whether to display the percentage text.
  final bool showPercentage;

  /// Optional custom value text to display (e.g. '50 / 1000').
  final String? valueText;

  /// The position of the percentage and value text relative to the progress bar.
  ///
  /// Defaults to [TProgressValuePosition.topRight].
  final TProgressValuePosition valuePosition;

  /// Whether to display the progress bar inline with its label and percentage.
  ///
  /// Convenience alias for setting [valuePosition] to [TProgressValuePosition.afterProgress].
  final bool? inline;

  /// The border radius of the progress bar and track.
  ///
  /// Defaults to 10.0.
  final double borderRadius;

  /// The duration of the progress value animation.
  ///
  /// Defaults to 300ms.
  final Duration animationDuration;

  /// Optional custom text style for the percentage/value text.
  final TextStyle? valueStyle;

  /// Creates a progress bar.
  const TProgressBar({
    super.key,
    this.value = 0.0,
    this.indeterminate = false,
    this.flowing = false,
    this.height = 8.0,
    this.color,
    this.colorBuilder,
    this.backgroundColor,
    this.label,
    this.showPercentage = false,
    this.valueText,
    this.valuePosition = TProgressValuePosition.topRight,
    this.inline,
    this.borderRadius = 10.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.valueStyle,
  });

  @override
  State<TProgressBar> createState() => _TProgressBarState();
}

class _TProgressBarState extends State<TProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.indeterminate || widget.flowing) {
      _flowController.repeat();
    }
  }

  @override
  void didUpdateWidget(TProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.indeterminate || widget.flowing) && !_flowController.isAnimating) {
      _flowController.repeat();
    } else if (!widget.indeterminate && !widget.flowing && _flowController.isAnimating) {
      _flowController.stop();
    }
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progressColor = widget.colorBuilder?.call(widget.value, widget.value * 100) ?? (widget.color ?? colors.primary);
    final trackColor = widget.backgroundColor ?? colors.surfaceContainerHighest;

    String? displayValue;
    if (widget.valueText != null && widget.showPercentage && !widget.indeterminate) {
      displayValue = '${widget.valueText} (${(widget.value * 100).toInt()}%)';
    } else if (widget.valueText != null) {
      displayValue = widget.valueText;
    } else if (widget.showPercentage && !widget.indeterminate) {
      displayValue = '${(widget.value * 100).toInt()}%';
    }

    final defaultValueStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
    final effectiveValueStyle = (widget.valueStyle != null ? defaultValueStyle.merge(widget.valueStyle) : defaultValueStyle).copyWith(
      color: widget.valueStyle?.color ?? progressColor.toMaterial().shade400,
    );

    final effectivePosition = (widget.inline == true && widget.valuePosition == TProgressValuePosition.topRight)
        ? TProgressValuePosition.afterProgress
        : widget.valuePosition;

    final isInline =
        effectivePosition == TProgressValuePosition.afterProgress || effectivePosition == TProgressValuePosition.beforeProgress;

    final barWidget = Container(
      height: widget.height,
      width: isInline ? null : double.infinity,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.indeterminate
          ? _buildIndeterminateBar(progressColor)
          : Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: widget.animationDuration,
                    curve: Curves.easeOut,
                    widthFactor: widget.value.clamp(0.0, 1.0),
                    heightFactor: 1.0,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                      ),
                      child: widget.flowing ? _buildFlowingEffect(progressColor) : null,
                    ),
                  ),
                ),
                if (effectivePosition == TProgressValuePosition.inside && displayValue != null)
                  Center(
                    child: Text(
                      displayValue,
                      style: widget.valueStyle ??
                          TextStyle(
                            fontSize: (widget.height * 0.65).clamp(8.0, 13.0),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
              ],
            ),
    );

    // Inline: After Progress
    if (effectivePosition == TProgressValuePosition.afterProgress) {
      return Row(
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(child: barWidget),
          if (displayValue != null) ...[
            const SizedBox(width: 12),
            Text(
              displayValue,
              style: effectiveValueStyle,
            ),
          ],
        ],
      );
    }

    // Inline: Before Progress
    if (effectivePosition == TProgressValuePosition.beforeProgress) {
      return Row(
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
            ),
            const SizedBox(width: 12),
          ],
          if (displayValue != null) ...[
            Text(
              displayValue,
              style: effectiveValueStyle,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(child: barWidget),
        ],
      );
    }

    // Top Left: Label + Display Value grouped on top-left
    if (effectivePosition == TProgressValuePosition.topLeft) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null || displayValue != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
                    ),
                  if (widget.label != null && displayValue != null) const SizedBox(width: 8),
                  if (displayValue != null)
                    Text(
                      displayValue,
                      style: effectiveValueStyle,
                    ),
                ],
              ),
            ),
          barWidget,
        ],
      );
    }

    // Bottom Right / Bottom Left
    if (effectivePosition == TProgressValuePosition.bottomRight || effectivePosition == TProgressValuePosition.bottomLeft) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                widget.label!,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
              ),
            ),
          barWidget,
          if (displayValue != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment:
                    effectivePosition == TProgressValuePosition.bottomRight ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Text(
                    displayValue,
                    style: effectiveValueStyle,
                  ),
                ],
              ),
            ),
        ],
      );
    }

    // Inside
    if (effectivePosition == TProgressValuePosition.inside) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                widget.label!,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
              ),
            ),
          barWidget,
        ],
      );
    }

    // Default: Top Right (Label on left, value on right)
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null || displayValue != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
                  )
                else
                  const SizedBox.shrink(),
                if (displayValue != null)
                  Text(
                    displayValue,
                    style: effectiveValueStyle,
                  ),
              ],
            ),
          ),
        barWidget,
      ],
    );
  }

  Widget _buildIndeterminateBar(Color color) {
    return AnimatedBuilder(
      animation: _flowController,
      builder: (context, child) {
        return FractionalTranslation(
          translation: Offset(-1.0 + (_flowController.value * 2.0), 0.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withAlpha(0),
                  color,
                  color.withAlpha(0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlowingEffect(Color color) {
    return AnimatedBuilder(
      animation: _flowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_flowController.value * 2), 0),
              end: Alignment(0.0 + (_flowController.value * 2), 0),
              colors: [
                Colors.white.withAlpha(0),
                Colors.white.withAlpha(77),
                Colors.white.withAlpha(0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
