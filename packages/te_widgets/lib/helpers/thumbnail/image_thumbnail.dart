import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Tiny image thumbnails for blurred placeholders (e.g. the glass background's "fade" stage).
///
/// The image is decoded at a few times the small size (never at full resolution), averaged down and re-encoded as PNG, the only encoder
/// `dart:ui` has. At 32-64px wide the result is a few KB, small enough to paste into source as a base64 string:
/// `initializeApp(glassImageThumbnail: '...')`.
abstract final class TImageThumbnail {
  /// PNG bytes of [bytes] scaled to [width] pixels wide (height keeps the aspect ratio); null if it cannot be decoded.
  ///
  /// The image is first decoded at [oversample] times the target width, then scaled down with high-quality filtering,
  /// so each thumbnail pixel is an average of its source area. Decoding straight at the tiny size can skip pixels
  /// instead of averaging them, which makes textured photos (foliage, water) look noisy and blotchy.
  static Future<Uint8List?> generate(Uint8List bytes, {int width = 48, int oversample = 4}) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: width * oversample);
      final src = (await codec.getNextFrame()).image;
      final w = width;
      final h = (width * src.height / src.width).round().clamp(1, 4096);

      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawImageRect(
        src,
        ui.Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble()),
        ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        ui.Paint()
          ..filterQuality = ui.FilterQuality.high
          ..isAntiAlias = true,
      );
      final picture = recorder.endRecording();
      final small = await picture.toImage(w, h);
      final data = await small.toByteData(format: ui.ImageByteFormat.png);
      small.dispose();
      picture.dispose();
      src.dispose();
      codec.dispose();
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// [generate] as a base64 string (no `data:` prefix).
  static Future<String?> generateBase64(Uint8List bytes, {int width = 48}) async {
    final png = await generate(bytes, width: width);
    return png == null ? null : base64Encode(png);
  }

  /// Bytes of a base64 thumbnail, accepting an optional `data:image/...;base64,` prefix; null when malformed.
  static Uint8List? fromBase64(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final comma = value.indexOf(',');
      var data = value.startsWith('data:') && comma > 0 ? value.substring(comma + 1) : value;
      // Tolerate pasted noise: whitespace, line breaks and stray characters such as a terminal's trailing `%`.
      data = data.replaceAll(RegExp(r'[^A-Za-z0-9+/=_-]'), '');
      return base64Decode(base64.normalize(data));
    } catch (_) {
      return null;
    }
  }
}
