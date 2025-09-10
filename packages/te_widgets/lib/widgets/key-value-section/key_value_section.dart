import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TKeyValueSection extends StatelessWidget {
  final List<TKeyValue> values;
  final TKeyValueStyle style;

  const TKeyValueSection({
    super.key,
    required this.values,
    this.style = const TKeyValueStyle(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (style.forceKeyValue) {
      return _buildKeyValueLayout(theme);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        if (availableWidth > style.keyValueBreakPoint) {
          return _buildGridLayoutWidget(theme, availableWidth);
        } else {
          return _buildKeyValueLayout(theme);
        }
      },
    );
  }

  Widget _buildKeyValueLayout(ColorScheme theme) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: values.asMap().entries.map((entry) {
            final index = entry.key;
            final keyValue = entry.value;
            final isLast = index == values.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: Text(keyValue.key, style: style.getKeyStyle(theme))),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: _buildCellContent(theme, keyValue))),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildGridLayoutWidget(ColorScheme theme, double availableWidth) {
    final gridData = _createRowData(availableWidth);

    return Column(
      children: gridData.map((rowData) {
        return Padding(
          padding: EdgeInsets.only(bottom: style.gridSpacing),
          child: Table(
            columnWidths: _createColumnWidths(rowData.columnWidths),
            children: [
              TableRow(
                children: rowData.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final header = entry.value;
                  final isFirst = index == 0;

                  return _buildGridCell(theme, header, isFirst);
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridCell(ColorScheme theme, TKeyValue keyValue, bool isFirstInRow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(border: isFirstInRow ? null : Border(left: BorderSide(color: theme.outline.withAlpha(100), width: 1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(keyValue.key, style: style.getLabelStyle(theme)),
          const SizedBox(height: 4),
          _buildCellContent(theme, keyValue),
        ],
      ),
    );
  }

  Widget _buildCellContent(ColorScheme theme, TKeyValue keyValue) {
    if (keyValue.widget != null) {
      return keyValue.widget!;
    }

    return Text(keyValue.value ?? '', style: style.getValueStyle(theme));
  }

  List<_RowData> _createRowData(double availableWidth) {
    final List<_RowData> rows = [];
    List<TKeyValue> currentRowValues = [];
    List<double> currentRowWidths = [];
    double currentRowTotalWidth = 0;

    for (final keyValue in values) {
      final columnWidth = _calculateColumnWidth(keyValue, availableWidth);
      final spacingNeeded = currentRowValues.isEmpty ? 0 : style.gridSpacing;

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

  double _calculateColumnWidth(TKeyValue keyValue, double availableWidth) {
    if (keyValue.width != null) {
      return keyValue.width!;
    }

    const double charWidth = 8.0;
    const double basePadding = 16.0;

    final headerLength = keyValue.key.length;

    if (keyValue.widget != null) {
      final finalWidth = (headerLength * charWidth) + basePadding;
      return math.max(style.minGridColWidth, math.min(finalWidth, availableWidth * 0.6));
    }

    final valueLength = keyValue.value?.length.toDouble() ?? 0;
    final maxLength = math.max(headerLength.toDouble(), valueLength);

    double scaledWidth;
    if (maxLength <= 32) {
      scaledWidth = maxLength * charWidth;
    } else if (maxLength <= 50) {
      final ratio = (maxLength - 32) / 18;
      scaledWidth = (32 * charWidth) + (ratio * (32 * charWidth * 0.2));
    } else if (maxLength <= 60) {
      final ratio = (maxLength - 50) / 10;
      scaledWidth = (32 * charWidth * 1.2) + (ratio * (42 * charWidth - 32 * charWidth * 1.2));
    } else {
      scaledWidth = math.min(42 * charWidth, availableWidth * 0.4);
    }

    final finalWidth = scaledWidth + basePadding;
    return math.max(style.minGridColWidth, math.min(finalWidth, availableWidth * 0.6));
  }

  Map<int, TableColumnWidth> _createColumnWidths(List<double> widths) {
    final Map<int, TableColumnWidth> columnWidths = {};
    final totalWidth = widths.fold<double>(0, (sum, width) => sum + width);

    for (int i = 0; i < widths.length; i++) {
      final fraction = widths[i] / totalWidth;
      columnWidths[i] = FractionColumnWidth(fraction);
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
