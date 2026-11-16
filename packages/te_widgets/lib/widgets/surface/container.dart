import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// How a [TContainer] renders when glass is active.
enum TGlassMode {
  /// Translucent fill only (no blur): cheap, safe for chips, rows and small widgets. Default.
  tint,

  /// Full glass surface: backdrop blur, sheen and specular edge. For cards, dialogs, popovers and bars.
  surface,

  /// Never glassy (opaque badges and similar).
  none,
}

/// Drop-in [Container] that resolves [TGlassStyle] itself, so call sites don't branch on glass.
///
/// With glass off it builds a plain [Container]. With glass on, the fill from [decoration] (or [color]) becomes
/// translucent ([TGlassMode.tint]) or a blurred glass surface ([TGlassMode.surface]).
class TContainer extends StatelessWidget {
  final Widget? child;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;

  /// Null follows the app theme; true/false overrides it (same as [TCard.glass]).
  final bool? glass;
  final TGlassMode glassMode;

  /// Fill used instead of the decoration's colour while glass is active (e.g. a light wash rather than a dark surface).
  final Color? glassColor;

  const TContainer({
    super.key,
    this.child,
    this.alignment,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
    this.glass,
    this.glassMode = TGlassMode.tint,
    this.glassColor,
  }) : assert(color == null || decoration == null, 'Provide either color or decoration, not both.');

  Container _build({Widget? child, Color? color, Decoration? decoration, bool pad = true}) => Container(
    alignment: alignment,
    padding: pad ? padding : null,
    margin: margin,
    color: color,
    decoration: decoration,
    foregroundDecoration: foregroundDecoration,
    width: width,
    height: height,
    constraints: constraints,
    transform: transform,
    transformAlignment: transformAlignment,
    clipBehavior: clipBehavior,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final style = glassMode == TGlassMode.none ? null : TGlassStyle.resolve(context, glass);
    if (style == null) return _build(child: child, color: color, decoration: decoration);

    final deco = decoration;
    if (deco != null && deco is! BoxDecoration) return _build(child: child, decoration: deco);
    final box = deco as BoxDecoration?;
    final base = glassColor ?? box?.color ?? color;

    if (glassMode == TGlassMode.surface && base != null && base.a != 0) {
      final radius = box?.borderRadius?.resolve(Directionality.of(context)) ?? BorderRadius.zero;
      // Shadow stays outside the blur clip; the fill, sheen and edge are painted by the glass surface.
      final shadow = box?.boxShadow;
      return _build(
        pad: false,
        decoration: shadow == null ? null : BoxDecoration(borderRadius: radius, boxShadow: shadow),
        child: TGlassSurface(
          style: style,
          borderRadius: radius,
          color: base,
          child: padding == null ? (child ?? const SizedBox.shrink()) : Padding(padding: padding!, child: child),
        ),
      );
    }

    // An explicit glassColor is already glass-tuned; only the theme fill is made translucent.
    final tinted = glassColor ?? (base == null ? null : TGlassStyle.surface(context, base, glass));
    return _build(
      child: child,
      decoration: (box ?? const BoxDecoration()).copyWith(color: tinted),
    );
  }
}
