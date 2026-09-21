import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

export 'tile_size.dart';

/// A versatile tile widget containing a leading icon/image container, title, subtitle, and optional trailing widget.
///
/// `TTile` can be used standalone, inside cards, lists, accordions, and table cells.
/// Sizing uses the unified [TSize] system, with presets [TTileSize.h1] through [TTileSize.h6]
/// available via [size] or named constructors [TTile.h1] through [TTile.h6].
/// All visual properties including icon colors, background colors, padding,
/// border radius, text styles, and spacing are fully configurable.
class TTile extends StatelessWidget {
  /// The size configuration of the tile. Defaults to [TTileSize.h5].
  final TSize size;

  /// The title text to display.
  final String? title;

  /// Custom widget for the title.
  final Widget? titleWidget;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Custom widget for the subtitle.
  final Widget? subtitleWidget;

  /// Leading icon. Supports [IconData], HugeIcon, or [Widget].
  final dynamic icon;

  /// Leading icon. Alias for [icon].
  final dynamic leading;

  /// Color of the leading icon.
  final Color? iconColor;

  /// Color of the leading icon when hovered.
  final Color? hoveredIconColor;

  /// Color of the leading icon when expanded/active.
  final Color? expandedIconColor;

  /// Background color of the leading icon container.
  final Color? iconBackgroundColor;

  /// Background color of the leading icon container when hovered.
  final Color? hoveredIconBackgroundColor;

  /// Background color of the leading icon container when expanded/active.
  final Color? expandedIconBackgroundColor;

  /// Padding inside the leading icon container.
  ///
  /// Defaults to [size.padding].
  final EdgeInsetsGeometry? iconPadding;

  /// Border radius of the leading icon container.
  ///
  /// Defaults to [size.borderRadius].
  final BorderRadius? iconBorderRadius;

  /// Size of the leading icon.
  ///
  /// Defaults to [size.iconSize].
  final double? iconSize;

  /// Text style for the title. Merged on top of default sizing style if provided.
  final TextStyle? titleStyle;

  /// Text style for the subtitle. Merged on top of default sizing style if provided.
  final TextStyle? subtitleStyle;

  /// Horizontal spacing between the leading icon and title/subtitle column.
  ///
  /// Defaults to [size.spacing].
  final double? spacing;

  /// Cross axis alignment of the row.
  ///
  /// Defaults to [CrossAxisAlignment.center].
  final CrossAxisAlignment crossAxisAlignment;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Internal padding around the tile.
  final EdgeInsetsGeometry? padding;

  /// Border radius of the tile when clickable.
  final BorderRadius? borderRadius;

  /// Whether the tile is currently in a hovered state.
  final bool isHovered;

  /// Whether the tile is currently in an expanded/active state.
  final bool isExpanded;

  const TTile({
    super.key,
    this.size = TTileSize.h5,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.leading,
    this.iconColor,
    this.hoveredIconColor,
    this.expandedIconColor,
    this.iconBackgroundColor,
    this.hoveredIconBackgroundColor,
    this.expandedIconBackgroundColor,
    this.iconPadding,
    this.iconBorderRadius,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
  });

  /// Heading 1: Extra-large tile for hero headers, primary dashboards, and page titles.
  const TTile.h1({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.leading,
    this.iconColor,
    this.hoveredIconColor,
    this.expandedIconColor,
    this.iconBackgroundColor,
    this.hoveredIconBackgroundColor,
    this.expandedIconBackgroundColor,
    this.iconPadding,
    this.iconBorderRadius,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
  }) : size = TTileSize.h1;

  /// Heading 2: Large tile for major section headers and modal titles.
  const TTile.h2({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.leading,
    this.iconColor,
    this.hoveredIconColor,
    this.expandedIconColor,
    this.iconBackgroundColor,
    this.hoveredIconBackgroundColor,
    this.expandedIconBackgroundColor,
    this.iconPadding,
    this.iconBorderRadius,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
  }) : size = TTileSize.h2;

  /// Heading 3: Medium-large tile for secondary sections and large card headers.
  const TTile.h3({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.leading,
    this.iconColor,
    this.hoveredIconColor,
    this.expandedIconColor,
    this.iconBackgroundColor,
    this.hoveredIconBackgroundColor,
    this.expandedIconBackgroundColor,
    this.iconPadding,
    this.iconBorderRadius,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
  }) : size = TTileSize.h3;

  /// Heading 4: Standard prominent tile for regular cards and dialog sections.
  const TTile.h4({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.leading,
    this.iconColor,
    this.hoveredIconColor,
    this.expandedIconColor,
    this.iconBackgroundColor,
    this.hoveredIconBackgroundColor,
    this.expandedIconBackgroundColor,
    this.iconPadding,
    this.iconBorderRadius,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
  }) : size = TTileSize.h4;

