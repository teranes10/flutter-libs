import 'dart:typed_data' show Uint8List;
import 'package:flutter/material.dart' show BuildContext, ColorScheme;
import 'package:pdf/widgets.dart' as pw;
import 'package:te_widgets/te_widgets.dart';

/// Helper for creating grid-based layouts in PDF documents.
///
/// `TPdfGridTableHelper` mimics the behavior of [TKeyValueSection]'s grid layout,
/// allowing key-value pairs to be arranged in a responsive-like grid within a PDF.
class TPdfGridTableHelper {
  /// Creates an adaptive layout: uses a standard table if it fits, otherwise uses a grid.
  static Future<pw.Widget> adaptive<T, K>(
    BuildContext context,
    List<TTableHeader<T, K>> headers,
    List<T> items, {
    TPdfTableDecoration decoration = const TPdfTableDecoration(),
    double availableWidth = 515,
    TKeyValueTheme? theme,
    Map<String, Uint8List>? imageCache,
  }) async {
    final colors = context.colors;
    final wTheme = theme ?? TKeyValueTheme.defaultTheme(colors);

    // Only consider headers with map or builder (same as TTableHelper.from)
    final effectiveHeaders = headers.where((h) => h.map != null || h.builder != null).toList();

    double totalEstimatedWidth = 0;
    for (final header in effectiveHeaders) {
      final kv = TKeyValue(header.text, width: header.minWidth);
      totalEstimatedWidth += 150; //kv.estimateColumnWidth(availableWidth, wTheme);
    }

    // Heuristic: if it fits horizontally and has a reasonable number of columns, use table
    if (totalEstimatedWidth <= availableWidth && effectiveHeaders.length <= 6) {
      return TTableHelper.from<T, K>(context, headers, items, decoration: decoration);
    } else {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((item) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              fromHeaders<T, K>(context, effectiveHeaders, item,
                  decoration: decoration, availableWidth: availableWidth, theme: wTheme, imageCache: imageCache),
              pw.SizedBox(height: 15),
            ],
          );
        }).toList(),
      );
    }
  }

  /// Creates a grid layout from headers and a single item.
  static pw.Widget fromHeaders<T, K>(
    BuildContext context,
    List<TTableHeader<T, K>> headers,
    T item, {
    TPdfTableDecoration decoration = const TPdfTableDecoration(),
    double availableWidth = 515,
    TKeyValueTheme? theme,
    Map<String, Uint8List>? imageCache,
  }) {
    final values = TKeyValue.mapHeaders<T, K>(
      context,
      headers,
      TListItem<T, K>(key: 0 as dynamic, data: item),
      0,
    );
    return from(context, values, decoration: decoration, availableWidth: availableWidth, theme: theme, imageCache: imageCache);
  }

  /// Creates a grid layout from a list of [TKeyValue] items.
  static pw.Widget from(
    BuildContext context,
    List<TKeyValue> values, {
    TPdfTableDecoration decoration = const TPdfTableDecoration(),
    double availableWidth = 515,
    TKeyValueTheme? theme,
    Map<String, Uint8List>? imageCache,
    double gridSpacing = 0,
  }) {
    final colors = context.colors;
    final wTheme = theme ?? TKeyValueTheme.defaultTheme(colors);

    final gridData = _createRowData(values, wTheme, availableWidth);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: gridData.map((rowData) {
        return pw.Padding(
          padding: pw.EdgeInsets.only(bottom: gridSpacing),
          child: pw.Table(
            columnWidths: _createColumnWidths(rowData.columnWidths),
            children: [
              pw.TableRow(
                children: rowData.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final keyValue = entry.value;
                  final isFirst = index == 0;

                  return _buildGridCell(colors, wTheme, decoration, keyValue, isFirst, imageCache: imageCache);
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildGridCell(
    ColorScheme colors,
    TKeyValueTheme wTheme,
    TPdfTableDecoration decoration,
    TKeyValue keyValue,
    bool isFirstInRow, {
    Map<String, Uint8List>? imageCache,
    bool showLeftBorder = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        border: !showLeftBorder || isFirstInRow
            ? null
            : pw.Border(
                left: pw.BorderSide(
                  color: colors.outline.toPdfColor(),
                  width: 0.2,
                ),
              ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            keyValue.key,
            style: decoration.getHeaderStyle(colors),
          ),
          pw.SizedBox(height: 4),
          if (keyValue.widget != null) ...[
            TPdfWidgetHelper.convert(keyValue.widget!, colors, imageCache: imageCache),
          ] else ...[
            pw.Text(
              keyValue.value ?? '',
              style: decoration.getCellStyle(colors),
            ),
          ],
        ],
      ),
    );
  }

  static List<_RowData> _createRowData(List<TKeyValue> values, TKeyValueTheme wTheme, double availableWidth, {double gridSpacing = 0}) {
    final List<_RowData> rows = [];
    List<TKeyValue> currentRowValues = [];
    List<double> currentRowWidths = [];
    double currentRowTotalWidth = 0;

    for (final keyValue in values) {
      final columnWidth = 150.0; //keyValue.estimateColumnWidth(availableWidth, wTheme);
      final spacingNeeded = currentRowValues.isEmpty ? 0 : gridSpacing;

      if (currentRowTotalWidth + spacingNeeded + columnWidth <= availableWidth) {
        currentRowValues.add(keyValue);
        currentRowWidths.add(columnWidth);
        currentRowTotalWidth += spacingNeeded + columnWidth;
      } else {
        if (currentRowValues.isNotEmpty) {
          rows.add(_RowData(
            values: List.from(currentRowValues),
            columnWidths: List.from(currentRowWidths),
          ));
          currentRowValues.clear();
          currentRowWidths.clear();
          currentRowTotalWidth = 0;
        }

        currentRowValues.add(keyValue);
        currentRowWidths.add(columnWidth);
        currentRowTotalWidth = columnWidth;
      }
    }

    if (currentRowValues.isNotEmpty) {
      rows.add(_RowData(
        values: currentRowValues,
        columnWidths: currentRowWidths,
      ));
    }

    return rows;
  }

  static Map<int, pw.TableColumnWidth> _createColumnWidths(List<double> widths) {
    final Map<int, pw.TableColumnWidth> columnWidths = {};
    final totalWidth = widths.fold<double>(0, (sum, width) => sum + width);

    for (int i = 0; i < widths.length; i++) {
      final fraction = widths[i] / totalWidth;
      columnWidths[i] = pw.FractionColumnWidth(fraction);
    }

    return columnWidths;
  }
}

class _RowData {
  final List<TKeyValue> values;
  final List<double> columnWidths;

  _RowData({
    required this.values,
    required this.columnWidths,
  });
}
