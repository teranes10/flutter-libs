import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

/// Every tunable number of the glass look in one place. Edit a value and hot-restart to try your own.
/// Alphas are 0-255. "dark" / "light" are the two theme brightnesses.
abstract final class TGlassTuning {
  // ── Backdrop (Liquid) ───────────────────────────────────────────────────────────────────────────────
  /// Colour saturation of what's behind the glass (1 = unchanged).
  static const double saturation = 1.4;

  /// Backdrop brightness scale: below 1 dims bright spots more than dark ones.
  static const double dimDark = 0.9;
  static const double dimLight = 0.93;

  // ── Fill (Liquid) ───────────────────────────────────────────────────────────────────────────────────
  /// Dark mode: how far the surface colour is lightened toward white (0-1).
  static const double darkFillLighten = 0.14;

  /// Dark mode: fill alpha as a fraction of [TGlassStyle.fillAlpha] (lower = more see-through).
  static const double darkFillAlphaFactor = 0.5;

  /// Light mode: how far the surface colour is mixed toward white (0-1).
  static const double lightFillWhiten = 0.5;

  // ── Elevation shadow (Liquid) ───────────────────────────────────────────────────────────────────────
  static const int shadowAlphaDark = 34;
  static const int shadowAlphaLight = 14;
  static const double shadowBlur = 16;
  static const double shadowOffsetY = 5;

  /// Tight contact shadow right under the edge.
  static const int contactShadowAlphaDark = 14;
  static const int contactShadowAlphaLight = 6;
  static const double contactShadowBlur = 5;
  static const double contactShadowOffsetY = 2;

  // ── Inner glow (Liquid): soft wash just inside the edge. Gradient stops are top, upper-mid, lower-mid, bottom.
  static const double glowWidth = 14;
  static const double glowBlur = 9;
  static const List<int> glowAlphaDark = [32, 8, 8, 26];
  static const List<int> glowAlphaLight = [44, 10, 10, 32];

  // ── Lens bands (Liquid): light bands inside the top and bottom edges ────────────────────────────────
  /// Band height as a fraction of the surface height, clamped to [bandMinHeight]..[bandMaxHeight].
  static const double bandHeightFactor = 0.3;
  static const double bandMinHeight = 8;
  static const double bandMaxHeight = 26;

  /// Gap between the edge and the bands.
  static const double bandInset = 2.5;
  static const int topBandAlphaDark = 26;
  static const int topBandAlphaLight = 38;
  static const int bottomBandAlphaDark = 14;
  static const int bottomBandAlphaLight = 24;

  // ── Edge ring (Liquid) ──────────────────────────────────────────────────────────────────────────────
  /// Crisp line: width and alpha stops (top, upper-mid, lower-mid, bottom).
  static const double ringWidth = 1;
  static const List<int> ringAlphaDark = [90, 36, 36, 66];
  static const List<int> ringAlphaLight = [110, 50, 50, 84];

  /// Soft blurred band under the crisp line.
  static const double ringSoftWidth = 2;
  static const double ringSoftBlur = 2;
  static const List<int> ringSoftAlphaDark = [24, 10, 10, 18];
  static const List<int> ringSoftAlphaLight = [36, 15, 15, 26];

  // ── Background blobs ────────────────────────────────────────────────────────────────────────────────
  /// Default colour mix of the animated glass background (the "Slate Blue" preset), used until the user or
  /// `initializeApp(glassColors: ...)` sets another.
  static const List<Color> defaultBlobColors = [Color(0xFF3B6EA5), Color(0xFF5B8DB8), Color(0xFF7AA5C9), Color(0xFF4A5F8A)];

  /// Blob alpha behind the glass.
  static const int blobAlphaDark = 38; // 15 %
  static const int blobAlphaLight = 10;

  /// Image background: alpha of the colour blobs laid over the photo (the photo's own palette; they follow the pointer
  /// and drift when idle). Lower = the photo shows more.
  static const int imageBlobAlphaDark = 26; // 10 %
  static const int imageBlobAlphaLight = 13;

