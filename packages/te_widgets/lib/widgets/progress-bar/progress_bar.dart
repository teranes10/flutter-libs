import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A progress bar widget that displays completion status.
///
/// `TProgressBar` provides a customizable progress indicator with:
/// - Support for current value (0.0 to 1.0)
/// - Indeterminate state for unknown progress
/// - Flowing animation for visual feedback
/// - Percentage text display
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
/// ## Indeterminate Progress
///
/// ```dart
/// TProgressBar(
///   indeterminate: true,
///   label: 'Processing...',
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

  /// The color of the track (background).
  ///
  /// Defaults to [AppColors.surfaceContainerHighest].
  final Color? backgroundColor;

  /// Optional label text displayed above the progress bar.
  final String? label;

  /// Whether to display the percentage text.
  final bool showPercentage;

  /// The border radius of the progress bar and track.
  ///
  /// Defaults to 10.0.
  final double borderRadius;

  /// The duration of the progress value animation.
  ///
  /// Defaults to 300ms.
  final Duration animationDuration;

  /// Creates a progress bar.
  const TProgressBar({
    super.key,
    this.value = 0.0,
    this.indeterminate = false,
    this.flowing = false,
    this.height = 8.0,
    this.color,
    this.backgroundColor,
    this.label,
    this.showPercentage = false,
    this.borderRadius = 10.0,
    this.animationDuration = const Duration(milliseconds: 300),
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
    final progressColor = widget.color ?? colors.primary;
    final trackColor = widget.backgroundColor ?? colors.surfaceContainerHighest;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null || widget.showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
                  ),
                if (widget.showPercentage && !widget.indeterminate)
                  Text(
                    '${(widget.value * 100).toInt()}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: progressColor),
                  ),
              ],
            ),
          ),
        Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (widget.indeterminate) {
                return _buildIndeterminateBar(progressColor);
              }

              return Stack(
                children: [
                  AnimatedContainer(
                    duration: widget.animationDuration,
                    curve: Curves.easeOut,
                    width: constraints.maxWidth * widget.value.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                    child: widget.flowing ? _buildFlowingEffect(progressColor) : null,
                  ),
                ],
              );
            },
          ),
        ),
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
