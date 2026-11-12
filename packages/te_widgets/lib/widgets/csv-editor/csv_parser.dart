import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:hugeicons/hugeicons.dart';
import 'csv_column.dart';
import 'csv_header_mapper.dart';

/// Supported data and file formats for [TCsvParser] and [TCsvEditor].
enum TCsvFileFormat {
  /// Standard comma-separated values (`,`).
  csv,

  /// Tab-separated values (`\t`).
  tsv,

  /// Semicolon-separated values (`;`).
  semicolon,

  /// Pipe-separated values (`|`).
  pipe,

  /// JSON formatted data (`.json` array or wrapped object).
  json,

  /// Custom delimiter format.
  custom;

  /// Default file extension (without leading dot).
  String get extension => switch (this) {
        TCsvFileFormat.csv => 'csv',
        TCsvFileFormat.tsv => 'tsv',
        TCsvFileFormat.semicolon => 'csv',
        TCsvFileFormat.pipe => 'psv',
        TCsvFileFormat.json => 'json',
        TCsvFileFormat.custom => 'txt',
      };

  /// Human-readable label.
  String get label => switch (this) {
        TCsvFileFormat.csv => 'CSV (Comma ,)',
        TCsvFileFormat.tsv => 'TSV (Tab \\t)',
        TCsvFileFormat.semicolon => 'CSV (Semicolon ;)',
        TCsvFileFormat.pipe => 'PSV (Pipe |)',
        TCsvFileFormat.json => 'JSON (.json)',
        TCsvFileFormat.custom => 'Custom Delimiter',
      };

  /// Short badge label.
  String get shortLabel => switch (this) {
        TCsvFileFormat.csv => 'CSV',
        TCsvFileFormat.tsv => 'TSV',
        TCsvFileFormat.semicolon => 'Semicolon',
        TCsvFileFormat.pipe => 'Pipe',
        TCsvFileFormat.json => 'JSON',
        TCsvFileFormat.custom => 'Custom',
      };

  /// Associated delimiter character if delimited format.
  String? get delimiter => switch (this) {
        TCsvFileFormat.csv => ',',
        TCsvFileFormat.tsv => '\t',
        TCsvFileFormat.semicolon => ';',
        TCsvFileFormat.pipe => '|',
        TCsvFileFormat.json => null,
        TCsvFileFormat.custom => null,
      };

  /// Associated icon.
  dynamic get icon => switch (this) {
        TCsvFileFormat.json => HugeIcons.strokeRoundedBraces,
        TCsvFileFormat.tsv => HugeIcons.strokeRoundedTableColumnsSplit,
        TCsvFileFormat.pipe => HugeIcons.strokeRoundedDeleteColumn,
        TCsvFileFormat.semicolon => HugeIcons.strokeRoundedGrid,
        _ => HugeIcons.strokeRoundedTable,
      };

  /// Mime type for file saving.
  MimeType get mimeType => switch (this) {
        TCsvFileFormat.json => MimeType.json,
        TCsvFileFormat.csv || TCsvFileFormat.semicolon => MimeType.csv,
        TCsvFileFormat.tsv => MimeType.text,
        _ => MimeType.text,
      };
}

/// Standard delimiter characters for tabular data.
class TCsvDelimiter {
  static const String comma = ',';
  static const String semicolon = ';';
  static const String tab = '\t';
  static const String pipe = '|';
  static const String colon = ':';
  static const String caret = '^';
  static const String tilde = '~';

  /// Common delimiters, in detection priority order.
  static const List<String> allCandidates = [comma, semicolon, tab, pipe, colon, caret, tilde];

  /// Human-readable name for [delimiter].
  static String nameOf(String delimiter) => switch (delimiter) {
        comma => 'Comma (,)',
        semicolon => 'Semicolon (;)',
        tab => 'Tab (\\t)',
        pipe => 'Pipe (|)',
        colon => 'Colon (:)',
        caret => 'Caret (^)',
        tilde => 'Tilde (~)',
        _ => 'Custom ($delimiter)',
      };

  /// Maps a delimiter to its [TCsvFileFormat].
  static TCsvFileFormat formatOf(String delimiter) => switch (delimiter) {
        comma => TCsvFileFormat.csv,
        tab => TCsvFileFormat.tsv,
        semicolon => TCsvFileFormat.semicolon,
        pipe => TCsvFileFormat.pipe,
        _ => TCsvFileFormat.custom,
      };
}

