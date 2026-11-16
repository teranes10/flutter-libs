import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Look of the optional liquid-glass mode: blurred backdrop, translucent fill and a light-catching edge.
@immutable
class TGlassStyle {
  /// Backdrop blur sigma.
  final double blur;

  /// Alpha (0-255) of the surface fill laid over the blurred backdrop.
  final int fillAlpha;

  /// Fill alpha in light mode: higher than [fillAlpha] so dark text stays readable over the colourful backdrop.
  final int lightFillAlpha;

  /// Alpha (0-255) of the specular border.
  final int borderAlpha;

  /// Alpha (0-255) of the top-left sheen gradient.
  final int highlightAlpha;

  const TGlassStyle({this.blur = 18, this.fillAlpha = 120, this.lightFillAlpha = 200, this.borderAlpha = 90, this.highlightAlpha = 50});

  /// Translucent version of [c] for small widgets (chips) that sit on a glass surface and skip the costly blur.
  Color tint(Color c) => c.withAlpha((c.a * 255 * fillAlpha / 255 + 40).clamp(0, 255).round());

  /// Light-catching edge colour for tinted small widgets.
  Color get edge => Colors.white.withAlpha(borderAlpha);

  /// [c] made translucent when glass is active (for fields, buttons and other small surfaces that sit on glass
  /// without their own blur). Returns [c] unchanged when glass is off or [c] is already transparent.
  static Color surface(BuildContext context, Color c, [bool? override]) {
    final style = resolve(context, override);
    if (style == null || c.a == 0) return c;
    final dark = context.colors.isDarkMode;
    return c.withAlpha(dark ? style.fillAlpha : style.lightFillAlpha - 20);
  }

  /// Glass-tuned copy of [s]: stronger outlines and secondary text, because the regular palette's faint greys
  /// disappear over the blurred, colourful backdrop. Used only when glass is on, so the regular palette is untouched.
  static ColorScheme scheme(ColorScheme s) {
    final dark = s.brightness == Brightness.dark;
    final toward = dark ? Colors.white : Colors.black;
    Color mix(Color c, double t) => Color.lerp(c, toward, t)!;
    return s.copyWith(
      onSurfaceVariant: mix(s.onSurfaceVariant, dark ? 0.45 : 0.4),
      outline: mix(s.outline, dark ? 0.45 : 0.3),
      outlineVariant: mix(s.outlineVariant, dark ? 0.35 : 0.2),
    );
  }

  /// [solid] normally; in glass mode a light frosted overlay instead (for small opaque chips such as icon buttons
  /// and badges that would otherwise read as dark blocks over the backdrop).
  static Color frost(BuildContext context, Color solid) {
    if (resolve(context) == null) return solid;
    return Colors.white.withAlpha(context.colors.isDarkMode ? 28 : 150);
  }

  /// Hover highlight for menu/list rows on glass: a light wash (dark mode) or primary tint (light mode) in place of
  /// the opaque dim surface, which reads as a dark slab over the backdrop.
  static Color hoverOverlay(BuildContext context) {
    final colors = context.colors;
    return colors.isDarkMode ? Colors.white.withAlpha(32) : colors.primary.withAlpha(28);
  }

  /// Selected-row highlight on glass: a primary wash.
  static Color activeOverlay(BuildContext context) {
    final colors = context.colors;
    return colors.primary.withAlpha(colors.isDarkMode ? 90 : 48);
  }

  /// Visible outline for fields on glass: the theme's faint outline vanishes over the blurred backdrop.
  Color fieldEdge(BuildContext context) {
    final colors = context.colors;
    // The glass scheme's outline (see [scheme]) already carries the contrast; keep it near-opaque.
    return colors.outline.withAlpha(colors.isDarkMode ? 200 : 210);
  }

  /// Resolves whether glass is active: [override] true/false wins, null follows the app theme
  /// ([TWidgetThemeExtension.glass], off by default). Returns null when glass is off.
  static TGlassStyle? resolve(BuildContext context, [bool? override]) {
    final themed = context.themeOrNull?.glass;
    return switch (override) {
      true => themed ?? const TGlassStyle(),
      false => null,
      null => themed,
    };
  }
}

