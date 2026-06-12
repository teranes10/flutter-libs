import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/widgets.dart' as pw;
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
  static Future<pw.Table> from<T, K>(
    BuildContext context,
    List<TTableHeader<T, K>> headers,
    List<T> items, {
    TPdfTableDecoration decoration = const TPdfTableDecoration(),
  }) async {
    final colors = context.colors;
    final effectiveHeaders = headers.where((header) => header.map != null || header.builder != null).toList();
    final imageCache = await TPdfWidgetHelper.preCacheImages(context, effectiveHeaders, items);
    final tHeaders = effectiveHeaders.map((header) => header.text).toList();

    final tData = items.asMap().entries.map((itemEntry) {
      final index = itemEntry.key;
      final item = itemEntry.value;

      return effectiveHeaders.map((header) {
        if (header.builder != null) {
          final listItem = TListItem<T, K>(key: index as dynamic, data: item);
          final widget = header.builder!(context, listItem, index);
          final pdfWidget = TPdfWidgetHelper.convert(widget, colors, imageCache: imageCache);

          // If conversion was successful, return the PDF widget
          if (pdfWidget is! pw.SizedBox) {
            return pdfWidget;
          }
        }
        return header.getValue(item);
      }).toList();
    }).toList();

    return pw.TableHelper.fromTextArray(
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