/// JSON layouts understood on import and available on export.
enum TJsonStyle {
  /// `[{"a":1}, {"a":2}]`
  arrayOfObjects('Array of objects'),

  /// `[["a"], [1], [2]]` (first row = headers)
  arrayOfArrays('Array of arrays (header row first)'),

  /// `{"a":[1,2], "b":[3,4]}`
  columns('Columns (object of arrays)'),

  /// `{"data": [{"a":1}]}`
  wrapped('Wrapped in a property'),

  /// One JSON object per line (JSON Lines / NDJSON).
  lines('JSON Lines (NDJSON)'),

  /// `{"id1": {"a":1}, "id2": {"a":2}}` (import only)
  keyed('Object keyed by id'),

  /// A single object (import only).
  single('Single object');

  final String label;
  const TJsonStyle(this.label);

  /// Whether this style can be chosen for export.
  bool get exportable => this != keyed && this != single;
}

/// Indentation used when serializing JSON.
enum TJsonIndent {
  minified('Minified'),
  two('2 spaces'),
  four('4 spaces'),
  tab('Tab');

  final String label;
  const TJsonIndent(this.label);

  String? get indent => switch (this) {
        minified => null,
        two => '  ',
        four => '    ',
        tab => '\t',
      };
}

/// Structured result of parsing CSV, TSV, DSV, or JSON data.
class TCsvParseResult {
  /// Detected file or data format.
  final TCsvFileFormat format;

  /// Effective delimiter used (null if JSON).
  final String? delimiter;

  /// Extracted column headers / JSON object keys.
  final List<String> headers;

  /// Stringified table row cells: `List<List<String>>`.
  final List<List<String>> rows;

  /// Original JSON maps if parsed from a JSON payload.
  final List<Map<String, dynamic>>? jsonMaps;

  /// Detected JSON layout (null if not JSON).
  final TJsonStyle? jsonStyle;

  const TCsvParseResult({
    required this.format,
    this.delimiter,
    required this.headers,
    required this.rows,
    this.jsonMaps,
    this.jsonStyle,
  });

  bool get isEmpty => headers.isEmpty && rows.isEmpty && (jsonMaps == null || jsonMaps!.isEmpty);
  bool get isNotEmpty => !isEmpty;
}

/// Robust parser and generator for CSV, TSV, Semicolon, Pipe, and JSON data.
///
/// Compliant with RFC-4180, supporting:
/// - Quoted cells with commas, semicolons, tabs, pipes, and escaped quotes (`""`).
/// - Multiline quoted cells.
/// - Auto-detection of delimiters (`,`, `;`, `\t`, `|`).
/// - Auto-detection of JSON payload vs delimited tabular text.
/// - Byte Order Mark (BOM) stripping.
/// - Export & Template generation in CSV, TSV, Semicolon, Pipe, and JSON formats.
class TCsvParser {
  /// Checks whether a text string contains JSON data (array, object, or JSON Lines).
  static bool isJson(String content) => _decodeJson(content) != null;

