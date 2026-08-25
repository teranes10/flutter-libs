import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

export 'dashed_line.dart';
export 'timeline_indicator.dart';
export 'timeline_item.dart';

/// Alignment for the indicator relative to the item content.
enum TTimelineIndicatorAlignment {
  /// Aligned to the top of the item header.
  top,

  /// Centered vertically with the item content.
  center,
}

/// A timeline widget displaying sequential events, milestones, or activity logs.
///
/// Features:
/// - Circular indicators surrounded by colored rings ([TTimelineIndicator]).
/// - Customizable colors resolved via theme variants ([TVariant]).
/// - Customizable connecting lines with **dashed**, **solid**, or **dotted** styles ([TDashedLine]).
/// - Comprehensive item layout supporting **title**, **subtitle**, **description**, and **trailing/time** metadata.
/// - Rich content embedding (cards, action buttons, image attachments).
/// - Both vertical and horizontal timeline orientations.
///
/// ## Example Usage
///
/// ```dart
/// TTimeline(
///   lineStyle: TTimelineLineStyle.dashed,
///   items: [
///     TTimelineItem(
///       titleText: 'Order Placed',
///       subtitleText: 'Order #ORD-98234 has been created',
///       descriptionText: 'Payment received via Credit Card ending in 4242.',
///       timeText: '10:30 AM',
///       iconData: Icons.shopping_bag_outlined,
///       color: context.theme.success,
///       isCompleted: true,
///     ),
///     TTimelineItem(
///       titleText: 'Processing',
///       subtitleText: 'Item packed and ready for dispatch',
///       descriptionText: 'Package inspected and handed over to logistics courier.',
///       timeText: '01:15 PM',
///       iconData: Icons.inventory_2_outlined,
///       color: context.theme.primary,
///       isActive: true,
///     ),
///     TTimelineItem(
///       titleText: 'Out for Delivery',
///       subtitleText: 'Driver is on the way',
///       descriptionText: 'Estimated delivery between 4:00 PM and 6:00 PM.',
///       iconData: Icons.local_shipping_outlined,
///     ),
///   ],
/// )
/// ```
class TTimeline extends StatelessWidget {
  /// The list of items in the timeline.
  final List<TTimelineItem> items;

  /// Direction of the timeline (vertical or horizontal). Defaults to [Axis.vertical].
  final Axis direction;

  /// Default line style for connecting lines (dashed, solid, dotted, none). Defaults to [TTimelineLineStyle.dashed].
  final TTimelineLineStyle lineStyle;

  /// Length of each dash segment for dashed lines. Defaults to 5.0.
  final double dashLength;

  /// Gap between dashes for dashed lines. Defaults to 3.5.
  final double dashGap;

  /// Thickness of the connecting line. Defaults to 2.0.
  final double lineWidth;

  /// Default color of the connecting line. Defaults to theme's outlineVariant.
  final Color? lineColor;

  /// Outer diameter of the circular indicator. Defaults to 24.0.
  final double indicatorSize;

  /// Thickness of the outer ring around each circle. Defaults to 2.0.
  final double ringWidth;

  /// Spacing gap between the outer ring and inner circle. Defaults to 2.5.
  final double ringGap;

  /// Default visual variant of the indicators (solid, tonal, outline, etc.). Defaults to [TVariant.tonal].
  final TVariant variant;

  /// Vertical (or horizontal) spacing between timeline items. Defaults to 16.0.
  final double itemGap;

  /// Horizontal spacing between the indicator and the text content. Defaults to 14.0.
  final double contentGap;

  /// Gap between the indicator and the start/end of the connecting line. Defaults to 5.0.
  final double lineGap;

  /// Alignment of the indicator relative to the content column.
  final TTimelineIndicatorAlignment indicatorAlignment;

  /// Padding around the entire timeline widget.
  final EdgeInsetsGeometry? padding;

  /// Callback fired when an item is tapped.
  final ValueChanged<int>? onItemTap;

  /// Custom text style for titles.
  final TextStyle? titleStyle;

  /// Custom text style for subtitles.
  final TextStyle? subtitleStyle;

  /// Custom text style for descriptions.
  final TextStyle? descriptionStyle;

  /// Custom text style for trailing/time texts.
  final TextStyle? timeStyle;