  /// Image background: blob size as a fraction of the screen's longer side.
  static const double imageBlobRadius = 0.5;

  /// Image background: how the blobs blend with the photo (srcOver = plain tint, softLight/overlay = punchier colour).
  static const BlendMode imageBlobBlend = BlendMode.srcOver;

  /// Seconds for one auto-drift loop.
  static const double autoDriftLoopSeconds = 40;

  /// How fast blobs ease toward the pointer (higher = snappier).
  static const double pointerEase = 2.5;

  /// How far the pointer pulls blobs (fraction of the screen).
  static const double pointerPull = 0.35;
}

/// Visual flavour of glass surfaces.
enum TGlassLook {
  /// Flat frosted glass: blur, translucent fill, light border.
  frosted,

  /// Raised, thick glass: outer elevation shadow, bright/dark rim, inner glow and boosted colour behind it.
  liquid;

  String get label => this == frosted ? 'Frosted' : 'Liquid';
}

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

  /// Frosted (flat) or liquid (raised, thick) rendering.
  final TGlassLook look;

  bool get isLiquid => look == TGlassLook.liquid;

  const TGlassStyle({
    this.blur = 18,
    this.fillAlpha = 120,
    this.lightFillAlpha = 120,
    this.borderAlpha = 90,
    this.highlightAlpha = 50,
    this.look = TGlassLook.frosted,
  });

  /// Backdrop filter: blur, plus a saturation boost in liquid mode so the colour behind the glass stays vivid.
  /// [dark]: scales the backdrop down so bright spots (a blob under the pointer) are dimmed more than dark ones,
  /// which keeps text on the glass readable wherever the background drifts.
  ImageFilter backdropFilterFor(bool dark) {
    final blurFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    if (!isLiquid) return blurFilter;
    const s = TGlassTuning.saturation;
    const r = 0.2126 * (1 - s), g = 0.7152 * (1 - s), b = 0.0722 * (1 - s);
    final k = dark ? TGlassTuning.dimDark : TGlassTuning.dimLight;
    return ImageFilter.compose(
      outer: ColorFilter.matrix(<double>[
        (r + s) * k, g * k, b * k, 0, 0, //
        r * k, (g + s) * k, b * k, 0, 0,
        r * k, g * k, (b + s) * k, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      inner: blurFilter,
    );
  }

  /// Translucent version of [c] for small widgets (chips) that sit on a glass surface and skip the costly blur.
  Color tint(Color c) => c.withAlpha((c.a * 255 * fillAlpha / 255 + 40).clamp(0, 255).round());

  /// Light-catching edge colour for tinted small widgets.
  Color get edge => Colors.white.withAlpha(borderAlpha);

  /// Edge colour for the current brightness: a bright specular white in light mode (stronger than dark mode's so it
  /// still shines over pale backdrops), the regular [edge] in dark mode.
  Color edgeOf(BuildContext context) => context.colors.isDarkMode ? edge : Colors.white.withAlpha(235);

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
      onSurfaceVariant: mix(s.onSurfaceVariant, dark ? 0.45 : 0.5),
      outline: mix(s.outline, dark ? 0.45 : 0.25),
      outlineVariant: mix(s.outlineVariant, dark ? 0.35 : 0.15),
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
    return colors.outline.withAlpha(colors.isDarkMode ? 200 : 170);
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
    final dark = context.colors.isDarkMode;
    final liquid = style.isLiquid;
    final glass = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: style.backdropFilterFor(dark),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Liquid dark: a lighter, more transparent fill so the colour behind shows through instead of a dark slab.
            color: (dark
                    ? (liquid ? Color.lerp(color, white, TGlassTuning.darkFillLighten)! : color)
                    : Color.lerp(color, white, TGlassTuning.lightFillWhiten)!)
                .withAlpha(alpha ??
                    (dark
                        ? (liquid ? (style.fillAlpha * TGlassTuning.darkFillAlphaFactor).round() : style.fillAlpha)
                        : style.lightFillAlpha)),
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Light mode: glossy sheen, bright at the top-left, a clear band in the middle, a soft reflection at the bottom-right.
              colors: dark
                  ? [white.withAlpha(style.highlightAlpha), white.withAlpha(0)]
                  : [white.withAlpha(190), white.withAlpha(20), white.withAlpha(80)],
              stops: dark ? null : const [0.0, 0.55, 1.0],
            ),
            border: liquid ? null : Border.all(color: style.edgeOf(context), width: dark ? 1 : 1.4),
          ),
          child: child,
        ),
      ),
    );
    if (!liquid) return glass;
    // Both are foreground painters: a shadow painted *under* the glass is picked up by the backdrop blur and bleeds
    // into the pane as a dark inset shadow.
    return CustomPaint(
      foregroundPainter: _LiquidRimPainter(borderRadius, dark),
      child: CustomPaint(foregroundPainter: _LiquidShadowPainter(borderRadius, dark), child: glass),
    );
  }
}

