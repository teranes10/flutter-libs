import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableMobileCard<T, K> extends StatelessWidget {
  final int index;
  final TListItem<T, K> item;
  final List<TTableHeader<T, K>> headers;
  final TTableMobileCardTheme theme;
  final double? width;

  //expandable
  final bool expandable;
  final bool isExpanded;
  final VoidCallback? onExpansionChanged;
  final Widget? expandedContent;

  //selectable
  final bool selectable;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  const TTableMobileCard({
    super.key,
    required this.index,
    required this.item,
    required this.headers,
    this.theme = const TTableMobileCardTheme(),
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

    return Container(
      width: width,
      margin: theme.margin,
      child: Material(
        elevation: theme.elevation,
        borderRadius: theme.borderRadius,
        color: theme.getBackgroundColor(colors, isSelected),
        child: Container(
          decoration: BoxDecoration(borderRadius: theme.borderRadius, border: theme.getBorder(colors, isSelected)),
          child: Column(
            children: [
              Stack(
                children: [
                  if (selectable)
                    Positioned(
                        top: 5,
                        left: 5,
                        child: TCheckbox(
                          value: isSelected,
                          onValueChanged: (value) => onSelectionChanged?.call(),
                        )),
                  _buildMainContent(context),
                  if (expandable)
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: TIcon(
                        icon: Icons.keyboard_arrow_down,
                        size: 20,
                        color: colors.onSurfaceVariant,
                        turns: (0, 0.5),
                        active: isExpanded,
                        onTap: onExpansionChanged,
                      ),
                    ),
                ],
              ),
              if (isExpanded && expandedContent != null) ...[
                Padding(
                  padding: EdgeInsets.only(
                    left: theme.padding.left + (selectable ? 3 : 0),
                    right: theme.padding.right + (expandable ? 3 : 0),
                    bottom: theme.padding.bottom,
                  ),
                  child: expandedContent!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext ctx) {
    final values = TKeyValue.mapHeaders(ctx, headers, item, index);
    return Padding(
      padding: EdgeInsets.only(
        top: theme.padding.top + (selectable ? 6 : 0),
        left: (theme.padding.left) + (selectable ? 3 : 0),
        right: (theme.padding.right) + (expandable ? 3 : 0),
        bottom: (theme.padding.bottom) + (expandable ? 6 : 0),
      ),
      child: TKeyValueSection(values: values),
    );
  }
}