  /// Decodes JSON or JSON Lines; returns null when [content] is not JSON.
  static ({dynamic value, bool lines})? _decodeJson(String content) {
    var text = content;
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    text = text.trim();
    if (text.isEmpty || !(text.startsWith('[') || text.startsWith('{'))) return null;
    try {
      final v = jsonDecode(text);
      if (v is List || v is Map) return (value: v, lines: false);
    } catch (_) {}

    // JSON Lines: every non-empty line is its own JSON value.
    final lines = text.split(RegExp(r'\r\n|\r|\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.length < 2) return null;
    try {
      final values = lines.map((l) => jsonDecode(l.trim())).toList();
      if (values.every((v) => v is Map || v is List)) return (value: values, lines: true);
    } catch (_) {}
    return null;
  }

  /// Auto-detects the data format (JSON, TSV, Semicolon, Pipe, CSV) from content.
  static TCsvFileFormat detectFormat(String content) {
    if (isJson(content)) {
      return TCsvFileFormat.json;
    }
    final delimiter = detectDelimiter(content);
    return TCsvDelimiter.formatOf(delimiter);
  }

  /// Auto-detects the most likely delimiter (`,` `;` tab `|` `:` `^` `~`).
  ///
  /// Scores each candidate by how consistently it appears the same number of
  /// times (outside quotes) on the first lines; rarer candidates must be fully consistent.
  static String detectDelimiter(String content) {
    var text = content;
    if (text.startsWith('\uFEFF')) text = text.substring(1);

    final lines = text.split(RegExp(r'\r\n|\r|\n')).where((l) => l.trim().isNotEmpty).take(20).toList();
    if (lines.isEmpty) return ',';

    String best = ',';
    double bestScore = 0;

    for (final (i, d) in TCsvDelimiter.allCandidates.indexed) {
      final counts = <int>[];
      for (final line in lines) {
        var n = 0;
        var inQuote = false;
        for (var k = 0; k < line.length; k++) {
          final c = line[k];
          if (c == '"') {
            inQuote = !inQuote;
          } else if (!inQuote && c == d) {
            n++;
          }
        }
        counts.add(n);
      }
      // Most common non-zero count and how many lines agree with it.
      final freq = <int, int>{};
      for (final n in counts) {
        if (n > 0) freq[n] = (freq[n] ?? 0) + 1;
      }
      if (freq.isEmpty) continue;
      final mode = freq.entries.reduce((a, b) => b.value > a.value ? b : a);
      final consistency = mode.value / lines.length;
      final rare = i >= 4;
      if (rare && consistency < 1) continue;
      if (consistency < 0.6) continue;
      // Prefer consistency, then more columns; earlier candidates win ties.
      final score = consistency * 1000 + mode.key - i * 0.001;
      if (score > bestScore) {
        bestScore = score;
        best = d;
      }
    }
    return best;
  }

  /// Parses JSON string content (any supported [TJsonStyle]) into a list of flat maps.
  static List<Map<String, dynamic>> parseJson(String content) => parseJsonDetailed(content).maps;

  /// Like [parseJson] but also reports the detected [TJsonStyle].
  static ({List<Map<String, dynamic>> maps, TJsonStyle style}) parseJsonDetailed(String content) {
    final decoded = _decodeJson(content);
    if (decoded == null) return (maps: const [], style: TJsonStyle.arrayOfObjects);
    if (decoded.lines) {
      final rows = decoded.value as List;
      return (maps: rows.expand((r) => _normalize(r).maps).toList(), style: TJsonStyle.lines);
    }
    return _normalize(decoded.value);
  }

  static const _wrapperKeys = ['data', 'items', 'rows', 'records', 'results', 'result', 'list', 'products', 'content', 'entries'];

  static ({List<Map<String, dynamic>> maps, TJsonStyle style}) _normalize(dynamic v, {int depth = 0}) {
    if (v is List) {
      if (v.isNotEmpty && v.every((e) => e is List)) {
        final rows = v.cast<List>();
        final first = rows.first;
        final hasHeader = rows.length > 1 && first.isNotEmpty && first.every((e) => e is String);
        final headers = hasHeader ? first.map((e) => e.toString()).toList() : List.generate(first.length, (i) => 'column_${i + 1}');
        final body = hasHeader ? rows.skip(1) : rows;
        return (
          maps: body.map((r) => {for (var i = 0; i < headers.length; i++) headers[i]: i < r.length ? _cell(r[i]) : null}).toList(),
          style: TJsonStyle.arrayOfArrays,
        );
      }
      return (
        maps: v.map((e) => e is Map ? _flatten(e) : <String, dynamic>{'value': _cell(e)}).toList(),
        style: TJsonStyle.arrayOfObjects,
      );
    }

    if (v is Map) {
      final values = v.values.toList();

      // Columns: {"a":[1,2],"b":[3,4]}
      if (values.isNotEmpty &&
          values.every((e) => e is List && e.every((x) => x is! Map && x is! List)) &&
          values.map((e) => (e as List).length).toSet().length == 1 &&
          (values.first as List).isNotEmpty) {
        final len = (values.first as List).length;
        final keys = v.keys.map((k) => k.toString()).toList();
        return (
          maps: List.generate(len, (i) => {for (var k = 0; k < keys.length; k++) keys[k]: _cell((values[k] as List)[i])}),
          style: TJsonStyle.columns,
        );
      }

      // Wrapped: {"data":[...]} — known keys first, then any list of objects/arrays.
      if (depth < 3) {
        final candidates = [
          ..._wrapperKeys.where(v.containsKey),
          ...v.keys.map((k) => k.toString()).where((k) => !_wrapperKeys.contains(k)),
        ];
        for (final key in candidates) {
          final inner = v[key];
          if (inner is List && inner.isNotEmpty && inner.every((e) => e is Map || e is List)) {
            return (maps: _normalize(inner, depth: depth + 1).maps, style: TJsonStyle.wrapped);
          }
        }
        for (final key in candidates) {
          final inner = v[key];
          if (inner is Map) {
            final r = _normalize(inner, depth: depth + 1);
            if (r.style == TJsonStyle.wrapped) return r;
          }
        }
      }

      // Keyed: {"id1": {...}, "id2": {...}}
      if (values.length > 1 && values.every((e) => e is Map)) {
        return (
          maps: v.entries.map((e) => {'_key': e.key.toString(), ..._flatten(e.value as Map)}).toList(),
          style: TJsonStyle.keyed,
        );
      }

      return (maps: [_flatten(v)], style: TJsonStyle.single);
    }

    return (maps: const [], style: TJsonStyle.arrayOfObjects);
  }

  /// Flattens nested objects into dot-notation keys; primitive lists are joined, others kept as JSON.
  static Map<String, dynamic> _flatten(Map map, [String prefix = '']) {
    final out = <String, dynamic>{};
    map.forEach((k, v) {
      final key = prefix.isEmpty ? k.toString() : '$prefix.$k';
      if (v is Map && v.isNotEmpty) {
        out.addAll(_flatten(v, key));
      } else {
        out[key] = _cell(v);
      }
    });
    return out;
  }

  static dynamic _cell(dynamic v) {
    if (v is List) {
      return v.every((e) => e is! Map && e is! List) ? v.map((e) => e ?? '').join(', ') : jsonEncode(v);
    }
    if (v is Map) return jsonEncode(v);
    return v;
  }

  /// Parses generic content (CSV, TSV, Semicolon, Pipe, or JSON) into a structured [TCsvParseResult].
  static TCsvParseResult parseGeneric(String content, {String? delimiter}) {
    if (content.trim().isEmpty) {
      return const TCsvParseResult(
        format: TCsvFileFormat.csv,
        headers: [],
        rows: [],
      );
    }

    String text = content;
    if (text.startsWith('\uFEFF')) {
      text = text.substring(1);
    }

    if (isJson(text)) {
      final detailed = parseJsonDetailed(text);
      final jsonMaps = detailed.maps;
      if (jsonMaps.isEmpty) {
        return const TCsvParseResult(
          format: TCsvFileFormat.json,
          headers: [],
          rows: [],
        );
      }

      // Collect all unique keys across all maps in order
      final headersSet = <String>{};
      for (final map in jsonMaps) {
        headersSet.addAll(map.keys);
      }
      final headers = headersSet.toList();

      final rows = jsonMaps.map((map) {
        return headers.map((h) => map[h]?.toString() ?? '').toList();
      }).toList();

      return TCsvParseResult(
        format: TCsvFileFormat.json,
        headers: headers,
        rows: rows,
        jsonMaps: jsonMaps,
        jsonStyle: detailed.style,
      );
    }

    // Delimited file
    final effectiveDelimiter = delimiter ?? detectDelimiter(text);
    final format = TCsvDelimiter.formatOf(effectiveDelimiter);

    final rawRows = parseDelimited(text, delimiter: effectiveDelimiter);
    if (rawRows.isEmpty) {
      return TCsvParseResult(
        format: format,
        delimiter: effectiveDelimiter,
        headers: const [],
        rows: const [],
      );
    }

    final headers = rawRows.first;
    final dataRows = rawRows.skip(1).toList();

    return TCsvParseResult(
      format: format,
      delimiter: effectiveDelimiter,
      headers: headers,
      rows: dataRows,
    );
  }

  /// Async [parseGeneric] that keeps the UI responsive for large delimited files.
  static Future<TCsvParseResult> parseGenericAsync(
    String content, {
    String? delimiter,
    void Function(double progress)? onProgress,
  }) async {
    var text = content;
    if (text.startsWith('\uFEFF')) text = text.substring(1);

    // JSON is decoded in one go (jsonDecode can't be sliced).
    if (text.trim().isEmpty || isJson(text)) return parseGeneric(text, delimiter: delimiter);

    final effectiveDelimiter = delimiter ?? detectDelimiter(text);
    final rawRows = await parseDelimitedAsync(text, delimiter: effectiveDelimiter, onProgress: onProgress);
    return TCsvParseResult(
      format: TCsvDelimiter.formatOf(effectiveDelimiter),
      delimiter: effectiveDelimiter,
      headers: rawRows.isEmpty ? const [] : rawRows.first,
      rows: rawRows.length > 1 ? rawRows.sublist(1) : const [],
    );
  }

  /// Parses standard delimited text (CSV, TSV, Semicolon, Pipe) into row cells.
  static List<List<String>> parseDelimited(String content, {String? delimiter}) {
    final rows = <List<String>>[];
    for (final _ in _parseDelimitedSteps(content, delimiter, rows)) {}
    return rows;
  }

  /// Like [parseDelimited] but yields to the event loop regularly so the UI keeps
  /// painting (spinners, progress) while a large file is parsed.
  ///
  /// [onProgress] receives a value from 0 to 1.
  static Future<List<List<String>>> parseDelimitedAsync(
    String content, {
    String? delimiter,
    void Function(double progress)? onProgress,
  }) async {
    final rows = <List<String>>[];
    final watch = Stopwatch()..start();
    for (final progress in _parseDelimitedSteps(content, delimiter, rows)) {
      if (watch.elapsedMilliseconds >= 10) {
        onProgress?.call(progress);
        await Future<void>.delayed(const Duration(milliseconds: 1));
        watch.reset();
      }
    }
    onProgress?.call(1);
    return rows;
  }

  /// Parse loop as a generator: fills [rows] and yields progress every few thousand characters.
  static Iterable<double> _parseDelimitedSteps(String content, String? delimiter, List<List<String>> rows) sync* {
    if (content.isEmpty) return;

    // Strip BOM if present
    String text = content;
    if (text.startsWith('\uFEFF')) {
      text = text.substring(1);
    }

    final effectiveDelimiter = delimiter ?? detectDelimiter(text);
    final delimiterCode = effectiveDelimiter.codeUnitAt(0);

    final currentRow = <String>[];
    final currentCell = StringBuffer();

    bool insideQuote = false;
    int i = 0;
    final length = text.length;

    while (i < length) {
      if (i & 0x3FFF == 0) yield i / length;
      final charCode = text.codeUnitAt(i);

      if (charCode == 34) {
        // Double quote "
        if (insideQuote) {
          // Check for escaped quote ""
          if (i + 1 < length && text.codeUnitAt(i + 1) == 34) {
            currentCell.write('"');
            i += 2;
            continue;
          } else {
            insideQuote = false;
          }
        } else {
          insideQuote = true;
        }
      } else if (!insideQuote && charCode == delimiterCode) {
        // Delimiter reached
        currentRow.add(currentCell.toString().trim());
        currentCell.clear();
      } else if (!insideQuote && (charCode == 10 || charCode == 13)) {
        // End of line (\n or \r)
        currentRow.add(currentCell.toString().trim());
        currentCell.clear();

        // Check for CRLF \r\n
        if (charCode == 13 && i + 1 < length && text.codeUnitAt(i + 1) == 10) {
          i++;
        }

        // Only add non-empty rows
        if (currentRow.any((c) => c.isNotEmpty)) {
          rows.add(List<String>.from(currentRow));
        }
        currentRow.clear();
      } else {
        currentCell.writeCharCode(charCode);
      }

      i++;
    }

    // Add last cell and row if any content remains
    if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentCell.toString().trim());
      if (currentRow.any((c) => c.isNotEmpty)) {
        rows.add(List<String>.from(currentRow));
      }
    }
  }

