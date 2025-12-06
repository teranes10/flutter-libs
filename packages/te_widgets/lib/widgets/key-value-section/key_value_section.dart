import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A responsive key-value display section.
///
/// `TKeyValueSection` provides adaptive layout for key-value pairs with:
/// - Grid layout on wide screens
/// - Key-value layout on narrow screens
/// - Custom breakpoint control
/// - Widget support for values
///
/// ## Basic Usage
///
/// ```dart
/// TKeyValueSection(
///   values: [
///     TKeyValue(key: 'Name', value: 'John Doe'),
///     TKeyValue(key: 'Email', value: 'john@example.com'),
///     TKeyValue(key: 'Phone', value: '+1234567890'),
///   ],
/// )
/// ```
///
/// ## With Custom Widgets
///
/// ```dart
/// TKeyValueSection(
///   values: [
///     TKeyValue(key: 'Status', widget: TChip(text: 'Active')),
///     TKeyValue(key: 'Actions', widget: Row(children: [...])),
///   ],
/// )
/// ```
///
/// See also:
/// - [TKeyValue] for key-value pairs
/// - [TKeyValueTheme] for styling
class TKeyValueSection extends StatelessWidget {
  /// The list of key-value pairs to display.
  final List<TKeyValue> values;

  /// Theme configuration for the section.
  final TKeyValueTheme theme;

  /// Creates a key-value section.
  const TKeyValueSection({
    super.key,
    required this.values,
    this.theme = const TKeyValueTheme(),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (theme.forceKeyValue) {
      return _buildKeyValueLayout(colors);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        if (availableWidth > theme.keyValueBreakPoint) {
          return _buildGridLayoutWidget(colors, availableWidth);
        } else {
          return _buildKeyValueLayout(colors);
        }
      },
    );
  }

  Widget _buildKeyValueLayout(ColorScheme colors) {
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
                  Expanded(flex: 2, child: Text(keyValue.key, style: theme.getKeyStyle(colors))),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: _buildCellContent(colors, keyValue))),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildGridLayoutWidget(ColorScheme colors, double availableWidth) {
    final gridData = _createRowData(availableWidth);

    return Column(
      children: gridData.map((rowData) {
        return Padding(
          padding: EdgeInsets.only(bottom: theme.gridSpacing),
          child: Table(
            columnWidths: _createColumnWidths(rowData.columnWidths),
            children: [
              TableRow(
                children: rowData.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final header = entry.value;
                  final isFirst = index == 0;

                  return _buildGridCell(colors, header, isFirst);
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridCell(ColorScheme colors, TKeyValue keyValue, bool isFirstInRow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(border: isFirstInRow ? null : Border(left: BorderSide(color: colors.outline.withAlpha(100), width: 1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(keyValue.key, style: theme.getLabelStyle(colors)),
          const SizedBox(height: 4),
          _buildCellContent(colors, keyValue),
        ],
      ),
    );
  }

  Widget _buildCellContent(ColorScheme colors, TKeyValue keyValue) {
    if (keyValue.widget != null) {
      return keyValue.widget!;
    }

    return Text(keyValue.value ?? '', style: theme.getValueStyle(colors));
  }

  List<_RowData> _createRowData(double availableWidth) {
    final List<_RowData> rows = [];
    List<TKeyValue> currentRowValues = [];
    List<double> currentRowWidths = [];
    double currentRowTotalWidth = 0;

    for (final keyValue in values) {
      final columnWidth = keyValue.estimateColumnWidth(availableWidth, theme);
      final spacingNeeded = currentRowValues.isEmpty ? 0 : theme.gridSpacing;

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
