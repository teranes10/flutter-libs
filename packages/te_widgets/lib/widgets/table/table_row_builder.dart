part of 'table.dart';

class TTableRowBuilder<T> {
  TTable<T> widget;
  final TTableController<T>? controller;

  TTableRowBuilder({
    required this.widget,
    this.controller,
  });

  void _updateWidget(TTable<T> newWidget) {
    widget = newWidget;
  }

  Widget _buildTableRow(ColorScheme colors, TRowStyle rowStyle, T item, int index, bool isExpanded, bool isSelected) {
    return _buildGestureDetector(
      item,
      index,
      TCard(
        margin: rowStyle.margin,
        elevation: rowStyle.elevation,
        borderRadius: rowStyle.borderRadius,
        backgroundColor: rowStyle.getBackgroundColor(colors, isSelected),
        padding: rowStyle.padding,
        boxShadow: [
          BoxShadow(color: colors.shadow, offset: const Offset(0, 1), blurRadius: 0, spreadRadius: 0),
        ],
        child: Column(
          children: [
            Table(
              columnWidths: TTableLayoutCalculator._getColumnWidths(widget),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [TableRow(children: _buildRowCells(colors, item, index, isExpanded, isSelected))],
            ),
            if (widget.expandable)
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: rowStyle.padding.top),
                        child: widget.expandedBuilder?.call(item, index, isExpanded) ?? _buildDefaultExpandedContent(colors, item, index),
                      )
                    : const SizedBox.shrink(),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildCardRow(ColorScheme colors, T item, int index, bool isExpanded, bool isSelected) {
    return _buildGestureDetector(
      item,
      index,
      TTableCard<T>(
        item: item,
        headers: widget.headers,
        style: widget.decoration.style.cardStyle,
        width: widget.decoration.cardWidth,
        expandable: widget.expandable,
        isExpanded: isExpanded,
        onExpansionChanged: widget.expandable ? () => controller?.toggleExpansion(index) : null,
        expandedContent: widget.expandedBuilder?.call(item, index, isExpanded) ?? _buildDefaultExpandedContent(colors, item, index),
        selectable: widget.selectable,
        isSelected: isSelected,
        onSelectionChanged: widget.selectable ? () => controller?.toggleSelection(index) : null,
      ),
    );
  }

  List<Widget> _buildRowCells(ColorScheme colors, T item, int index, bool isExpanded, bool isSelected) {
    List<Widget> cells = [];

    // Expansion cell
    if (widget.expandable) {
      cells.add(
        Align(
          alignment: Alignment.centerLeft,
          child: TTableCard._buildExpandButton(colors, isExpanded, () => controller?.toggleExpansion(index)),
        ),
      );
    }

    // Selection cell
    if (widget.selectable) {
      cells.add(
        Align(
          alignment: Alignment.centerLeft,
          child: TCheckbox(
            value: isSelected,
            onValueChanged: (value) => controller?.toggleSelection(index),
          ),
        ),
      );
    }

    // Data cells
    cells.addAll(
      widget.headers.map((header) {
        Widget cellContent = _buildCellContent(colors, header, item);
        return Align(
          alignment: header.alignment ?? Alignment.centerLeft,
          child: cellContent,
        );
      }),
    );

    return cells;
  }

  Widget _buildCellContent(ColorScheme colors, TTableHeader<T> header, T item) {
    if (header.builder != null) {
      return Builder(
        builder: (context) => header.builder!(context, item),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        header.getValue(item),
        style: widget.decoration.style.getContentTextStyle(colors),
      ),
    );
  }

  Widget _buildDefaultExpandedContent(ColorScheme colors, T item, int index) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Expanded content for item $index\nProvide expandedBuilder for custom content',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGestureDetector(T item, int index, Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _handleTap(item, index),
      onDoubleTap: () => _handleDoubleTap(item, index),
      onLongPress: () => _handleLongPress(item, index),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: child,
      ),
    );
  }

  void _handleTap(T item, int index) {
    _handleRowInteraction(widget.interactionConfig.tapAction, item, index);
    widget.interactionConfig.onRowTap?.call(item, index);
  }

  void _handleDoubleTap(T item, int index) {
    _handleRowInteraction(widget.interactionConfig.doubleTapAction, item, index);
    widget.interactionConfig.onRowDoubleTap?.call(item, index);
  }

  void _handleLongPress(T item, int index) {
    _handleRowInteraction(widget.interactionConfig.longPressAction, item, index);
    widget.interactionConfig.onRowLongPress?.call(item, index);
  }

  void _handleRowInteraction(TTableInteractionType type, T item, int index) {
    switch (type) {
      case TTableInteractionType.expand:
        if (widget.expandable) {
          controller?.toggleExpansion(index);
        }
        break;
      case TTableInteractionType.select:
        if (widget.selectable) {
          controller?.toggleSelection(index);
        }
        break;
      case TTableInteractionType.none:
        break;
    }
  }
}
