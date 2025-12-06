import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/widgets.dart';
import 'package:te_widgets/te_widgets.dart';

/// Helper class for creating PDF tables from data headers.
///
/// `TTableHelper` simplifies the creation of PDF tables using the `pdf` package
/// by bridging `TTableHeader` definitions with the PDF `TableHelper`.
///
/// ## Usage Example
///
/// ```dart
/// final pdfTable = TTableHelper.from(
///   context,
///   [
///     TTableHeader(text: 'Name', map: (item) => item.name),
///     TTableHeader(text: 'Age', map: (item) => item.age),
///   ],
///   users,
/// );
/// ```
class TTableHelper {
  /// Creates a PDF table widget from headers and items.
  static from<T, K>(
    BuildContext context,
    List<TTableHeader<T, K>> headers,
    List<T> items, {
    TPdfTableDecoration decoration = const TPdfTableDecoration(),
  }) {
    final colors = context.colors;
    final effectiveHeaders = headers.where((header) => header.map != null);
    final tHeaders = effectiveHeaders.map((header) => header.text).toList();
    final tData = items.map((item) => effectiveHeaders.map((header) => header.getValue(item)).toList()).toList();

    return TableHelper.fromTextArray(
      headers: tHeaders,
      data: tData,
      border: decoration.getBorder(colors),
      headerStyle: decoration.getHeaderStyle(colors),
      cellStyle: decoration.getCellStyle(colors),
      headerAlignment: decoration.headerAlignment,
      cellAlignment: decoration.cellAlignment,
      headerPadding: decoration.headerPadding,
      cellPadding: decoration.cellPadding,
    );
  }
}
