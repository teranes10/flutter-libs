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

  /// Whether expansion happens on the side.
  final bool expandSide;

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
    this.expandSide = false,

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
    final themeBgColor = wTheme.backgroundColor.resolve(states);
    final resolvedBgColor = backgroundColor ?? (themeBgColor == colors.surface ? context.getBackgroundColor(colors.surface) : themeBgColor);

    final controller = TTableScope.maybeOf(context)?.controller;
    final isDense = TTableScope.maybeOf(context)?.dense ?? false;
    final indentWidth = item.level * 16.0;

    final cardMargin = wTheme.margin.copyWith(
      left: wTheme.margin.left + indentWidth,
    );

    final isTreeMode = (controller?.isHierarchical ?? false) || item.level > 0 || item.hasChildren;

    final mappedKeyValues = TKeyValue.mapHeaders(context, headers, item, index);
    if (isTreeMode && mappedKeyValues.isNotEmpty) {
      final firstKv = mappedKeyValues.first;
      final originalWidget = firstKv.widget ?? SelectableText(firstKv.value ?? '', style: wTheme.valueStyle);
      mappedKeyValues[0] = TKeyValue(
        firstKv.key,
        widget: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (item.hasChildren) ...[
              Builder(builder: (ctx) {
                final isTreeExpanded = controller?.isExpanded(item.key) ?? false;
                return TIcon(
                  icon: isTreeExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  size: isDense ? 18 : 20,
                  padding: const EdgeInsets.all(1),
                  color: colors.onSurfaceVariant,
                  background: colors.surfaceContainerLow,
                  active: isTreeExpanded,
                  onTap: () {
                    controller?.toggleExpansion(item.key);
                  },
                );
              }),
              const SizedBox(width: 4),
            ],
            Flexible(child: originalWidget),
          ],
        ),
      );
    }

    return TCard(
      margin: cardMargin,
      elevation: wTheme.elevation,
      borderRadius: wTheme.borderRadius,
      backgroundColor: resolvedBgColor,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: wTheme.padding,
            child: TKeyValueSection(values: [
              if (selectable)
                TKeyValue(
                  "",
                  widget: TCheckbox(
                    value: isSelected,
                    onValueChanged: (value) => onSelectionChanged?.call(),
                  ),
                  alignment: Alignment.topLeft,
                ),
              ...mappedKeyValues,
              if (expandable)
                TKeyValue(
                  "",
                  widget: Builder(builder: (context) {
                    return TIcon(
                      icon: expandSide ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down,
                      size: isDense ? 18 : 20,
                      color: colors.onSurfaceVariant,
                      background: colors.surfaceContainerLow,
                      padding: isDense ? const EdgeInsets.all(2) : const EdgeInsets.all(3),
                      borderRadius: BorderRadius.circular(20),
                      turns: expandSide ? (0, -0.5) : (0, 0.5),
                      active: isExpanded,
                      onTap: onExpansionChanged,
                    );
                  }),
                  alignment: Alignment.bottomRight,
                )
            ]),
          ),
          if (isExpanded && !expandSide && expandedContent != null) Padding(padding: wTheme.padding, child: expandedContent!),
        ],
      ),
    );
  }
}
