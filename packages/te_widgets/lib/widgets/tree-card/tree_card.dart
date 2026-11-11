import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// An expandable card whose [children] hang off a tree connector line.
///
/// The card shows a chevron + [header] (usually a [TTile] with `values`/`footer`).
/// Tapping the card expands it to reveal [children], each joined to the parent by
/// a rounded elbow connector. Children are normally cards themselves (a nested
/// [TTreeCard] for deeper levels, or any widget wrapped with `.card()`).
///
/// ```dart
/// TTreeCard(
///   initiallyExpanded: true,
///   header: TTile.md(imageUrl: url, title: 'JR Bengal Gram', subtitle: '2 locations',
///       valuesDivider: true, values: [TKeyValue('Total units', value: '183')]),
///   children: [
///     TTreeCard(header: TTile(title: 'BENGAL-GRAM-1KG'), children: [
///       TTile(title: 'Main Warehouse').card(),
///     ]),
///   ],
/// )
/// ```
class TTreeCard extends StatefulWidget {
  /// Content of the card, shown beside the chevron.
  final Widget header;

  /// Child nodes drawn below the card on the tree line.
  final List<Widget> children;

  /// Whether the card starts expanded (ignored when [isExpanded] is set).
  final bool initiallyExpanded;

  /// Controlled expansion state.
  final bool? isExpanded;

  /// Called with the new state when the user toggles the card.
  final ValueChanged<bool>? onExpansionChanged;

  /// Padding inside the card.
  final EdgeInsetsGeometry padding;

  /// Horizontal distance from the parent card's left edge to the tree line.
  /// Defaults to 24 (12 on narrow/mobile screens).
  final double? lineInset;

  /// Width of the elbow between the tree line and each child.
  /// Defaults to 24 (14 on narrow/mobile screens).
  final double? elbowWidth;

  /// Vertical gap between the card and its children, and between siblings.
  /// Defaults to 12 (10 on narrow/mobile screens).
  final double? gap;

  /// Distance from the top of a child to its elbow (align with the child's first line).
  /// Defaults to 28 (22 on narrow/mobile screens).
  final double? elbowY;

  /// Draws a small dot where each elbow meets its child.
  final bool showDots;

  /// Overrides the connector color (defaults to the theme outline).
  final Color? lineColor;

  /// Card tap handler. When set, only the chevron toggles expansion.
  final VoidCallback? onTap;

  /// Card background color.
  final Color? backgroundColor;

  /// Whether the card can expand even while [children] is empty (e.g. children are built lazily
  /// only when expanded). Defaults to `children.isNotEmpty`.
  final bool? expandable;

  /// Vertically centers the chevron against the header (default). When false it sits at the top,
  /// which suits headers that grow tall (e.g. a row with inline expanded details).
  final bool centerChevron;

  /// Reserves the chevron slot on cards without children so sibling headers stay aligned
  /// (e.g. rows sharing table columns).
  final bool alignLeaves;

  /// Card shadow. Defaults to [TCardShadow.sm] on narrow/mobile screens and
  /// [TCardShadow.none] on large screens.
  final TCardShadow? shadow;

  /// Width of the chevron slot.
  static const double chevronWidth = 28;

  /// Horizontal space one nesting level takes (line inset + elbow) for the current screen size,
  /// so callers can size nested content (e.g. table columns) to the remaining width.
  static double indentOf(BuildContext context, {double? lineInset, double? elbowWidth}) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return (lineInset ?? (compact ? 12.0 : 24.0)) + (elbowWidth ?? (compact ? 14.0 : 24.0));
  }

  const TTreeCard({
    super.key,
    required this.header,
    this.children = const [],
    this.initiallyExpanded = false,
    this.isExpanded,
    this.onExpansionChanged,
    this.padding = const EdgeInsets.all(16),
    this.lineInset,
    this.elbowWidth,
    this.gap,
    this.elbowY,
    this.showDots = false,
    this.lineColor,
    this.onTap,
    this.backgroundColor,
    this.expandable,
    this.alignLeaves = false,
    this.centerChevron = true,
    this.shadow,
  });

  @override
  State<TTreeCard> createState() => _TTreeCardState();
}

