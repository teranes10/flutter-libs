import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A single row in a [TSummaryList].
class TSummaryItem {
  /// Leading icon.
  final IconData? icon;

  /// Optional custom leading widget (takes precedence over [icon]).
  final Widget? leading;

  /// Primary text content.
  final String text;

  /// Optional secondary/trailing text.
  final String? trailing;

  /// Optional icon color override.
  final Color? iconColor;

  /// Creates a summary item.
  const TSummaryItem({
    this.icon,
    this.leading,
    required this.text,
    this.trailing,
    this.iconColor,
  });
}

/// A vertical list of icon + text summary rows.
///
/// Designed for review screens such as package summary.
///
/// ## Basic Usage
///
/// ```dart
/// TSummaryList(
///   title: 'Package Summary',
///   titleIcon: Icons.inventory_2,
///   items: [
///     TSummaryItem(icon: Icons.category_outlined, text: 'Type: Parcel (5 kg)'),
///     TSummaryItem(icon: Icons.notes_outlined, text: 'Description: Electronics'),
///     TSummaryItem(icon: Icons.numbers, text: 'Quantity: 1'),
///   ],
/// )
/// ```
///
/// See also:
/// - [TBreakdownCard] for header + line items + total
/// - [TKeyValueSection] for key/value grid layouts
class TSummaryList extends StatelessWidget {
  /// Optional section title.
  final String? title;

  /// Optional icon shown before the title.
  final IconData? titleIcon;

  /// Optional custom title leading widget.
  final Widget? titleLeading;

  /// Summary rows.
  final List<TSummaryItem> items;

  /// Accent color for title icon.
  final Color? color;

  /// Spacing between rows.
  final double spacing;

  /// Icon size for row icons.
  final double iconSize;

  /// Internal padding.
  final EdgeInsetsGeometry padding;

  /// Whether to wrap content in a [TCard].
  final bool card;

  /// Creates a summary list.
  const TSummaryList({
    super.key,
    this.title,
    this.titleIcon,
    this.titleLeading,
    required this.items,
    this.color,
    this.spacing = 12,
    this.iconSize = 18,
    this.padding = const EdgeInsets.all(16),
    this.card = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = color ?? colors.primary;

    final content = Padding(
      padding: card ? EdgeInsets.zero : padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || titleIcon != null || titleLeading != null) ...[
            Row(
              children: [
                if (titleLeading != null)
                  titleLeading!
                else if (titleIcon != null) ...[
                  Icon(titleIcon, size: 22, color: accent),
                  const SizedBox(width: 8),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            _buildRow(context, items[i]),
          ],
        ],
      ),
    );

    if (!card) return content;

    return TCard(
      padding: padding,
      child: content,
    );
  }

  Widget _buildRow(BuildContext context, TSummaryItem item) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.leading != null)
          item.leading!
        else if (item.icon != null) ...[
          Icon(
            item.icon,
            size: iconSize,
            color: item.iconColor ?? colors.onSurface,
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            item.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.onSurface,
              height: 1.35,
            ),
          ),
        ),
        if (item.trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            item.trailing!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}
