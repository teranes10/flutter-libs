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
    final wTheme = theme ?? TTableScope.maybeOf(context)?.theme?.headerTheme ?? context.theme.tableTheme.headerTheme;

    final order = controller.headerOrder;
    final visibility = controller.headerVisibility;

    final List<TTableHeader<T, K>> effectiveHeaders;
    if (order.isEmpty) {
      effectiveHeaders = headers.where((h) => visibility[h.text] ?? true).toList();
    } else {
      final orderedVisibleHeaders = <TTableHeader<T, K>>[];
      for (final text in order) {
        if (visibility[text] ?? true) {
          final index = headers.indexWhere((h) => h.text == text);
          if (index != -1) {
            orderedVisibleHeaders.add(headers[index]);
          }
        }
      }
      // Also include any headers that are not in headerOrder (e.g. actions column)
      for (final h in headers) {
        if (!order.contains(h.text)) {
          if (visibility[h.text] ?? true) {
            orderedVisibleHeaders.add(h);
          }
        }
      }
      effectiveHeaders = orderedVisibleHeaders;
    }

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
            ...effectiveHeaders.asMap().entries.map((entry) {
              final headerIndex = entry.key;
              final header = entry.value;
              int maxLevel = 0;
              if (controller.isHierarchical) {
                for (final item in controller.value.displayItems) {
                  if (item.level > maxLevel) maxLevel = item.level;
                }
                if (maxLevel == 0 && controller.value.displayItems.any((i) => i.hasChildren)) {
                  maxLevel = 1;
                }
              }
              final treeExtraWidth = (headerIndex == 0 && (controller.isHierarchical || maxLevel > 0))
                  ? (maxLevel * 16.0 + 36.0)
                  : 0.0;
              return buildHeaderCell(wTheme, header, extraWidth: treeExtraWidth);
            }),
          ])
        ],
      ),
    );
  }

  /// Builds a single header cell.
  Widget buildHeaderCell(TTableRowHeaderTheme wTheme, TTableHeader<T, K> header, {double extraWidth = 0.0}) {
    final minW = (header.minWidth ?? 50) + extraWidth;
    final maxW = (header.maxWidth != null && header.maxWidth != double.infinity)
        ? header.maxWidth! + extraWidth
        : double.infinity;

    return Container(
      constraints: BoxConstraints(minWidth: minW, maxWidth: maxW),
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
