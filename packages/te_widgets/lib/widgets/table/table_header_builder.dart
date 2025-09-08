part of 'table.dart';

class TTableHeaderBuilder<T> {
  TTable<T> widget;
  final TTableController<T>? controller;

  TTableHeaderBuilder({
    required this.widget,
    this.controller,
  });

  void _updateWidget(TTable<T> newWidget) {
    widget = newWidget;
  }

  Widget _build(ColorScheme theme) {
    return Container(
      width: double.infinity,
      padding: widget.decoration.style.headerPadding,
      decoration: widget.decoration.style.headerDecoration,
      child: Table(
        columnWidths: TTableLayoutCalculator._getColumnWidths(widget),
        children: [
          TableRow(
            children: _buildHeaderCells(theme, widget.decoration.style.getHeaderStyle(theme)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderCells(ColorScheme theme, TextStyle headerStyle) {
    List<Widget> cells = [];

    if (widget.expandable) {
      cells.add(Container());
    }

    if (widget.selectable && controller != null) {
      cells.add(
        ValueListenableBuilder<Set<int>>(
          valueListenable: controller!.selected,
          builder: (context, selectedSet, _) {
            final isAllSelected = selectedSet.length == widget.items.length && widget.items.isNotEmpty;
            final isPartiallySelected = selectedSet.isNotEmpty && !isAllSelected;
            final value = isAllSelected ? true : (isPartiallySelected ? null : false);

            return Align(
              alignment: Alignment.centerLeft,
              child: TCheckbox(
                tristate: true,
                value: value,
                onValueChanged: widget.items.isEmpty ? null : (value) => controller?.toggleSelectAll(),
              ),
            );
          },
        ),
      );
    }

    cells.addAll(
      widget.headers.map((header) {
        return Container(
          constraints: BoxConstraints(minWidth: header.minWidth ?? 0, maxWidth: header.maxWidth ?? double.infinity),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(header.text, style: headerStyle, textAlign: header.alignment?.toTextAlign() ?? TextAlign.left),
          ),
        );
      }),
    );

    return cells;
  }
}