class _TTreeCardState extends State<TTreeCard> {
  late bool _expanded = widget.isExpanded ?? widget.initiallyExpanded;

  bool get _isExpanded => widget.isExpanded ?? _expanded;

  void _toggle() {
    final next = !_isExpanded;
    widget.onExpansionChanged?.call(next);
    if (widget.isExpanded == null) setState(() => _expanded = next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasChildren = widget.expandable ?? widget.children.isNotEmpty;
    final expanded = _isExpanded && widget.children.isNotEmpty;
    final lineColor = widget.lineColor ?? colors.outlineVariant.withAlpha(160);
    final compact = MediaQuery.sizeOf(context).width < 600;
    final lineInset = widget.lineInset ?? (compact ? 12.0 : 24.0);
    final elbowWidth = widget.elbowWidth ?? (compact ? 14.0 : 24.0);
    final gap = widget.gap ?? (compact ? 10.0 : 12.0);
    final elbowY = widget.elbowY ?? (compact ? 22.0 : 28.0);

    Widget? chevron;
    if (hasChildren) {
      chevron = SizedBox(
        width: TTreeCard.chevronWidth,
        child: AnimatedRotation(
          turns: _isExpanded ? 0 : -0.25,
          duration: const Duration(milliseconds: 200),
          child: TIcon.raw(HugeIcons.strokeRoundedArrowDown01, size: 20, color: colors.onSurfaceVariant),
        ),
      );
      if (widget.onTap != null) {
        chevron = GestureDetector(behavior: HitTestBehavior.opaque, onTap: _toggle, child: chevron);
      }
    }

    final card = TCard(
      padding: widget.padding,
      margin: EdgeInsets.zero,
      shadowLevel: widget.shadow ?? (compact ? TCardShadow.sm : TCardShadow.none),
      backgroundColor: widget.backgroundColor,
      onTap: widget.onTap ?? (hasChildren ? _toggle : null),
      child: Row(
        crossAxisAlignment: widget.centerChevron ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (chevron != null) chevron else if (widget.alignLeaves) const SizedBox(width: TTreeCard.chevronWidth),
          Expanded(child: widget.header),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        card,
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: !expanded
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: EdgeInsets.only(left: lineInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < widget.children.length; i++)
                        // CustomPaint sizes to the child, so the trunk spans the full child height
                        // without IntrinsicHeight (which breaks on LayoutBuilder-based tiles).
                        CustomPaint(
                          painter: _TreeElbowPainter(
                            color: lineColor,
                            width: elbowWidth,
                            elbowY: gap + elbowY,
                            isLast: i == widget.children.length - 1,
                            showDot: widget.showDots,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: elbowWidth, top: gap),
                            child: widget.children[i],
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _TreeElbowPainter extends CustomPainter {
  final Color color;
  final double width;
  final double elbowY;
  final bool isLast;
  final bool showDot;

  const _TreeElbowPainter({required this.color, required this.width, required this.elbowY, required this.isLast, required this.showDot});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const r = 8.0;
    final dotSpace = showDot ? 8.0 : 0.0;
    final endX = width - dotSpace;
    final y = elbowY.clamp(r, size.height);

    // Trunk: runs the full height for non-last siblings, stops at the elbow for the last.
    final path = Path()..moveTo(0, 0);
    if (!isLast) {
      canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
      path
        ..reset()
        ..moveTo(0, y - r);
    }
    path
      ..lineTo(0, y - r)
      ..quadraticBezierTo(0, y, r, y)
      ..lineTo(endX, y);
    canvas.drawPath(path, paint);

    if (showDot) {
      canvas.drawCircle(Offset(width - 3, y), 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_TreeElbowPainter old) =>
      old.color != color || old.width != width || old.elbowY != elbowY || old.isLast != isLast || old.showDot != showDot;
}
