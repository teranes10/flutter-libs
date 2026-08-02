import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A standard table row rendered as a card.
///
/// `TTableRowCard` renders a single row in a [TTable] using a [Table] layout.
/// It integrates with:
/// - [TTableHeader] for cell rendering
/// - [TListController] for selection/expansion state
class TTableRowCard<T, K> extends StatelessWidget {
  /// The index of the item.
  final int index;

  /// The list item data.
  final TListItem<T, K> item;

  /// The table headers definitions.
  final List<TTableHeader<T, K>> headers;

  /// Theme for the row card.
  final TTableRowCardTheme? theme;

  /// Optional fixed width.
  final double? width;

  /// Column width configuration for the underlying [Table].
  final Map<int, TableColumnWidth>? columnWidths;

  //expandable
  /// Whether the row is expandable.
  final bool expandable;

  /// Whether the row is currently expanded.
  final bool isExpanded;

  /// Callback when expansion toggles.
  final VoidCallback? onExpansionChanged;

  /// Content to show when expanded.
  final Widget? expandedContent;

  /// The expansion mode for details (bottom, side, dialog, page).
  final TTableExpansionMode expansionMode;

  /// Whether expansion happens on the side.
  final bool expandSide;

  //selectable
  /// Whether the row is selectable.
  final bool selectable;

  /// Whether the row is selected.
  final bool isSelected;

  /// Callback when selection toggles.
  final VoidCallback? onSelectionChanged;

  /// Callback when row card tapped.
  final VoidCallback? onTap;

  /// Custom background color for the row.
  final Color? backgroundColor;

  /// Creates a table row card.
  const TTableRowCard({
    super.key,
    required this.index,
    required this.item,
    required this.headers,
    this.columnWidths,
    this.theme,
    this.width,

    //expandable
    this.expandable = false,
    this.isExpanded = false,
    this.onExpansionChanged,
    this.expandedContent,
    this.expansionMode = TTableExpansionMode.bottom,
    this.expandSide = false,

    //selectable
    this.selectable = false,
    this.isSelected = false,
    this.onSelectionChanged,
    this.onTap,
    this.backgroundColor,
  });

  IconData _getDetailExpandIcon(TTableExpansionMode mode, bool isExpanded) {
    switch (mode) {
      case TTableExpansionMode.side:
        return isExpanded ? Icons.chevron_left : Icons.chevron_right;
      case TTableExpansionMode.dialog:
        return isExpanded ? Icons.close : Icons.open_in_new_outlined;
      case TTableExpansionMode.page:
        return isExpanded ? Icons.close : Icons.open_in_new_outlined;
      case TTableExpansionMode.bottom:
        return isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final wTheme = theme ?? context.theme.tableTheme.rowCardTheme;
    final states = <WidgetState>{if (isSelected) WidgetState.selected};
    final themeBgColor = wTheme.backgroundColor.resolve(states);
    final resolvedBgColor = backgroundColor ?? (themeBgColor == colors.surface ? context.getBackgroundColor(colors.surface) : themeBgColor);

    final controller = TTableScope.maybeOf(context)?.controller;
    final isDense = TTableScope.maybeOf(context)?.dense ?? false;
    final indentWidth = item.level * 16.0;

    return TCard(
      margin: wTheme.margin,
      elevation: wTheme.elevation,
      borderRadius: wTheme.borderRadius,
      borderColor: Colors.transparent,
      backgroundColor: resolvedBgColor,
      padding: wTheme.padding,
      onTap: onTap,
      hoverColor: colors.primaryContainer.withAlpha(120),
      splashColor: colors.primary.withAlpha(50),
      highlightColor: colors.primaryContainer.withAlpha(150),
      child: Column(
        children: [
          Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                if (expandable)
                  Builder(builder: (context) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: TIcon(
                        icon: _getDetailExpandIcon(expansionMode, isExpanded),
                        size: isDense ? 18 : 20,
                        padding: isDense ? const EdgeInsets.all(3) : const EdgeInsets.all(6),
                        color: colors.onSurfaceVariant,
                        background: colors.surfaceContainerLow,
                        active: isExpanded,
                        onTap: onExpansionChanged,
                      ),
                    );
                  }),
                if (selectable)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TCheckbox(value: isSelected, onValueChanged: (v) => onSelectionChanged?.call()),
                  ),
                ...headers.asMap().entries.map((entry) {
                  final headerIndex = entry.key;
                  final header = entry.value;

                  Widget cellWidget = header.builder != null
                      ? Builder(builder: (context) => header.builder!(context, item, index))
                      : SelectableText(header.getValue(item.data), style: wTheme.contentTextStyle);

                  if (headerIndex == 0) {
                    final iconSlotWidth = isDense ? 20.0 : 24.0;
                    final isTreeMode = (controller?.isHierarchical ?? false) || item.level > 0 || item.hasChildren;

                    cellWidget = Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (indentWidth > 0) SizedBox(width: indentWidth),
                        if (item.hasChildren) ...[
                          Builder(builder: (ctx) {
                            final isTreeExpanded = controller?.isExpanded(item.key) ?? false;
                            return Padding(
                              padding: EdgeInsetsGeometry.only(top: 1.5),
                              child: TIcon(
                                icon: isTreeExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                                size: isDense ? 18 : 20,
                                padding: const EdgeInsets.all(0),
                                color: colors.onSurfaceVariant,
                                background: colors.surfaceContainerLow,
                                active: isTreeExpanded,
                                onTap: () {
                                  controller?.toggleExpansion(item.key);
                                },
                              ),
                            );
                          }),
                          const SizedBox(width: 6),
                        ] else if (isTreeMode) ...[
                          SizedBox(width: iconSlotWidth),
                        ],
                        Flexible(child: cellWidget),
                      ],
                    );
                  }

                  return Container(
                    constraints: BoxConstraints(minWidth: header.minWidth ?? 50, maxWidth: header.maxWidth ?? double.infinity),
                    child: Align(
                      alignment: header.alignment ?? Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: cellWidget,
                      ),
                    ),
                  );
                }),
              ])
            ],
          ),
          if (expandable)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded && !expandSide
                  ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: wTheme.padding.top),
                      child: expandedContent,
                    )
                  : const SizedBox.shrink(),
            )
        ],
      ),
    );
  }
}
