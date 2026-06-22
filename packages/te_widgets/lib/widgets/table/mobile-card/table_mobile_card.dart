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
  final TTableMobileCardTheme? theme;

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

  /// Custom background color for the card.
  final Color? backgroundColor;

  /// Creates a mobile table card.
  const TTableMobileCard({
    super.key,
    required this.index,
    required this.item,
    required this.headers,
    this.theme,
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
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final wTheme = theme ?? context.theme.tableTheme.mobileCardTheme;

    final states = <WidgetState>{if (isSelected) WidgetState.selected};

    return TCard(
      margin: wTheme.margin,
      elevation: wTheme.elevation,
      borderRadius: wTheme.borderRadius,
      backgroundColor: backgroundColor ?? wTheme.backgroundColor.resolve(states),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: wTheme.padding,
            child: TKeyValueSection(values: [
              TKeyValue(
                "",
                widget: TCheckbox(
                  value: isSelected,
                  onValueChanged: (value) => onSelectionChanged?.call(),
                ),
                alignment: Alignment.topLeft,
              ),
              ...TKeyValue.mapHeaders(context, headers, item, index),
              if (expandable)
                TKeyValue(
                  "",
                  widget: TIcon(
                    icon: Icons.keyboard_arrow_down,
                    size: 20,
                    color: colors.onSurfaceVariant,
                    background: colors.surfaceContainerLow,
                    padding: EdgeInsets.all(3),
                    borderRadius: BorderRadius.circular(20),
                    turns: (0, 0.5),
                    active: isExpanded,
                    onTap: onExpansionChanged,
                  ),
                  alignment: Alignment.bottomRight,
                )
            ]),
          ),
          if (isExpanded && expandedContent != null) Padding(padding: wTheme.padding, child: expandedContent!),
        ],
      ),
    );
  }
}