  /// Parses CSV / TSV / DSV / JSON text content into a list of row cells: `List<List<String>>`.
  /// Row 0 is headers, remaining rows are data records.
  static List<List<String>> parse(String content, {String? delimiter}) {
    if (isJson(content)) {
      final res = parseGeneric(content);
      if (res.headers.isEmpty && res.rows.isEmpty) return [];
      return [res.headers, ...res.rows];
    }
    return parseDelimited(content, delimiter: delimiter);
  }

  /// Parses any supported format (CSV, TSV, DSV, JSON) directly into typed Maps.
  /// If [columns] schema is provided, applies auto-mapping and type coercion.
  static List<Map<String, dynamic>> parseToMaps(
    String content, {
    List<TCsvColumn>? columns,
    String? delimiter,
  }) {
    final result = parseGeneric(content, delimiter: delimiter);
    if (result.isEmpty) return [];

    if (columns != null && columns.isNotEmpty) {
      final mapping = TCsvHeaderMapping.autoMap(
        expectedColumns: columns,
        csvHeaders: result.headers,
      );

      return result.rows.map((row) {
        return mapping.mapRow(
          expectedColumns: columns,
          csvHeaders: result.headers,
          csvRow: row,
        );
      }).toList();
    }

    // No columns schema provided: return direct map from headers to row values
    if (result.jsonMaps != null) {
      return result.jsonMaps!;
    }

    return result.rows.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < result.headers.length; i++) {
        final header = result.headers[i];
        map[header] = i < row.length ? row[i] : null;
      }
      return map;
    }).toList();
  }

  /// Converts headers and rows to a standard CSV formatted string with custom [delimiter].
  static String toCsv(List<String> headers, List<List<dynamic>> rows, {String delimiter = ','}) {
    final buffer = StringBuffer();

    // Escape and write header row
    buffer.writeln(headers.map((h) => _escapeCell(h, delimiter)).join(delimiter));

    // Escape and write data rows
    for (final row in rows) {
      buffer.writeln(row.map((cell) => _escapeCell(cell?.toString() ?? '', delimiter)).join(delimiter));
    }

    return buffer.toString();
  }

  /// Converts a list of Maps to a CSV / TSV / DSV formatted string with custom [delimiter].
  static String toCsvFromMaps(
    List<Map<String, dynamic>> maps, {
    List<TCsvColumn>? columns,
    List<String>? headers,
    String delimiter = ',',
  }) {
    if (maps.isEmpty) return '';

    final resolvedHeaders = headers ?? columns?.map((c) => c.header).toList() ?? maps.first.keys.toList();

    final keys = columns?.map((c) => c.key).toList() ?? headers ?? maps.first.keys.toList();

    final rows = maps.map((map) {
      return keys.map((k) {
        final val = map[k];
        if (columns != null) {
          final col = columns.firstWhere(
            (c) => c.key == k,
            orElse: () => TCsvColumn.text(key: k, header: k),
          );
          return col.formatValue(val);
        }
        return val?.toString() ?? '';
      }).toList();
    }).toList();

    return toCsv(resolvedHeaders, rows, delimiter: delimiter);
  }

  /// Shortcut helper to export to Tab-Separated Values (TSV).
  static String toTsv(List<String> headers, List<List<dynamic>> rows) => toCsv(headers, rows, delimiter: '\t');

  /// Shortcut helper to export to TSV from maps.
  static String toTsvFromMaps(List<Map<String, dynamic>> maps, {List<TCsvColumn>? columns, List<String>? headers}) =>
      toCsvFromMaps(maps, columns: columns, headers: headers, delimiter: '\t');

  /// Shortcut helper to export to Semicolon-Separated Values (`;`).
  static String toSemicolon(List<String> headers, List<List<dynamic>> rows) => toCsv(headers, rows, delimiter: ';');

  /// Shortcut helper to export to Semicolon-Separated Values from maps.
  static String toSemicolonFromMaps(List<Map<String, dynamic>> maps, {List<TCsvColumn>? columns, List<String>? headers}) =>
      toCsvFromMaps(maps, columns: columns, headers: headers, delimiter: ';');

  /// Shortcut helper to export to Pipe-Separated Values (`|`).
  static String toPipe(List<String> headers, List<List<dynamic>> rows) => toCsv(headers, rows, delimiter: '|');

  /// Shortcut helper to export to Pipe-Separated Values from maps.
  static String toPipeFromMaps(List<Map<String, dynamic>> maps, {List<TCsvColumn>? columns, List<String>? headers}) =>
      toCsvFromMaps(maps, columns: columns, headers: headers, delimiter: '|');

  /// Converts a list of row maps to a formatted JSON string.
  static String toJson(List<Map<String, dynamic>> maps, {bool pretty = true}) {
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(maps);
    }
    return jsonEncode(maps);
  }

  /// Serializes [maps] as JSON in the chosen [style].
  ///
  /// [keys] gives the column order for array-of-arrays / columns output.
  static String toJsonStyled(
    List<Map<String, dynamic>> maps, {
    TJsonStyle style = TJsonStyle.arrayOfObjects,
    TJsonIndent indent = TJsonIndent.two,
    String wrapperKey = 'data',
    List<String>? keys,
  }) {
    final k = keys ?? (maps.isEmpty ? <String>[] : maps.first.keys.toList());
    final encoder = indent.indent == null ? const JsonEncoder() : JsonEncoder.withIndent(indent.indent);

    switch (style) {
      case TJsonStyle.lines:
        return maps.map((m) => jsonEncode(m)).join('\n');
      case TJsonStyle.arrayOfArrays:
        return encoder.convert([k, ...maps.map((m) => k.map((c) => m[c]).toList())]);
      case TJsonStyle.columns:
        return encoder.convert({for (final c in k) c: maps.map((m) => m[c]).toList()});
      case TJsonStyle.wrapped:
        return encoder.convert({wrapperKey.isEmpty ? 'data' : wrapperKey: maps});
      case TJsonStyle.arrayOfObjects:
      case TJsonStyle.keyed:
      case TJsonStyle.single:
        return encoder.convert(maps);
    }
  }

  /// Converts headers and rows to a formatted JSON string.
  static String toJsonFromRows(
    List<String> headers,
    List<List<dynamic>> rows, {
    bool pretty = true,
    List<TCsvColumn>? columns,
  }) {
    final maps = rows.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        final header = headers[i];
        final val = i < row.length ? row[i] : null;

        if (columns != null) {
          final col = columns.firstWhere(
            (c) => c.header == header || c.key == header,
            orElse: () => TCsvColumn.text(key: header, header: header),
          );
          map[col.key] = col.parseValue(val);
        } else {
          map[header] = val;
        }
      }
      return map;
    }).toList();

    return toJson(maps, pretty: pretty);
  }

  /// Formats and exports data according to the target [TCsvFileFormat] or custom [delimiter].
  static String formatOutput(
    List<Map<String, dynamic>> maps, {
    TCsvFileFormat format = TCsvFileFormat.csv,
    List<TCsvColumn>? columns,
    String? delimiter,
    bool prettyJson = true,
  }) {
    if (format == TCsvFileFormat.json) {
      return toJson(maps, pretty: prettyJson);
    }

    final effectiveDelimiter = delimiter ?? format.delimiter ?? ',';
    return toCsvFromMaps(maps, columns: columns, delimiter: effectiveDelimiter);
  }

  static String _escapeCell(String value, String delimiter) {
    bool needsQuotes = value.contains(delimiter) || value.contains('"') || value.contains('\n') || value.contains('\r');
    if (needsQuotes) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Generates a sample template string based on a list of [TCsvColumn]s in any format.
  static String generateTemplate(
    List<TCsvColumn> columns, {
    bool includeSampleRow = true,
    String? delimiter,
    TCsvFileFormat format = TCsvFileFormat.csv,
    TJsonStyle jsonStyle = TJsonStyle.arrayOfObjects,
    TJsonIndent jsonIndent = TJsonIndent.two,
    String wrapperKey = 'data',
  }) {
    if (format == TCsvFileFormat.json) {
      final sampleMap = <String, dynamic>{};
      if (includeSampleRow) {
        for (final col in columns) {
          if (col.defaultValue != null) {
            sampleMap[col.key] = col.defaultValue;
          } else {
            sampleMap[col.key] = switch (col.type) {
              TCsvColumnType.text => 'Sample ${col.header}',
              TCsvColumnType.number => 29.99,
              TCsvColumnType.integer => 10,
              TCsvColumnType.boolean => true,
              TCsvColumnType.image => 'sample_${col.key.toLowerCase()}.jpg',
            };
          }
        }
      }
      return toJsonStyled(
        includeSampleRow ? [sampleMap] : [],
        style: jsonStyle,
        indent: jsonIndent,
        wrapperKey: wrapperKey,
        keys: columns.map((c) => c.key).toList(),
      );
    }

    final headers = columns.map((c) => c.header).toList();
    final sampleRows = <List<dynamic>>[];

    if (includeSampleRow) {
      final sampleRow = columns.map((col) {
        if (col.defaultValue != null) return col.formatValue(col.defaultValue);
        return switch (col.type) {
          TCsvColumnType.text => 'Sample ${col.header}',
          TCsvColumnType.number => '29.99',
          TCsvColumnType.integer => '10',
          TCsvColumnType.boolean => 'true',
          TCsvColumnType.image => 'sample_${col.key.toLowerCase()}.jpg',
        };
      }).toList();
      sampleRows.add(sampleRow);
    }

    return toCsv(headers, sampleRows, delimiter: delimiter ?? format.delimiter ?? ',');
  }
}
