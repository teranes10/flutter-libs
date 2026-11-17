import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Minimal BlurHash encoder/decoder (https://blurha.sh): a ~30 character string that describes a blurry preview
/// of an image, small enough to keep in preferences or a database and show instantly while the real image loads.
///
/// ```dart
/// final hash = await TBlurHash.fromImageBytes(bytes); // store it next to the image
/// ...
/// TBlurHashView(hash: hash)                           // instant placeholder, no network or decoding of the image
/// ```
///
/// Pure Dart, no dependencies. More components (see [encode]) give a sharper preview and a longer hash.
abstract final class TBlurHash {
  static const _chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#\$%*+,-.:;=?@[]^_{|}~';

  static String _enc83(int value, int length) {
    final b = StringBuffer();
    for (var i = 1; i <= length; i++) {
      b.write(_chars[(value ~/ pow(83, length - i).toInt()) % 83]);
    }
    return b.toString();
  }

  static int _dec83(String s) {
    var v = 0;
    for (final c in s.split('')) {
      v = v * 83 + _chars.indexOf(c);
    }
    return v;
  }

  static double _toLinear(int v) {
    final x = v / 255;
    return x <= 0.04045 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4).toDouble();
  }

  static int _toSrgb(double v) {
    final x = v.clamp(0.0, 1.0);
    return ((x <= 0.0031308 ? x * 12.92 : 1.055 * pow(x, 1 / 2.4) - 0.055) * 255 + 0.5).toInt();
  }

  static double _signPow(double v, double e) => (v < 0 ? -1 : 1) * pow(v.abs(), e).toDouble();

  /// Encodes straight RGBA [pixels] of size [width]x[height]. Use a small image (e.g. 32px wide): it is sampled fully.
  static String encode(Uint8List pixels, int width, int height, {int componentsX = 4, int componentsY = 3}) {
    final factors = <List<double>>[];
    for (var y = 0; y < componentsY; y++) {
      for (var x = 0; x < componentsX; x++) {
        final norm = (x == 0 && y == 0) ? 1.0 : 2.0;
        double r = 0, g = 0, b = 0;
        for (var py = 0; py < height; py++) {
          for (var px = 0; px < width; px++) {
            final basis = norm * cos(pi * x * px / width) * cos(pi * y * py / height);
            final i = 4 * (py * width + px);
            r += basis * _toLinear(pixels[i]);
            g += basis * _toLinear(pixels[i + 1]);
            b += basis * _toLinear(pixels[i + 2]);
          }
        }
        final scale = 1 / (width * height);
        factors.add([r * scale, g * scale, b * scale]);
      }
    }
    final dc = factors.first;
    final ac = factors.sublist(1);
    final out = StringBuffer(_enc83((componentsX - 1) + (componentsY - 1) * 9, 1));
    double maxVal = 1;
    if (ac.isNotEmpty) {
      final actual = ac.expand((f) => f).map((v) => v.abs()).reduce(max);
      final q = (actual * 166 - 0.5).floor().clamp(0, 82);
      maxVal = (q + 1) / 166;
      out.write(_enc83(q, 1));
    } else {
      out.write(_enc83(0, 1));
    }
    out.write(_enc83((_toSrgb(dc[0]) << 16) + (_toSrgb(dc[1]) << 8) + _toSrgb(dc[2]), 4));
    int q(double v) => (_signPow(v / maxVal, 0.5) * 9 + 9.5).floor().clamp(0, 18);
    for (final f in ac) {
      out.write(_enc83(q(f[0]) * 19 * 19 + q(f[1]) * 19 + q(f[2]), 2));
    }
    return out.toString();
  }

  /// Decodes [hash] to RGBA pixels of [width]x[height]; null when the hash is malformed.
  static Uint8List? decode(String hash, int width, int height) {
    try {
      if (hash.length < 6) return null;
      final sizeFlag = _dec83(hash[0]);
      final ny = sizeFlag ~/ 9 + 1, nx = sizeFlag % 9 + 1;
      if (hash.length != 4 + 2 * nx * ny) return null;
      final maxVal = (_dec83(hash[1]) + 1) / 166;
      final colors = <List<double>>[];
      for (var i = 0; i < nx * ny; i++) {
        if (i == 0) {
          final v = _dec83(hash.substring(2, 6));
          colors.add([_toLinear(v >> 16), _toLinear((v >> 8) & 255), _toLinear(v & 255)]);
        } else {
          final v = _dec83(hash.substring(4 + i * 2, 6 + i * 2));
          colors.add([
            _signPow(((v ~/ (19 * 19)) - 9) / 9, 2) * maxVal,
            _signPow((((v ~/ 19) % 19) - 9) / 9, 2) * maxVal,
            _signPow(((v % 19) - 9) / 9, 2) * maxVal,
          ]);
        }
      }
      final out = Uint8List(width * height * 4);
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          double r = 0, g = 0, b = 0;
          for (var j = 0; j < ny; j++) {
            for (var i = 0; i < nx; i++) {
              final basis = cos(pi * x * i / width) * cos(pi * y * j / height);
              final c = colors[i + j * nx];
              r += c[0] * basis;
              g += c[1] * basis;
              b += c[2] * basis;
            }
          }
          final o = 4 * (y * width + x);
          out[o] = _toSrgb(r);
          out[o + 1] = _toSrgb(g);
          out[o + 2] = _toSrgb(b);
          out[o + 3] = 255;
        }
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  /// Hash of encoded image [bytes] (any format Flutter can decode), or null if decoding fails.
  static Future<String?> fromImageBytes(Uint8List bytes, {int componentsX = 4, int componentsY = 3}) async {
    try {
      final img = await _decodeSmall(bytes, 32);
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return null;
      return encode(data.buffer.asUint8List(), img.width, img.height, componentsX: componentsX, componentsY: componentsY);
    } catch (_) {
      return null;
    }
  }

  /// Renders [hash] as a small [ui.Image] (scale it up when drawing).
  static Future<ui.Image?> toImage(String hash, {int width = 32, int height = 32}) async {
    final px = decode(hash, width, height);
    if (px == null) return null;
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(px, width, height, ui.PixelFormat.rgba8888, c.complete);
    return c.future;
  }

  static Future<ui.Image> _decodeSmall(Uint8List bytes, int width) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    return (await codec.getNextFrame()).image;
  }
}
