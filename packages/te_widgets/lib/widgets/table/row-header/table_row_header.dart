import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableRowHeader<T, K> extends StatelessWidget {
  final TTableRowHeaderTheme theme;
  final List<TTableHeader<T, K>> headers;
  final TListController<T, K> controller;
  final Map<int, TableColumnWidth>? columnWidths;

  const TTableRowHeader({
    super.key,
    required this.controller,
    required this.headers,
    this.columnWidths,
    this.theme = const TTableRowHeaderTheme(),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: controller.reorderable ? theme.padding.copyWith(left: theme.padding.left + 25) : theme.padding,
      decoration: theme.decoration,
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
            ...headers.map((header) => buildHeaderCell(colors, header)),
          ])
        ],
      ),
    );
  }

  Widget buildHeaderCell(ColorScheme colors, TTableHeader<T, K> header) {
    return Container(
      constraints: BoxConstraints(minWidth: header.minWidth ?? 50, maxWidth: header.maxWidth ?? double.infinity),
      child: Align(
        alignment: header.alignment ?? Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(header.text, style: theme.getHeaderStyle(colors), textAlign: header.getTextAlign()),
        ),
      ),
    );
  }
}