/// Soft elevation shadow, painted only outside the surface so it never shows through the translucent glass.
class _LiquidShadowPainter extends CustomPainter {
  final BorderRadius radius;
  final bool dark;
  _LiquidShadowPainter(this.radius, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = radius.toRRect(Offset.zero & size);
    canvas.save();
    // Even-odd: big rect minus the pane, so only the area outside the pane is painted (the shadow is a foreground
    // layer, drawing it unclipped would darken the content).
    canvas.clipPath(Path()
      ..fillType = PathFillType.evenOdd
      ..addRect((Offset.zero & size).inflate(80))
      ..addRRect(rrect));
    canvas.drawRRect(
      rrect.shift(const Offset(0, TGlassTuning.shadowOffsetY)),
      Paint()
        ..color = Colors.black.withAlpha(dark ? TGlassTuning.shadowAlphaDark : TGlassTuning.shadowAlphaLight)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, TGlassTuning.shadowBlur),
    );
    canvas.drawRRect(
      rrect.shift(const Offset(0, TGlassTuning.contactShadowOffsetY)),
      Paint()
        ..color = Colors.black.withAlpha(dark ? TGlassTuning.contactShadowAlphaDark : TGlassTuning.contactShadowAlphaLight)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, TGlassTuning.contactShadowBlur),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LiquidShadowPainter old) => old.radius != radius || old.dark != dark;
}

/// Thick-glass edge: a smooth, even ring that is a little brighter along the top and bottom (like light catching a
/// curved lens edge), plus a soft inner glow. The gradient runs top-to-bottom, not corner-to-corner, so wide rows
/// don't end up with one bright end and one dull end.
class _LiquidRimPainter extends CustomPainter {
  final BorderRadius radius;
  final bool dark;
  _LiquidRimPainter(this.radius, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);
    LinearGradient vertical(List<int> a) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [for (final v in a) Colors.white.withAlpha(v)],
        );
    canvas.save();
    canvas.clipRRect(rrect);
    // Inner glow: soft, wide and symmetric, strongest at the top and bottom edges.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = TGlassTuning.glowWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, TGlassTuning.glowBlur)
        ..shader = vertical(dark ? TGlassTuning.glowAlphaDark : TGlassTuning.glowAlphaLight).createShader(rect),
    );
    canvas.restore();
    // Fake lens: soft light bands just inside the top and bottom edges, following the rounded corners (the look of
    // light bending through a thick curved edge, without a refraction shader, which web can't run).
    final bandH = (size.height * TGlassTuning.bandHeightFactor).clamp(TGlassTuning.bandMinHeight, TGlassTuning.bandMaxHeight);
    canvas.save();
    canvas.clipRRect(rrect.deflate(TGlassTuning.bandInset));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, bandH + 3),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withAlpha(dark ? TGlassTuning.topBandAlphaDark : TGlassTuning.topBandAlphaLight),
            Colors.white.withAlpha(0)
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, bandH + 3)),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - bandH - 3, size.width, bandH + 3),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.white.withAlpha(dark ? TGlassTuning.bottomBandAlphaDark : TGlassTuning.bottomBandAlphaLight),
            Colors.white.withAlpha(0)
          ],
        ).createShader(Rect.fromLTWH(0, size.height - bandH - 3, size.width, bandH + 3)),
    );
    canvas.restore();
    // Edge ring: even all round, slightly brighter at top and bottom, softened by a faint wider blurred pass.
    final edge = rrect.deflate(0.6);
    final ring = vertical(dark ? TGlassTuning.ringAlphaDark : TGlassTuning.ringAlphaLight);
    canvas.drawRRect(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = TGlassTuning.ringSoftWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, TGlassTuning.ringSoftBlur)
        ..shader = vertical(dark ? TGlassTuning.ringSoftAlphaDark : TGlassTuning.ringSoftAlphaLight).createShader(rect),
    );
    canvas.drawRRect(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = TGlassTuning.ringWidth
        ..isAntiAlias = true
        ..shader = ring.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_LiquidRimPainter old) => old.radius != radius || old.dark != dark;
}

