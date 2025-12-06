import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A card representation of a table row for mobile views.
///
/// `TTableMobileCard` transforms a table row into a self-contained card
/// displaying key-value pairs. It supports:
/// - Expandable details
/// - Selection checkbox
/// - Custom styling
class TTableMobileCard<T, K> extends StatelessWidget {
  /// The index of the item.
  final int index;

  /// The list item data.
  final TListItem<T, K> item;

  /// The table headers definitions.
  final List<TTableHeader<T, K>> headers;

  /// Theme for the mobile card.
  final TTableMobileCardTheme theme;

  /// Optional fixed width.
  final double? width;

  //expandable
  /// Whether the card is expandable.
  final bool expandable;

  /// Whether the card is currently expanded.
  final bool isExpanded;

  /// Callback when expansion toggles.
  final VoidCallback? onExpansionChanged;

  /// Content to show when expanded.
  final Widget? expandedContent;

  //selectable
  /// Whether the card is selectable.
  final bool selectable;

  /// Whether the card is selected.
  final bool isSelected;

  /// Callback when selection toggles.
  final VoidCallback? onSelectionChanged;

  /// Creates a mobile table card.
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
