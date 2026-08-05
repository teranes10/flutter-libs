import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A single label/value row in a [TBreakdownCard].
class TBreakdownItem {
  /// Left-side label.
  final String label;

  /// Right-side value text.
  final String value;

  /// Creates a breakdown line item.
  const TBreakdownItem({
    required this.label,
    required this.value,
  });
}

/// A card with a colored header, label/value rows, and an optional footer total.
///
/// ## Basic Usage
///
/// ```dart
/// TBreakdownCard(
///   title: 'Order Summary',
///   trailingLabel: 'Secure',
///   items: [
///     TBreakdownItem(label: 'Base Charge', value: 'LKR 250.00'),
///     TBreakdownItem(label: 'Distance Fee (30.5 km)', value: 'LKR 2850.00'),
///     TBreakdownItem(label: 'Service Tax', value: 'LKR 310.00'),
///   ],
///   totalLabel: 'Total Delivery Charge:',
///   totalValue: 'LKR 3410.00',
/// )
/// ```
///
/// See also:
/// - [TSummaryList] for icon + text summary rows
/// - [TKeyValueSection] for generic key/value display
class TBreakdownCard extends StatelessWidget {
  /// Header title.
  final String title;

  /// Optional leading header icon.
  final IconData? headerIcon;

  /// Optional trailing header label (e.g. `Secure`).
  final String? trailingLabel;

  /// Optional trailing header icon.
  final IconData? trailingIcon;

  /// Line items shown above the total.
  final List<TBreakdownItem> items;

  /// Label for the total/footer row. Hidden when null.
  final String? totalLabel;

  /// Value for the total/footer row. Hidden when null.
  final String? totalValue;

  /// Header / accent color.
  ///
  /// Defaults to the theme primary color.
  final Color? color;

  /// Header text/icon color.
  final Color? headerForegroundColor;

  /// Spacing between line items.
  final double itemSpacing;

  /// Content padding below the header.
  final EdgeInsetsGeometry contentPadding;

  /// Border radius of the card.
  final double borderRadius;

  /// Creates a breakdown card.
  const TBreakdownCard({
    super.key,
    required this.title,
    this.headerIcon,
    this.trailingLabel,
    this.trailingIcon,
    required this.items,
    this.totalLabel,
    this.totalValue,
    this.color,
    this.headerForegroundColor,
    this.itemSpacing = 10,
    this.contentPadding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
    this.borderRadius = 12,
  });

  bool get _hasTotal => totalLabel != null || totalValue != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = color ?? colors.primary;
    final headerFg = headerForegroundColor ?? Colors.white;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            offset: const Offset(0, 1),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: colors.outlineVariant.withAlpha(75)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: accent,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                if (headerIcon != null) ...[
                  Icon(headerIcon, size: 16, color: headerFg),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: headerFg,
                    ),
                  ),
                ),
                if (trailingLabel != null) ...[
                  if (trailingIcon != null) ...[
                    Icon(trailingIcon, size: 14, color: headerFg),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    trailingLabel!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: headerFg,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: contentPadding,
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) SizedBox(height: itemSpacing),
                  _buildLine(
                    context,
                    items[i].label,
                    items[i].value,
                    bold: false,
                  ),
                ],
                if (_hasTotal) ...[
                  const SizedBox(height: 12),
                  TDivider(space: 1, thickness: 1, color: colors.outlineVariant),
                  const SizedBox(height: 12),
                  _buildLine(
                    context,
                    totalLabel ?? '',
                    totalValue ?? '',
                    bold: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(BuildContext context, String label, String value, {required bool bold}) {
    final colors = context.colors;
    final style = TextStyle(
      fontSize: bold ? 15 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: colors.onSurface,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Text(value, style: style),
      ],
    );
  }
}
