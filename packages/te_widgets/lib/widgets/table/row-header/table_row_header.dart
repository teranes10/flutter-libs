import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableRowHeader<T, K> extends StatelessWidget {
  final TTableRowHeaderTheme theme;
  final List<TTableHeader<T>> headers;
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
      padding: theme.padding,
      decoration: theme.decoration,
      child: Table(
        columnWidths: columnWidths,
        children: [
          TableRow(children: [
            if (controller.expandable) Container(),
            if (controller.selectable) buildCheckbox(),
            ...headers.map((header) => buildHeaderCell(colors, header)),
          ])
        ],
      ),
    );
  }

  Widget buildCheckbox() {
    return TReactiveSelector(
      listenable: controller,
      selector: (x) => x.selectionValue,
      builder: (_, tristate, oldState) {
        return Align(
          alignment: Alignment.centerLeft,
          child: TCheckbox(
            tristate: true,
            value: tristate,
            onValueChanged: (value) => controller.toggleSelectAll(),
          ),
        );
      },
    );
  }

  Widget buildHeaderCell(ColorScheme colors, TTableHeader<T> header) {
    return Container(
      constraints: BoxConstraints(minWidth: header.minWidth ?? 0, maxWidth: header.maxWidth ?? double.infinity),
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
