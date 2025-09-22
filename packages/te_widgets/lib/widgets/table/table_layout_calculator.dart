part of 'table.dart';

class TTableLayoutCalculator<T> {
  TTable<T> widget;

  TTableLayoutCalculator({required this.widget});

  void _updateWidget(TTable<T> newWidget) {
    widget = newWidget;
  }

  double _calculateTotalRequiredWidth() {
    double totalWidth = 0;

    // Add width for expand/select columns
    if (widget.expandable) totalWidth += 40;
    if (widget.selectable) totalWidth += 40;

    for (final header in widget.headers) {
      if (header.maxWidth != null && header.maxWidth != double.infinity) {
        totalWidth += header.maxWidth!;
      } else if (header.minWidth != null && header.minWidth! > 0) {
        totalWidth += header.minWidth!;
      } else {
        // For flex columns, assume a minimum reasonable width
        totalWidth += 100; // Default minimum width for flex columns
      }
    }

    // Add some padding for table margins/padding
    totalWidth += 32; // Account for horizontal padding

    return totalWidth;
  }

  bool _needsHorizontalScroll(BoxConstraints constraints) {
    final totalRequiredWidth = _calculateTotalRequiredWidth();
    return totalRequiredWidth > constraints.maxWidth;
  }

  static Map<int, TableColumnWidth> _getColumnWidths<T>(TTable<T> widget) {
    Map<int, TableColumnWidth> columnWidths = {};
    int columnIndex = 0;

    if (widget.selectable) {
      columnWidths[columnIndex] = const FixedColumnWidth(40);
      columnIndex++;
    }

    if (widget.expandable) {
      columnWidths[columnIndex] = const FixedColumnWidth(40);
      columnIndex++;
    }

    for (int i = 0; i < widget.headers.length; i++) {
      final header = widget.headers[i];

      if (header.maxWidth != null && header.maxWidth != double.infinity) {
        columnWidths[columnIndex] = FixedColumnWidth(header.maxWidth!);
      } else if (header.minWidth != null && header.minWidth! > 0) {
        columnWidths[columnIndex] = FixedColumnWidth(header.minWidth!);
      } else {
        columnWidths[columnIndex] = FlexColumnWidth(header.flex?.toDouble() ?? 1.0);
      }
      columnIndex++;
    }

    return columnWidths;
  }
}