  const TTimeline({
    super.key,
    required this.items,
    this.direction = Axis.vertical,
    this.lineStyle = TTimelineLineStyle.dashed,
    this.dashLength = 5.0,
    this.dashGap = 3.5,
    this.lineWidth = 2.0,
    this.lineColor,
    this.indicatorSize = 24.0,
    this.ringWidth = 2.0,
    this.ringGap = 2.5,
    this.variant = TVariant.outline,
    this.itemGap = 16.0,
    this.contentGap = 14.0,
    this.lineGap = 5.0,
    this.indicatorAlignment = TTimelineIndicatorAlignment.top,
    this.padding,
    this.onItemTap,
    this.titleStyle,
    this.subtitleStyle,
    this.descriptionStyle,
    this.timeStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final content = direction == Axis.vertical ? _buildVerticalTimeline(context) : _buildHorizontalTimeline(context);

    if (padding != null) {
      return Padding(padding: padding!, child: content);
    }
    return content;
  }

  // ---------------------------------------------------------------------------
  // Vertical Timeline Layout
  // ---------------------------------------------------------------------------

  Widget _buildVerticalTimeline(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment:
                indicatorAlignment == TTimelineIndicatorAlignment.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              // Left Column: Indicator + Connecting Line
              _buildVerticalIndicatorColumn(context, index, item, isLast),

              SizedBox(width: contentGap),

              // Right Column: Title, Subtitle, Desc, Trailing, Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : itemGap),
                  child: _buildItemContent(context, index, item),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildVerticalIndicatorColumn(
    BuildContext context,
    int index,
    TTimelineItem item,
    bool isLast,
  ) {
    final colors = context.colors;

    final resolvedLineStyle = item.lineStyle ?? lineStyle;
    final resolvedLineColor = item.lineColor ??
        lineColor ??
        (item.isCompleted && item.color != null
            ? item.color!.withAlpha(160)
            : (item.isCompleted ? context.theme.primary.withAlpha(160) : colors.outlineVariant));

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildIndicator(context, index, item),
        if (!isLast)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: lineGap),
              child: TDashedLine(
                direction: Axis.vertical,
                color: resolvedLineColor,
                strokeWidth: lineWidth,
                dashLength: dashLength,
                dashGap: dashGap,
                style: resolvedLineStyle,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Horizontal Timeline Layout
  // ---------------------------------------------------------------------------

  Widget _buildHorizontalTimeline(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          final resolvedLineStyle = item.lineStyle ?? lineStyle;
          final resolvedLineColor = item.lineColor ??
              lineColor ??
              (item.isCompleted && item.color != null
                  ? item.color!.withAlpha(160)
                  : (item.isCompleted ? context.theme.primary.withAlpha(160) : context.colors.outlineVariant));

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildIndicator(context, index, item),
                        if (!isLast)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: lineGap),
                              child: TDashedLine(
                                direction: Axis.horizontal,
                                color: resolvedLineColor,
                                strokeWidth: lineWidth,
                                dashLength: dashLength,
                                dashGap: dashGap,
                                style: resolvedLineStyle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildItemContent(context, index, item),
                  ],
                ),
              ),
              if (!isLast) SizedBox(width: itemGap),
            ],
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Indicator Builder
  // ---------------------------------------------------------------------------

  Widget _buildIndicator(BuildContext context, int index, TTimelineItem item) {
    if (item.indicator != null) {
      return GestureDetector(
        onTap: () {
          item.onTap?.call();
          onItemTap?.call(index);
        },
        child: item.indicator!,
      );
    }

    return TTimelineIndicator(
      size: indicatorSize,
      color: item.color,
      ringColor: item.ringColor,
      innerColor: item.innerColor,
      ringWidth: ringWidth,
      ringGap: ringGap,
      icon: item.icon,
      iconData: item.iconData,
      iconSize: item.iconSize,
      iconColor: item.iconColor,
      variant: item.variant ?? variant,
      isActive: item.isActive,
      isCompleted: item.isCompleted,
      onTap: () {
        item.onTap?.call();
        onItemTap?.call(index);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Content Builder (Title, Subtitle, Description, Trailing, Content)
  // ---------------------------------------------------------------------------

  Widget _buildItemContent(BuildContext context, int index, TTimelineItem item) {
    final colors = context.colors;
    final hasTitle = item.title != null || item.titleText != null;
    final hasSubtitle = item.subtitle != null || item.subtitleText != null;
    final hasDescription = item.description != null || item.descriptionText != null;
    final hasTrailing = item.trailing != null || item.timeText != null;

    return InkWell(
      onTap: item.onTap != null || onItemTap != null
          ? () {
              item.onTap?.call();
              onItemTap?.call(index);
            }
          : null,
      borderRadius: BorderRadius.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Title & Trailing/Time
          if (hasTitle || hasTrailing)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasTitle)
                  Expanded(
                    child: item.title ??
                        Text(
                          item.titleText!,
                          style: titleStyle ??
                              TextStyle(
                                fontSize: 14,
                                fontWeight: item.isActive ? FontWeight.w400 : FontWeight.w300,
                                color: item.isActive ? (item.color ?? colors.primary) : colors.onSurface,
                              ),
                        ),
                  ),
                if (hasTrailing) ...[
                  if (hasTitle) const SizedBox(width: 8),
                  item.trailing ??
                      Text(
                        item.timeText!,
                        style: timeStyle ??
                            TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: colors.onSurfaceVariant.withAlpha(160),
                            ),
                      ),
                ],
              ],
            ),

          // Subtitle
          if (hasSubtitle)
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: item.subtitle ??
                  Text(
                    item.subtitleText!,
                    style: subtitleStyle ??
                        TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          color: colors.onSurfaceVariant,
                        ),
                  ),
            ),

          // Description (desc for every line)
          if (hasDescription)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: item.description ??
                  Text(
                    item.descriptionText!,
                    style: descriptionStyle ??
                        TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          height: 1.45,
                          color: colors.onSurfaceVariant.withAlpha(200),
                        ),
                  ),
            ),

          // Optional Extra Content (cards, attachments, action buttons)
          if (item.content != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: item.content!,
            ),
        ],
      ),
    );
  }
}
