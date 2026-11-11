import 'package:flutter/material.dart';

/// Single-line text that scrolls cyclically instead of overflowing.
///
/// If the text fits, it renders statically. Otherwise it rests at the start
/// for [pause] (so it can be read), scrolls left at a constant [velocity]
/// until the text wraps around after [gap], then repeats seamlessly.
///
/// ```dart
/// SizedBox(width: 120, child: TMarquee('A very long product name'))
/// ```
class TMarquee extends StatefulWidget {
  final String text;
  final TextStyle? style;

  /// Scroll speed in logical pixels per second (~40 is comfortable to read).
  final double velocity;

  /// Time the text rests at its start position before each scroll cycle.
  final Duration pause;

  /// Empty space between the end of the text and its repeat.
  final double gap;

  const TMarquee(
    this.text, {
    super.key,
    this.style,
    this.velocity = 40,
    this.pause = const Duration(seconds: 2),
    this.gap = 32,
  });

  @override
  State<TMarquee> createState() => _TMarqueeState();
}

class _TMarqueeState extends State<TMarquee> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  double _distance = 0;

  /// Fraction of one cycle spent resting.
  double _pauseFraction = 0;

  void _configure(double distance) {
    if (distance == _distance && _controller.isAnimating) return;
    _distance = distance;
    final scrollMs = distance / widget.velocity * 1000;
    final pauseMs = widget.pause.inMilliseconds;
    _pauseFraction = pauseMs / (pauseMs + scrollMs);
    _controller.duration = Duration(milliseconds: (pauseMs + scrollMs).round());
    _controller.repeat();
  }

  @override
  void didUpdateWidget(TMarquee old) {
    super.didUpdateWidget(old);
    _distance = 0; // force reconfigure on next layout
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final text = Text(widget.text, style: style, maxLines: 1, softWrap: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final textWidth = painter.width;
        final textHeight = painter.height;
        painter.dispose();

        if (textWidth <= constraints.maxWidth) {
          if (_controller.isAnimating) _controller.stop();
          return text;
        }

        final distance = textWidth + widget.gap;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _configure(distance);
        });

        return ClipRect(
          child: SizedBox(
            height: textHeight,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: 0,
              maxWidth: double.infinity,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  final progress = t < _pauseFraction ? 0.0 : (t - _pauseFraction) / (1 - _pauseFraction);
                  return Transform.translate(offset: Offset(-progress * distance, 0), child: child);
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: [text, SizedBox(width: widget.gap), text]),
              ),
            ),
          ),
        );
      },
    );
  }
}
