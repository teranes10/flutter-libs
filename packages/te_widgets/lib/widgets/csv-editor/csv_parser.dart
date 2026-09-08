import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
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
  IconData get icon => switch (this) {
        TCsvFileFormat.json => Icons.data_object_rounded,
        TCsvFileFormat.tsv => Icons.table_rows_rounded,
        TCsvFileFormat.pipe => Icons.view_column_outlined,
        TCsvFileFormat.semicolon => Icons.grid_on_rounded,
        _ => Icons.table_chart_rounded,
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

  static const List<String> allCandidates = [comma, semicolon, tab, pipe];
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

  const TCsvParseResult({
    required this.format,
    this.delimiter,
    required this.headers,
    required this.rows,
    this.jsonMaps,
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
  /// Checks whether a text string contains valid JSON data (Array or Object).
  static bool isJson(String content) {
    if (content.trim().isEmpty) return false;
    String text = content;
    if (text.startsWith('\uFEFF')) {
      text = text.substring(1);
    }
    text = text.trim();
    if (!((text.startsWith('[') && text.endsWith(']')) || (text.startsWith('{') && text.endsWith('}')))) {
      return false;
    }
    try {
      final dynamic decoded = jsonDecode(text);
      return decoded is List || decoded is Map;
    } catch (_) {
      return false;
    }
  }

  /// Auto-detects the data format (JSON, TSV, Semicolon, Pipe, CSV) from content.
  static TCsvFileFormat detectFormat(String content) {
    if (isJson(content)) {
      return TCsvFileFormat.json;
    }
    final delimiter = detectDelimiter(content);
    return switch (delimiter) {
      '\t' => TCsvFileFormat.tsv,
      ';' => TCsvFileFormat.semicolon,
      '|' => TCsvFileFormat.pipe,
      _ => TCsvFileFormat.csv,
    };
  }

  /// Auto-detects the most likely delimiter from CSV / TSV / DSV content.
  static String detectDelimiter(String content) {
    if (content.isEmpty) return ',';

    String text = content;
    if (text.startsWith('\uFEFF')) {
      text = text.substring(1);
    }

    // Look across the first up to 10 non-empty lines for robust detection
    final lines = text
        .split(RegExp(r'\r\n|\r|\n'))
        .where((line) => line.trim().isNotEmpty)
        .take(10)
        .toList();

    if (lines.isEmpty) return ',';

    final candidates = TCsvDelimiter.allCandidates;
    final candidateScores = <String, int>{for (var c in candidates) c: 0};

    for (final delimiter in candidates) {
      int totalCount = 0;
      for (final line in lines) {
        int lineCount = 0;
        bool insideQuote = false;
        for (int i = 0; i < line.length; i++) {
          final char = line[i];
          if (char == '"') {
            insideQuote = !insideQuote;
          } else if (!insideQuote && char == delimiter) {
            lineCount++;
          }
        }
        totalCount += lineCount;
      }
      candidateScores[delimiter] = totalCount;
    }

    int maxScore = -1;
    String bestDelimiter = ',';

    for (final delimiter in candidates) {
      final score = candidateScores[delimiter] ?? 0;
      if (score > maxScore) {
        maxScore = score;
        bestDelimiter = delimiter;
      }
    }

    return maxScore > 0 ? bestDelimiter : ',';
  }

  /// Parses JSON string content into a list of typed maps: `List<Map<String, dynamic>>`.
  static List<Map<String, dynamic>> parseJson(String content) {
    if (content.trim().isEmpty) return [];

    String text = content;
    if (text.startsWith('\uFEFF')) {
      text = text.substring(1);
    }

    final dynamic decoded = jsonDecode(text.trim());

    if (decoded is List) {
      return decoded.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{'value': item};
      }).toList();
    }

    if (decoded is Map) {
      // Look for standard nested list properties (e.g. { "data": [...] }, { "items": [...] })
      for (final key in ['data', 'items', 'rows', 'records', 'results', 'list', 'products', 'content']) {
        if (decoded[key] is List) {
          return (decoded[key] as List).map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{'value': item};
          }).toList();
        }
      }
      // Single object wrapped in a map
      return [Map<String, dynamic>.from(decoded)];
    }

    return [];
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
      final jsonMaps = parseJson(text);
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
      );
    }

    // Delimited file
    final effectiveDelimiter = delimiter ?? detectDelimiter(text);
    final format = switch (effectiveDelimiter) {
      '\t' => TCsvFileFormat.tsv,
      ';' => TCsvFileFormat.semicolon,
      '|' => TCsvFileFormat.pipe,
      _ => TCsvFileFormat.csv,
    };

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

  /// Parses standard delimited text (CSV, TSV, Semicolon, Pipe) into row cells.
  static List<List<String>> parseDelimited(String content, {String? delimiter}) {
    if (content.isEmpty) return [];

    // Strip BOM if present
    String text = content;
    if (text.startsWith('\uFEFF')) {
      text = text.substring(1);
    }

    final effectiveDelimiter = delimiter ?? detectDelimiter(text);
    final delimiterCode = effectiveDelimiter.codeUnitAt(0);

    final rows = <List<String>>[];
    final currentRow = <String>[];
    final currentCell = StringBuffer();

    bool insideQuote = false;
    int i = 0;
    final length = text.length;

    while (i < length) {
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

    return rows;
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

    final resolvedHeaders = headers ??
        columns?.map((c) => c.header).toList() ??
        maps.first.keys.toList();

    final keys = columns?.map((c) => c.key).toList() ??
        headers ??
        maps.first.keys.toList();

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
  static String toTsv(List<String> headers, List<List<dynamic>> rows) =>
      toCsv(headers, rows, delimiter: '\t');

  /// Shortcut helper to export to TSV from maps.
  static String toTsvFromMaps(List<Map<String, dynamic>> maps, {List<TCsvColumn>? columns, List<String>? headers}) =>
      toCsvFromMaps(maps, columns: columns, headers: headers, delimiter: '\t');

  /// Shortcut helper to export to Semicolon-Separated Values (`;`).
  static String toSemicolon(List<String> headers, List<List<dynamic>> rows) =>
      toCsv(headers, rows, delimiter: ';');

  /// Shortcut helper to export to Semicolon-Separated Values from maps.
  static String toSemicolonFromMaps(List<Map<String, dynamic>> maps, {List<TCsvColumn>? columns, List<String>? headers}) =>
      toCsvFromMaps(maps, columns: columns, headers: headers, delimiter: ';');

  /// Shortcut helper to export to Pipe-Separated Values (`|`).
  static String toPipe(List<String> headers, List<List<dynamic>> rows) =>
      toCsv(headers, rows, delimiter: '|');

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
    String delimiter = ',',
    TCsvFileFormat format = TCsvFileFormat.csv,
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
            };
          }
        }
      }
      return toJson(includeSampleRow ? [sampleMap] : [], pretty: true);
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
        };
      }).toList();
      sampleRows.add(sampleRow);
    }

    final effectiveDelimiter = format.delimiter ?? delimiter;
    return toCsv(headers, sampleRows, delimiter: effectiveDelimiter);
  }
}