/// Colourful gradient blobs that give [TGlassSurface] something to refract. Shown behind the layout in glass mode.
///
/// Settings come from the theme state: custom colour mix, pointer reaction (+ auto drift after the configurable idle time, default 10s, can be
/// turned off), or a static image (user-picked and stored in IndexedDB, or an asset set from code).
class TGlassBackground extends ConsumerStatefulWidget {
  final Widget child;

  /// Overrides the theme's colour mix.
  final List<Color>? colors;

  const TGlassBackground({super.key, required this.child, this.colors});

  @override
  ConsumerState<TGlassBackground> createState() => _TGlassBackgroundState();
}

class _TGlassBackgroundState extends ConsumerState<TGlassBackground> with SingleTickerProviderStateMixin {
  Duration _idle = const Duration(seconds: 10);
  static const _autoSpeed = 2 * pi / TGlassTuning.autoDriftLoopSeconds; // radians per second

  final _phase = ValueNotifier<double>(0);
  final _pointer = ValueNotifier<Offset>(const Offset(0.5, 0.5)); // smoothed, 0-1
  Offset _target = const Offset(0.5, 0.5);
  late final Ticker _ticker = createTicker(_tick);
  Timer? _idleTimer;
  Duration _last = Duration.zero;
  bool _auto = false;
  bool _enabled = false;

