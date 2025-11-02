import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableMobileCard<T> extends StatelessWidget {
  final T item;
  final List<TTableHeader<T>> headers;
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
                  _buildMainContent(colors),
                  if (expandable)
                    Positioned(
                      bottom: 3,
                      right: 5,
                      child: TIcon(
                        icon: Icons.keyboard_arrow_down,
                        size: 16,
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
                    left: theme.padding.left + (selectable ? 6 : 0),
                    right: theme.padding.right,
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

  Widget _buildMainContent(ColorScheme colors) {
    final values = TKeyValue.mapHeaders(headers, item);
    return Padding(
      padding: EdgeInsets.only(
        top: theme.padding.top + (selectable ? 3 : 0),
        left: (theme.padding.left) + (selectable ? 6 : 0),
        right: (theme.padding.right),
        bottom: (theme.padding.bottom),
      ),
      child: TKeyValueSection(values: values),
    );
  }
}
