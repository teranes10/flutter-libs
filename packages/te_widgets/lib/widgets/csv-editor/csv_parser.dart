import 'csv_column.dart';

/// Robust parser and generator for CSV / TSV data.
///
/// Compliant with RFC-4180, supporting:
/// - Quoted cells with commas and escaped quotes (`""`).
/// - Multiline quoted cells.
/// - Auto-detection of delimiters (`,`, `;`, `\t`, `|`).
/// - Byte Order Mark (BOM) stripping.
/// - Template generation.
class TCsvParser {
  /// Auto-detects the most likely delimiter from CSV content.
  static String detectDelimiter(String content) {
    if (content.isEmpty) return ',';

    // Look at the first line or first 1000 characters
    final firstLine = content.split(RegExp(r'\r\n|\r|\n')).firstWhere(
          (line) => line.trim().isNotEmpty,
          orElse: () => '',
        );

    if (firstLine.isEmpty) return ',';

    final candidates = [',', ';', '\t', '|'];
    int maxCount = -1;
    String bestDelimiter = ',';

    for (final delimiter in candidates) {
      int count = 0;
      bool insideQuote = false;
      for (int i = 0; i < firstLine.length; i++) {
        final char = firstLine[i];
        if (char == '"') {
          insideQuote = !insideQuote;
        } else if (!insideQuote && char == delimiter) {
          count++;
        }
      }
      if (count > maxCount) {
        maxCount = count;
        bestDelimiter = delimiter;
      }
    }

    return maxCount > 0 ? bestDelimiter : ',';
  }

  /// Parses CSV / TSV text content into a list of row cells: `List<List<String>>`.
  static List<List<String>> parse(String content, {String? delimiter}) {
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

  /// Converts headers and rows to a standard CSV formatted string.
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

  static String _escapeCell(String value, String delimiter) {
    bool needsQuotes = value.contains(delimiter) || value.contains('"') || value.contains('\n') || value.contains('\r');
    if (needsQuotes) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Generates a sample CSV template string based on a list of [TCsvColumn]s.
  static String generateTemplate(List<TCsvColumn> columns, {bool includeSampleRow = true, String delimiter = ','}) {
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

    return toCsv(headers, sampleRows, delimiter: delimiter);
  }
}
