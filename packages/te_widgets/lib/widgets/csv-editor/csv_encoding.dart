import 'dart:convert';
import 'dart:typed_data';

/// Text encodings supported when reading and writing CSV / JSON files.
enum TCsvEncoding {
  utf8('UTF-8'),
  utf8Bom('UTF-8 with BOM (Excel)'),
  utf16le('UTF-16 LE'),
  utf16be('UTF-16 BE'),
  windows1252('Windows-1252 (Western)'),
  latin1('ISO-8859-1 (Latin-1)'),
  ascii('ASCII');

  final String label;
  const TCsvEncoding(this.label);

  /// Windows-1252 code points for bytes 0x80–0x9F (0 = undefined).
  static const _cp1252 = <int>[
    0x20AC, 0, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0, 0x017D, 0, //
    0, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0, 0x017E, 0x0178,
  ];

  /// Detects the encoding of [bytes] (BOM, UTF-16 heuristics, strict UTF-8, then Windows-1252).
  static TCsvEncoding detect(Uint8List bytes) {
    if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) return utf8Bom;
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) return utf16le;
    if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) return utf16be;

    // BOM-less UTF-16: ASCII-heavy text has a zero byte in every other position.
    final sample = bytes.length < 512 ? bytes.length : 512;
    if (sample >= 4) {
      var evenZeros = 0, oddZeros = 0;
      for (var i = 0; i < sample; i++) {
        if (bytes[i] == 0) i.isEven ? evenZeros++ : oddZeros++;
      }
      final half = sample / 2;
      if (oddZeros > half * 0.6 && evenZeros == 0) return utf16le;
      if (evenZeros > half * 0.6 && oddZeros == 0) return utf16be;
    }

    try {
      const Utf8Decoder(allowMalformed: false).convert(bytes);
      return utf8;
    } on FormatException {
      return windows1252;
    }
  }

  /// Decodes [bytes] with [encoding], or the auto-detected one. Strips any BOM.
  static ({String text, TCsvEncoding encoding}) decode(Uint8List bytes, {TCsvEncoding? encoding}) {
    final enc = encoding ?? detect(bytes);
    final text = switch (enc) {
      utf8 || utf8Bom => const Utf8Decoder(allowMalformed: true).convert(bytes, _hasBom(bytes, 3) ? 3 : 0),
      utf16le => _decode16(bytes, Endian.little),
      utf16be => _decode16(bytes, Endian.big),
      windows1252 => String.fromCharCodes(bytes.map((b) => b >= 0x80 && b <= 0x9F && _cp1252[b - 0x80] != 0 ? _cp1252[b - 0x80] : b)),
      latin1 => String.fromCharCodes(bytes),
      ascii => String.fromCharCodes(bytes.map((b) => b < 0x80 ? b : 0xFFFD)),
    };
    return (text: text, encoding: enc);
  }

  /// Encodes [text] with this encoding (BOM included for UTF-8 BOM and UTF-16).
  Uint8List encode(String text) {
    switch (this) {
      case utf8:
        return Uint8List.fromList(const Utf8Encoder().convert(text));
      case utf8Bom:
        return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...const Utf8Encoder().convert(text)]);
      case utf16le:
      case utf16be:
        final le = this == utf16le;
        final units = text.codeUnits;
        final data = ByteData(2 + units.length * 2)..setUint16(0, 0xFEFF, le ? Endian.little : Endian.big);
        for (var i = 0; i < units.length; i++) {
          data.setUint16(2 + i * 2, units[i], le ? Endian.little : Endian.big);
        }
        return data.buffer.asUint8List();
      case windows1252:
        return Uint8List.fromList(text.runes.map((r) {
          if (r < 0x80 || (r >= 0xA0 && r <= 0xFF)) return r;
          final idx = _cp1252.indexOf(r);
          return idx >= 0 && r != 0 ? 0x80 + idx : 0x3F;
        }).toList());
      case latin1:
        return Uint8List.fromList(text.runes.map((r) => r <= 0xFF ? r : 0x3F).toList());
      case ascii:
        return Uint8List.fromList(text.runes.map((r) => r < 0x80 ? r : 0x3F).toList());
    }
  }

  static bool _hasBom(Uint8List b, int n) => n == 3 && b.length >= 3 && b[0] == 0xEF && b[1] == 0xBB && b[2] == 0xBF;

  static String _decode16(Uint8List bytes, Endian endian) {
    final data = ByteData.sublistView(bytes);
    var start = 0;
    if (bytes.length >= 2) {
      final bom = data.getUint16(0, Endian.big);
      if (bom == 0xFFFE || bom == 0xFEFF) start = 2;
    }
    final units = <int>[for (var i = start; i + 1 < bytes.length; i += 2) data.getUint16(i, endian)];
    return String.fromCharCodes(units);
  }
}
