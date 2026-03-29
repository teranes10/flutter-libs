import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// The header row of a [TTable].
///
/// `TTableRowHeader` renders the column titles and optional "Select All" checkbox.
/// It automatically adjusts to match column widths of [TTableRowCard].
class TTableRowHeader<T, K> extends StatelessWidget {
  /// Theme text and decoration.
  final TTableRowHeaderTheme? theme;

  /// Column definitions.
  final List<TTableHeader<T, K>> headers;

  /// The list controller (for select all state).
  final TListController<T, K> controller;

  /// Width configuration for columns.
  final Map<int, TableColumnWidth>? columnWidths;

  /// Creates a table header row.
  const TTableRowHeader({
    super.key,
    required this.controller,
    required this.headers,
    this.columnWidths,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final wTheme = theme ?? context.theme.tableTheme.headerTheme;

    return Container(
      width: double.infinity,
      padding: controller.reorderable ? wTheme.padding.copyWith(left: wTheme.padding.left + 25) : wTheme.padding,
      decoration: wTheme.decoration,
      child: Table(
        columnWidths: columnWidths,
        children: [
          TableRow(children: [
            if (controller.expandable) SizedBox(width: 20),
            if (controller.selectable)
              Align(
                alignment: Alignment.centerLeft,
                child: TCheckbox(
                  tristate: true,
                  value: controller.selectionTristate,
                  onValueChanged: (value) => controller.toggleSelectAll(),
                ),
              ),
            ...headers.map((header) => buildHeaderCell(wTheme, header)),
          ])
        ],
      ),
    );
  }

  /// Builds a single header cell.
  Widget buildHeaderCell(TTableRowHeaderTheme wTheme, TTableHeader<T, K> header) {
    return Container(
      constraints: BoxConstraints(minWidth: header.minWidth ?? 50, maxWidth: header.maxWidth ?? double.infinity),
      child: Align(
        alignment: header.alignment ?? Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(header.text, style: wTheme.textStyle, textAlign: header.getTextAlign()),
        ),
      ),
    );
  }
}
