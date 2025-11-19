import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableRowCard<T> extends StatelessWidget {
  final T item;
  final List<TTableHeader<T>> headers;
  final TTableRowCardTheme theme;
  final double? width;
  final Map<int, TableColumnWidth>? columnWidths;

  //expandable
  final bool expandable;
  final bool isExpanded;
  final VoidCallback? onExpansionChanged;
  final Widget? expandedContent;

  //selectable
  final bool selectable;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  const TTableRowCard({
    super.key,
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
                    constraints: BoxConstraints(minWidth: header.minWidth ?? 0, maxWidth: header.maxWidth ?? double.infinity),
                    child: Align(
                      alignment: header.alignment ?? Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: header.builder != null
                            ? Builder(builder: (context) => header.builder!(context, item))
                            : Text(header.getValue(item), style: theme.getContentTextStyle(colors)),
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
