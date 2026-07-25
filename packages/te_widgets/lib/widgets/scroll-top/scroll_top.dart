import 'package:flutter/material.dart';

class TScrollTop extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double alignment;

  const TScrollTop({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.alignment = 0.0,
  });

  static Widget activeOrOpacity({
    required Widget child,
    required bool active,
    required bool anyActive,
    Key? key,
    double opacity = 0.4,
  }) {
    if (anyActive && !active) {
      return RepaintBoundary(
        child: Opacity(
          opacity: opacity,
          child: IgnorePointer(child: child),
        ),
      );
    } else if (active) {
      return TScrollTop(key: key, child: child);
    }
    return child;
  }

  @override
  State<TScrollTop> createState() => _TScrollTopState();
}

class _TScrollTopState extends State<TScrollTop> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          alignment: widget.alignment,
          duration: widget.duration,
          curve: widget.curve,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
