import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Loading animation types.
enum TLoadingType {
  /// Spinning oval/circle loader
  oval,

  /// Pulsing dots loader
  dots,

  /// Linear progress bar
  linear
}

/// An animated loading indicator with multiple styles.
///
/// `TLoadingIcon` provides loading animations with:
/// - Three animation types (oval, dots, linear)
/// - Customizable colors and size
/// - Smooth animations
///
/// ## Basic Usage
///
/// ```dart
/// TLoadingIcon()
/// ```
///
/// ## Custom Style
///
/// ```dart
/// TLoadingIcon(
///   type: TLoadingType.dots,
///   color: Colors.blue,
///   size: 40,
/// )
/// ```
///
/// ## Linear Progress
///
/// ```dart
/// TLoadingIcon(
///   type: TLoadingType.linear,
///   color: Colors.green,
/// )
/// ```
///
/// See also:
/// - [CircularProgressIndicator] for Material loading
class TLoadingIcon extends StatefulWidget {
  /// The type of loading animation.
  final TLoadingType type;

  /// The color of the loading indicator.
  final Color? color;

  /// The background color (for oval and linear types).
  final Color? background;

  /// The size of the loading indicator.
  final double size;

  /// Creates a loading icon.
  const TLoadingIcon({
    super.key,
    this.type = TLoadingType.oval,
    this.color,
    this.size = 25.0,
    this.background,
  });

  @override
  State<TLoadingIcon> createState() => _LoadingIconState();
}

class _LoadingIconState extends State<TLoadingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = widget.color ?? colors.primary;
    final background = widget.background ?? color.withAlpha(50);

    switch (widget.type) {
      case TLoadingType.oval:
        return SizedBox(
            width: widget.size,
            height: widget.size,
            child: _LoadingOval(color: color, background: background, size: widget.size, controller: _controller));
      case TLoadingType.dots:
        return SizedBox(width: widget.size, height: widget.size, child: _LoadingDots(color: color, size: widget.size));
      case TLoadingType.linear:
        return SizedBox(
          height: widget.size,
          child: LinearProgressIndicator(
            backgroundColor: background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
    }
  }
}

class _LoadingOval extends StatelessWidget {
  final Color color;
  final Color background;
  final double size;
  final AnimationController controller;

  const _LoadingOval({
    required this.color,
    required this.size,
    required this.controller,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: controller.value * 2 * 3.1415926,
          child: CustomPaint(
            painter: _OvalPainter(color, background),
            child: SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _OvalPainter extends CustomPainter {
  final Color color;
  final Color background;
  _OvalPainter(this.color, this.background);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final radius = size.width / 2 - strokeWidth / 2;

    final paintBackground = Paint()
      ..color = background
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final paintArc = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, paintBackground);

    // Draw 90-degree arc to simulate spinner
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.5,
      false,
      paintArc,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _LoadingDots extends StatefulWidget {
  final Color color;
  final double size;

  const _LoadingDots({required this.color, required this.size});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _scales;
  final durations = [0.0, 0.2, 0.4];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();

    _scales = durations.map((delay) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 50),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, delay + 0.6, curve: Curves.easeInOut),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(Animation<double> scale, double offset) {
    return ScaleTransition(
      scale: scale,
      child: Container(
        width: widget.size / 2,
        height: widget.size / 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) => _dot(_scales[i], durations[i])),
      ),
    );
  }
}
