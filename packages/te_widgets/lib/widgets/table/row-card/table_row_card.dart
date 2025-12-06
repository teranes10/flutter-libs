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
  final TTableRowCardTheme theme;

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

  //selectable
  /// Whether the row is selectable.
  final bool selectable;

  /// Whether the row is selected.
  final bool isSelected;

  /// Callback when selection toggles.
  final VoidCallback? onSelectionChanged;

  /// Creates a table row card.
  const TTableRowCard({
    super.key,
    required this.index,
    required this.item,
    required this.headers,
    this.columnWidths,
    this.theme = const TTableRowCardTheme(),
    this.width,

    //expandable
    this.expandable = false,
    this.isExpanded = false,
    this.onExpansionChanged,
    this.expandedContent,

    //selectable
    this.selectable = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TCard(
      margin: theme.margin,
      elevation: theme.elevation,
      borderRadius: theme.borderRadius,
      backgroundColor: theme.getBackgroundColor(colors, isSelected),
      padding: theme.padding,
      boxShadow: [BoxShadow(color: colors.shadow, offset: const Offset(0, 1), blurRadius: 0, spreadRadius: 0)],
      child: Column(
        children: [
          Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                if (expandable)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TIcon(
                      icon: Icons.keyboard_arrow_down,
                      size: 20,
                      color: colors.onSurfaceVariant,
                      turns: (0, 0.5),
                      active: isExpanded,
                      onTap: onExpansionChanged,
                    ),
                  ),
                if (selectable)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TCheckbox(value: isSelected, onValueChanged: (v) => onSelectionChanged?.call()),
                  ),
                ...headers.map((header) {
                  return Container(
                    constraints: BoxConstraints(minWidth: header.minWidth ?? 50, maxWidth: header.maxWidth ?? double.infinity),
                    child: Align(
                      alignment: header.alignment ?? Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: header.builder != null
                            ? Builder(builder: (context) => header.builder!(context, item, index))
                            : Text(header.getValue(item.data), style: theme.getContentTextStyle(colors)),
                      ),
                    ),
                  );
                })
              ])
            ],
          ),
          if (expandable)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: theme.padding.top),
                      child: expandedContent,
                    )
                  : const SizedBox.shrink(),
            )
        ],
      ),
    );
  }
}
