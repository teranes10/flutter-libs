import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Colours picked from a background image: [primary] for the accent, [secondary] for the second colour, and a
/// short [mix] for the glass blobs.
class TGlassImagePalette {
  final Color primary;
  final Color secondary;
  final List<Color> mix;
  const TGlassImagePalette(this.primary, this.secondary, this.mix);

  /// Samples a small copy of [bytes] and picks the most prominent, colourful, non-extreme colours.
  /// Returns null when the image cannot be decoded.
  static Future<TGlassImagePalette?> fromBytes(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 64);
      final img = (await codec.getNextFrame()).image;
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return null;
      final px = data.buffer.asUint8List();

      // 4 bits per channel histogram.
      final counts = <int, int>{};
      var lumSum = 0.0, lumN = 0;
      for (var i = 0; i < px.length; i += 4) {
        if (px[i + 3] < 128) continue;
        lumSum += (0.2126 * px[i] + 0.7152 * px[i + 1] + 0.0722 * px[i + 2]) / 255;
        lumN++;
        final key = ((px[i] >> 4) << 8) | ((px[i + 1] >> 4) << 4) | (px[i + 2] >> 4);
        counts[key] = (counts[key] ?? 0) + 1;
      }
      final scored = <(HSLColor, double)>[];
      counts.forEach((key, n) {
        final c = Color.fromARGB(255, ((key >> 8) & 15) * 17, ((key >> 4) & 15) * 17, (key & 15) * 17);
        final hsl = HSLColor.fromColor(c);
        // Skip near-grey and near-white/black bins; dark tones are kept, they get lightened below.
        if (hsl.saturation < 0.18 || hsl.lightness < 0.06 || hsl.lightness > 0.9) return;
        scored.add((hsl, n * (0.3 + hsl.saturation)));
      });
      if (scored.isEmpty) return null;
      scored.sort((a, b) => b.$2.compareTo(a.$2));

      // Pick distinct hues.
      final picked = <HSLColor>[];
      for (final (c, _) in scored) {
        final distinct = picked.every((p) {
          final d = (p.hue - c.hue).abs();
          return (d > 180 ? 360 - d : d) > 35;
        });
        if (distinct) picked.add(c);
        if (picked.length == 4) break;
      }
      // The darker the photo, the lighter the accent has to be to stand out against it and the dark UI: a dark tone
      // keeps its hue but is lifted to a floor that depends on the image's average brightness.
      final avg = lumN == 0 ? 0.5 : lumSum / lumN;
      final floor = avg < 0.2 ? 0.72 : (avg < 0.35 ? 0.66 : 0.58);
      Color tune(HSLColor c) =>
          c.withSaturation(c.saturation.clamp(0.5, 0.85)).withLightness(c.lightness.clamp(floor, floor + 0.1)).toColor();
      final tuned = [for (final c in picked) tune(c)];
      final primary = tuned.first;
      final secondary =
          tuned.length > 1 ? tuned[1] : HSLColor.fromColor(primary).withHue((HSLColor.fromColor(primary).hue + 30) % 360).toColor();
      final mix = [...tuned];
      while (mix.length < 4) {
        mix.add(Color.lerp(primary, secondary, mix.length / 4)!);
      }
      return TGlassImagePalette(primary, secondary, mix);
    } catch (_) {
      return null;
    }
  }
}