/// Glass surface: clips to [borderRadius], blurs what is behind it and paints a translucent [color]
/// with a sheen and a specular border. Needs something colourful behind it to read as glass.
class TGlassSurface extends StatelessWidget {
  final TGlassStyle style;
  final BorderRadius borderRadius;
  final Color color;
  final Widget child;

  /// Fill alpha override (0-255); strong surfaces (snackbars, tooltips) keep text readable.
  final int? alpha;

  const TGlassSurface({
    super.key,
    required this.style,
    required this.borderRadius,
    required this.color,
    required this.child,
    this.alpha,
  });

  /// Wraps [child] in a glass surface when glass is active, else returns it unchanged. Callers drop their own
  /// opaque fill when [TGlassStyle.resolve] is non-null.
  static Widget wrap(BuildContext context, {required BorderRadius radius, required Color color, required Widget child, int? alpha}) {
    final style = TGlassStyle.resolve(context);
    if (style == null) return child;
    return TGlassSurface(style: style, borderRadius: radius, color: color, alpha: alpha, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final white = Colors.white;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: style.blur, sigmaY: style.blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withAlpha(alpha ?? (context.colors.isDarkMode ? style.fillAlpha : style.lightFillAlpha)),
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [white.withAlpha(style.highlightAlpha), white.withAlpha(0)],
            ),
            border: Border.all(color: white.withAlpha(style.borderAlpha)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Slowly drifting, colourful gradient blobs: gives [TGlassSurface] something to refract.
/// Shown behind the layout when glass mode is on.
class TGlassBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const TGlassBackground({super.key, required this.child, this.colors});

  @override
  State<TGlassBackground> createState() => _TGlassBackgroundState();
}

class _TGlassBackgroundState extends State<TGlassBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final theme = context.theme;
    final dark = scheme.isDarkMode;
    final blobs = widget.colors ?? [scheme.primary, theme.secondary, theme.info, theme.success, theme.warning];
    final base = Color.lerp(scheme.surface, scheme.primary, dark ? 0.12 : 0.06)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(painter: _BlobPainter(_c, blobs, base, dark ? 110 : 150)),
        ),
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Animation<double> t;
  final List<Color> colors;
  final Color base;
  final int alpha;

  _BlobPainter(this.t, this.colors, this.base, this.alpha) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final phase = t.value * 2 * pi;
    final radius = size.longestSide * 0.45;
    for (var i = 0; i < colors.length; i++) {
      // Each blob follows its own slow Lissajous path, so the flow never repeats visibly.
      final a = phase * (1 + i % 2) + i * 1.7;
      final b = phase * (1 + (i + 1) % 2) + i * 2.3;
      final center = Offset(
        size.width * (0.5 + 0.4 * sin(a)),
        size.height * (0.5 + 0.4 * cos(b)),
      );
      final shader = RadialGradient(
        colors: [colors[i].withAlpha(alpha), colors[i].withAlpha(0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.colors != colors || old.base != base || old.alpha != alpha;
}

/// Edge-to-edge glass for bars (bottom bars, top bars): blurs the backdrop, fills translucently and draws a
/// light divider on one side instead of a full border.
class TGlassBar extends StatelessWidget {
  final TGlassStyle style;
  final Color color;
  final Widget child;

  /// Draw the divider on the top edge (bottom bars) rather than the bottom edge.
  final bool dividerOnTop;

  const TGlassBar({super.key, required this.style, required this.color, required this.child, this.dividerOnTop = true});

  /// [child] wrapped in a glass bar when glass is active, else [fallback] built around it.
  static Widget wrap(BuildContext context, {required Color color, required Widget child, bool dividerOnTop = true}) {
    final style = TGlassStyle.resolve(context);
    if (style == null) return child;
    return TGlassBar(style: style, color: color, dividerOnTop: dividerOnTop, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.colors.isDarkMode;
    final edge = BorderSide(color: Colors.white.withAlpha(style.borderAlpha));
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: style.blur, sigmaY: style.blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withAlpha(dark ? style.fillAlpha : style.lightFillAlpha),
            border: dividerOnTop ? Border(top: edge) : Border(bottom: edge),
          ),
          child: child,
        ),
      ),
    );
  }
}
