import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// How a character changes to its new value in [TRollingText].
enum TRollingEffect {
  /// Digits spin through the intermediate digits like a mechanical odometer
  /// (taxi meter, counters). Non-digits fall back to [slide].
  odometer,

  /// Old character slides up and out while the new one slides in
  /// (scoreboard runs, player names).
  slide,

  /// Old character folds away and the new one unfolds, like a flip clock.
  flip,
}

/// Text whose characters change one by one with a mechanical rotation effect.
///
/// Only characters that differ animate, and they start sequentially
/// ([stagger] apart). Characters are aligned from the right, so counters
/// grow naturally (`99` → `100`).
///
/// Drive it with a plain string, or with any [ValueListenable]:
///
/// ```dart
/// final fare = ValueNotifier<double>(0);
///
/// TRollingText.listenable(
///   fare,
///   format: (v) => '\$${(v as double).toStringAsFixed(2)}',
///   style: const TextStyle(fontSize: 40),
/// )
/// ```
class TRollingText extends StatelessWidget {
  final String? text;
  final ValueListenable<Object?>? listenable;
  final String Function(Object? value)? format;
  final TextStyle? style;
  final TRollingEffect effect;

  /// Duration of each character's change.
  final Duration duration;

  /// Delay between consecutive changing characters.
  final Duration stagger;

  /// Starts the sequence from the rightmost changing character instead.
  final bool reverseStagger;

  final Curve curve;

  /// Optional box drawn around every character (flip-clock tiles).
  final BoxDecoration? slotDecoration;
  final EdgeInsetsGeometry slotPadding;

  const TRollingText(
    String this.text, {
    super.key,
    this.style,
    this.effect = TRollingEffect.odometer,
    this.duration = const Duration(milliseconds: 500),
    this.stagger = const Duration(milliseconds: 80),
    this.reverseStagger = false,
    this.curve = Curves.easeInOutCubic,
    this.slotDecoration,
    this.slotPadding = EdgeInsets.zero,
  }) : listenable = null,
       format = null;

  const TRollingText.listenable(
    this.listenable, {
    super.key,
    this.format,
    this.style,
    this.effect = TRollingEffect.odometer,
    this.duration = const Duration(milliseconds: 500),
    this.stagger = const Duration(milliseconds: 80),
    this.reverseStagger = false,
    this.curve = Curves.easeInOutCubic,
    this.slotDecoration,
    this.slotPadding = EdgeInsets.zero,
  }) : text = null;

  @override
  Widget build(BuildContext context) {
    final l = listenable;
    if (l == null) return _RollingCore(text!, this);
    return ValueListenableBuilder<Object?>(
      valueListenable: l,
      builder: (context, value, child) => _RollingCore(format != null ? format!(value) : '$value', this),
    );
  }
}

class _RollingCore extends StatefulWidget {
  final String text;
  final TRollingText config;
  const _RollingCore(this.text, this.config);

  @override
  State<_RollingCore> createState() => _RollingCoreState();
}

class _RollingCoreState extends State<_RollingCore> {
  List<Duration> _delays = const [];
  int _slots = 0;

  @override
  void initState() {
    super.initState();
    _slots = widget.text.length;
  }

  @override
  void didUpdateWidget(_RollingCore old) {
    super.didUpdateWidget(old);
    final n = _slots = math.max(_slots, math.max(old.text.length, widget.text.length));
    final from = _padded(old.text, n), to = _padded(widget.text, n);
    final changed = [
      for (var i = 0; i < n; i++)
        if (from[i] != to[i]) i,
    ];
    final ordered = widget.config.reverseStagger ? changed.reversed.toList() : changed;
    _delays = List.filled(n, Duration.zero);
    for (var k = 0; k < ordered.length; k++) {
      _delays[ordered[k]] = widget.config.stagger * k;
    }
  }

  List<String> _padded(String s, int n) => [...List.filled(n - s.length, ''), ...s.split('')];

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final chars = _padded(widget.text, _slots);
    final style = c.style ?? DefaultTextStyle.of(context).style;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < chars.length; i++)
          _Slot(
            // Keyed from the right so a slot keeps its state when length changes.
            key: ValueKey(chars.length - i),
            char: chars[i],
            delay: i < _delays.length ? _delays[i] : Duration.zero,
            style: style,
            config: c,
          ),
      ],
    );
  }
}

class _Slot extends StatefulWidget {
  final String char;
  final Duration delay;
  final TextStyle style;
  final TRollingText config;
  const _Slot({super.key, required this.char, required this.delay, required this.style, required this.config});

  @override
  State<_Slot> createState() => _SlotState();
}

class _SlotState extends State<_Slot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.config.duration, value: 1);
  late String _from = widget.char;
  late String _to = widget.char;
  Timer? _timer;

  @override
  void didUpdateWidget(_Slot old) {
    super.didUpdateWidget(old);
    if (widget.char == _to) return;
    _timer?.cancel();
    _from = _to;
    _to = widget.char;
    _c.duration = widget.config.duration;
    _c.value = 0;
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  Size _measure(String s, BuildContext context) {
    final p = TextPainter(
      text: TextSpan(text: s.isEmpty ? ' ' : s, style: widget.style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final size = Size(s.isEmpty ? 0 : p.width, p.height);
    p.dispose();
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final settled = _c.value >= 1 && _timer?.isActive != true;
        if (settled && _to.isEmpty) return const SizedBox.shrink();

        final p = cfg.curve.transform(_c.value);
        final sf = _measure(_from, context), st = _measure(_to, context);
        final h = math.max(sf.height, st.height);
        final w = settled ? st.width : sf.width + (st.width - sf.width) * p;

        Widget content = SizedBox(
          width: w,
          height: h,
          child: settled ? Center(child: _text(_to)) : _animated(p, h),
        );

        if (cfg.slotDecoration != null) {
          content = Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            padding: cfg.slotPadding,
            decoration: cfg.slotDecoration,
            child: content,
          );
        }
        return content;
      },
    );
  }

  Text _text(String s) => Text(s, style: widget.style, maxLines: 1, softWrap: false);

  Widget _animated(double p, double h) {
    final bothDigits = _isDigit(_from) && _isDigit(_to);
    switch (widget.config.effect) {
      case TRollingEffect.odometer when bothDigits:
        final a = int.parse(_from), b = int.parse(_to);
        final steps = (b - a) % 10;
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: double.infinity,
            child: Transform.translate(
              offset: Offset(0, -p * steps * h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i <= steps; i++) SizedBox(height: h, child: Center(child: _text('${(a + i) % 10}'))),
                ],
              ),
            ),
          ),
        );
      case TRollingEffect.flip:
        final first = p < 0.5;
        final angle = first ? -math.pi / 2 * (p * 2) : math.pi / 2 * (1 - (p - 0.5) * 2);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.003)
            ..rotateX(angle),
          child: Center(child: _text(first ? _from : _to)),
        );
      default: // slide, and odometer for non-digits
        return ClipRect(
          child: Stack(
            children: [
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, -p * h),
                  child: Opacity(opacity: 1 - p, child: Center(child: _text(_from))),
                ),
              ),
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, (1 - p) * h),
                  child: Opacity(opacity: p, child: Center(child: _text(_to))),
                ),
              ),
            ],
          ),
        );
    }
  }

  static bool _isDigit(String s) => s.length == 1 && s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
}