  void _sync(bool enabled) {
    if (enabled == _enabled) return;
    _enabled = enabled;
    if (enabled) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
      _restartIdle();
    } else {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
      _idleTimer?.cancel();
      _auto = false;
      if (_ticker.isActive) _ticker.stop();
    }
  }

  void _restartIdle() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idle, () {
      _auto = true;
      _start();
    });
  }

  void _start() {
    if (_ticker.isActive) return;
    _last = Duration.zero;
    _ticker.start();
  }

  void _onPointer(PointerEvent e) {
    if (e is! PointerHoverEvent && e is! PointerMoveEvent && e is! PointerDownEvent) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || box.size.isEmpty) return;
    final p = box.globalToLocal(e.position);
    _target = Offset((p.dx / box.size.width).clamp(0, 1), (p.dy / box.size.height).clamp(0, 1));
    _auto = false;
    _restartIdle();
    _start();
  }

  void _tick(Duration now) {
    final dt = _last == Duration.zero ? 0.016 : (now - _last).inMicroseconds / 1e6;
    _last = now;
    // Ease the pointer influence toward the target, frame-rate independent.
    final k = 1 - exp(-dt * TGlassTuning.pointerEase);
    final next = Offset.lerp(_pointer.value, _target, k)!;
    final moving = (next - _target).distance > 0.001;
    _pointer.value = moving ? next : _target;
    if (_auto) _phase.value += dt * _autoSpeed;
    if (!_auto && !moving) _ticker.stop();
  }

  @override
  void dispose() {
    _sync(false);
    _ticker.dispose();
    _phase.dispose();
    _pointer.dispose();
    super.dispose();
  }

  /// Blurred (or plain) photo. Kept in its own repaint boundary so the parallax moves a cached layer instead of
  /// re-blurring the photo every frame.
  Widget photo(double blur, Widget image) => RepaintBoundary(
        child: blur > 0
            ? ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur, tileMode: TileMode.mirror), child: image)
            : image,
      );

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final dark = scheme.isDarkMode;
    final state = ref.watch(themeNotifierProvider);
    // One stable layer stack for the whole load: BlurHash preview (always the same keyed element, so it is never
    // rebuilt or re-decoded) with the real image fading in on top once it has decoded. Changing the tree shape between
    // "loading" and "loaded" is what used to restart the preview and flash empty frames.
    ImageFrameBuilder fade(int ms) => (c, child, frame, sync) => AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: Duration(milliseconds: ms),
          curve: Curves.easeInOut,
          child: child,
        );
    final frame = fade(700);
    // Image source: the user's image, else the code-set asset (kept locally after its first download).
    final hash = state.glassImageHash ?? state.glassAssetHash;
    // A user image that is still loading from storage must not be preceded by the code asset: its own BlurHash and
    // thumbnail hold the place until the bytes arrive.
    final userImage = state.glassImageHash != null || state.glassImageThumb != null;
    final bytes = state.glassImageBytes ?? (userImage ? null : state.glassAssetBytes);
    final Widget? real = state.glassStatic && bytes != null
        ? Image.memory(bytes,
            key: ValueKey('glass-image-${identityHashCode(bytes)}'), fit: BoxFit.cover, gaplessPlayback: true, frameBuilder: frame)
        : null;
    // An asset that is still being fetched counts as loading: show the preview (or nothing), never the animated blobs.
    final loading = state.glassStatic && bytes == null && state.glassImageAsset != null;
    // Middle stage: the code-supplied tiny thumbnail, stretched (so naturally soft) and faded in over the BlurHash.
    // The user's own thumbnail replaces the one from code as soon as they have their own image.
    final thumbBytes = state.glassImageThumb ?? (state.glassImageHash != null ? null : state.glassThumbBytes);
    final thumb = state.glassStatic && thumbBytes != null
        ? Image.memory(thumbBytes,
            key: ValueKey('glass-thumb-${identityHashCode(thumbBytes)}'),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
            frameBuilder: fade(450))
        : null;
    final image = state.glassStatic && (real != null || hash != null || thumb != null || loading)
        ? Stack(fit: StackFit.expand, children: [
            if (hash != null) TBlurHashView(key: const ValueKey('glass-blurhash'), hash: hash),
            if (thumb != null) thumb,
            if (real != null) real,
          ])
        : null;
    final idle = Duration(seconds: state.glassIdleSeconds);
    if (idle != _idle) {
      _idle = idle;
      if (_enabled && !_auto) _restartIdle();
    }
    // The pointer reaction and auto drift drive both the blobs and the image's parallax.
    _sync(state.glassAnimated);

    if (image != null) {
      final blur = state.glassImageBlur;
      return Stack(fit: StackFit.expand, children: [
        // Blur softens photo detail so it doesn't fight the content; the clip stops blurred edges bleeding in.
        ClipRect(child: photo(blur, image)),
        // Scrim so glass surfaces and text stay readable over any photo.
        ColoredBox(color: Colors.black.withAlpha((state.glassImageDim * 2.55).round())),
        // Colour blobs from the photo's palette drift over it: pulled by the pointer, wandering on their own when idle.
        // No RepaintBoundary: the blend mode has to blend with the photo below.
        if (state.glassAnimated)
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _BlobPainter(
                _phase,
                _pointer,
                state.glassColors ?? TGlassTuning.defaultBlobColors,
                Colors.transparent,
                dark
                    ? state.glassImageBlobAlpha
                    : (state.glassImageBlobAlpha * TGlassTuning.imageBlobAlphaLight / TGlassTuning.imageBlobAlphaDark)
                        .round()
                        .clamp(0, 255),
                drawBase: false,
                radiusFactor: TGlassTuning.imageBlobRadius,
                blend: TGlassTuning.imageBlobBlend,
              ),
            ),
          ),
        widget.child,
      ]);
    }

    final raw = widget.colors ?? state.glassColors ?? TGlassTuning.defaultBlobColors;
    // Light mode: the full palette, lifted slightly toward white; the low blob alpha keeps it pastel instead of muddy.
    final blobs = dark ? raw : [for (final c in raw) Color.lerp(c, Colors.white, 0.3)!];
    final base = dark ? Color.lerp(scheme.surface, scheme.primary, 0.12)! : Colors.white;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
              painter: _BlobPainter(
                  _phase,
                  _pointer,
                  blobs,
                  base,
                  dark
                      ? state.glassBlobAlpha
                      : (state.glassBlobAlpha * TGlassTuning.blobAlphaLight / TGlassTuning.blobAlphaDark).round().clamp(0, 255))),
        ),
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  final ValueNotifier<double> phase;
  final ValueNotifier<Offset> pointer;
  final List<Color> colors;
  final Color base;
  final int alpha;
  final bool drawBase;
  final double radiusFactor;
  final BlendMode blend;

  _BlobPainter(this.phase, this.pointer, this.colors, this.base, this.alpha,
      {this.drawBase = true, this.radiusFactor = 0.45, this.blend = BlendMode.srcOver})
      : super(repaint: Listenable.merge([phase, pointer]));

  @override
  void paint(Canvas canvas, Size size) {
    if (drawBase) canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final radius = size.longestSide * radiusFactor;
    final p = pointer.value - const Offset(0.5, 0.5);
    for (var i = 0; i < colors.length; i++) {
      // Each blob follows its own Lissajous path (advanced only by auto drift) and is pulled by the pointer by its
      // own signed amount, so blobs spread and swirl as the pointer moves.
      final a = phase.value * (1 + i % 2) + i * 1.7;
      final b = phase.value * (1 + (i + 1) % 2) + i * 2.3;
      final pull = (i.isEven ? 1 : -1) * (TGlassTuning.pointerPull + 0.15 * (i % 3));
      final center = Offset(
        size.width * (0.5 + 0.4 * sin(a) + p.dx * pull),
        size.height * (0.5 + 0.4 * cos(b) + p.dy * pull),
      );
      final shader = RadialGradient(
        colors: [colors[i].withAlpha(alpha), colors[i].withAlpha(0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(
          center,
          radius,
          Paint()
            ..shader = shader
            ..blendMode = blend);
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

  /// Dark mode: a light frosted wash instead of the (dark) [color], which would read as a dark slab over the backdrop.
  final bool frosted;

  const TGlassBar(
      {super.key, required this.style, required this.color, required this.child, this.dividerOnTop = true, this.frosted = false});

  /// [child] wrapped in a glass bar when glass is active, else [fallback] built around it.
  static Widget wrap(BuildContext context, {required Color color, required Widget child, bool dividerOnTop = true, bool frosted = false}) {
    final style = TGlassStyle.resolve(context);
    if (style == null) return child;
    return TGlassBar(style: style, color: color, dividerOnTop: dividerOnTop, frosted: frosted, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.colors.isDarkMode;
    final edge = BorderSide(color: Colors.white.withAlpha(style.borderAlpha));
    return ClipRect(
      child: BackdropFilter(
        filter: style.backdropFilterFor(dark),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: frosted && dark ? Colors.white.withAlpha(22) : color.withAlpha(dark ? style.fillAlpha : style.lightFillAlpha),
            border: dividerOnTop ? Border(top: edge) : Border(bottom: edge),
          ),
          child: child,
        ),
      ),
    );
  }
}