  /// Heading 5: Standard default tile for lists, accordions, and table cells.
  const TTile.h5({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.leading,
    this.iconColor,
    this.hoveredIconColor,
    this.expandedIconColor,
    this.iconBackgroundColor,
    this.hoveredIconBackgroundColor,
    this.expandedIconBackgroundColor,
    this.iconPadding,
    this.iconBorderRadius,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
  }) : size = TTileSize.h5;

  /// Heading 6: Compact/dense tile for tight lists, sidebars, and dense table rows.
  const TTile.h6({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.leading,
    this.iconColor,
    this.hoveredIconColor,
    this.expandedIconColor,
    this.iconBackgroundColor,
    this.hoveredIconBackgroundColor,
    this.expandedIconBackgroundColor,
    this.iconPadding,
    this.iconBorderRadius,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
  }) : size = TTileSize.h6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveIcon = icon ?? leading;

    final effectiveIconSize = iconSize ?? size.icon;
    final effectiveIconPadding = iconPadding ?? (size.hPad > 0 || size.vPad > 0 ? size.padding : const EdgeInsets.all(8));
    final effectiveIconBorderRadius = iconBorderRadius ?? BorderRadius.circular(size.radius);
    final effectiveSpacing = spacing ?? size.spacing;

    Widget? leadingWidget;
    if (effectiveIcon != null) {
      if (effectiveIcon is Widget) {
        leadingWidget = effectiveIcon;
      } else {
        final defaultBg = (isHovered || isExpanded) ? colors.primaryContainer.withAlpha(128) : colors.onSurface.withAlpha(13);
        final defaultIconColor = (isHovered || isExpanded) ? colors.primary : colors.onSurfaceVariant;

        Color resolvedBg;
        if (isExpanded && expandedIconBackgroundColor != null) {
          resolvedBg = expandedIconBackgroundColor!;
        } else if (isHovered && hoveredIconBackgroundColor != null) {
          resolvedBg = hoveredIconBackgroundColor!;
        } else {
          resolvedBg = iconBackgroundColor ?? defaultBg;
        }

        Color resolvedIconColor;
        if (isExpanded && expandedIconColor != null) {
          resolvedIconColor = expandedIconColor!;
        } else if (isHovered && hoveredIconColor != null) {
          resolvedIconColor = hoveredIconColor!;
        } else {
          resolvedIconColor = iconColor ?? defaultIconColor;
        }

        leadingWidget = Container(
          padding: effectiveIconPadding,
          decoration: BoxDecoration(
            color: resolvedBg,
            borderRadius: effectiveIconBorderRadius,
          ),
          child: TIcon.raw(
            effectiveIcon,
            size: effectiveIconSize,
            color: resolvedIconColor,
          ),
        );
      }
    }

    final titleFontWeight = size.font >= 22.0 ? FontWeight.w700 : (size.font >= 16.0 ? FontWeight.w600 : FontWeight.w500);

    final defaultTitleStyle = TextStyle(
      fontSize: size.font,
      fontWeight: titleFontWeight,
      color: colors.onSurface,
    );

    final titleChild = titleWidget ??
        (title != null
            ? Text(
                title!,
                style: titleStyle != null ? defaultTitleStyle.merge(titleStyle) : defaultTitleStyle,
              )
            : const SizedBox.shrink());

    final subtitleFontSize = switch (size) {
      TTileSize.h1 => 15.0,
      TTileSize.h2 => 14.0,
      TTileSize.h3 => 13.0,
      TTileSize.h4 => 12.5,
      TTileSize.h5 => 12.0,
      TTileSize.h6 => 11.0,
      _ => (size.font * 0.85).clamp(10.0, 16.0),
    };

    final subtitleGap = switch (size) {
      TTileSize.h1 => 4.0,
      TTileSize.h2 => 3.5,
      TTileSize.h3 => 3.0,
      TTileSize.h4 => 2.5,
      TTileSize.h5 => 2.0,
      TTileSize.h6 => 1.5,
      _ => (size.font * 0.15).clamp(1.5, 4.0),
    };

    final defaultSubtitleStyle = TextStyle(
      fontSize: subtitleFontSize,
      fontWeight: FontWeight.w400,
      color: colors.onSurfaceVariant,
    );

    final subtitleChild = subtitleWidget ??
        (subtitle != null
            ? Text(
                subtitle!,
                style: subtitleStyle != null ? defaultSubtitleStyle.merge(subtitleStyle) : defaultSubtitleStyle,
              )
            : null);

    Widget content = Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (leadingWidget != null) ...[
          leadingWidget,
          SizedBox(width: effectiveSpacing),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleChild,
              if (subtitleChild != null) ...[
                SizedBox(height: subtitleGap),
                subtitleChild,
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }
}

/// Shorthand alias for [TTile].
typedef TAccordionHeader = TTile;
