import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A versatile tile widget containing a leading icon/image container, title, subtitle, and optional trailing widget.
///
/// `TTile` can be used standalone, inside cards, lists, accordions, and table cells.
/// All visual properties including icon colors, background colors, padding,
/// border radius, text styles, and spacing are fully configurable.
class TTile extends StatelessWidget {
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
  /// Defaults to `EdgeInsets.all(8.0)`.
  final EdgeInsetsGeometry? iconPadding;

  /// Border radius of the leading icon container.
  ///
  /// Defaults to `BorderRadius.circular(12.0)`.
  final BorderRadius? iconBorderRadius;

  /// Size of the leading icon.
  ///
  /// Defaults to 20.0.
  final double? iconSize;

  /// Text style for the title.
  final TextStyle? titleStyle;

  /// Text style for the subtitle.
  final TextStyle? subtitleStyle;

  /// Horizontal spacing between the leading icon and title/subtitle column.
  ///
  /// Defaults to 12.0.
  final double spacing;

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
    this.spacing = 12.0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveIcon = icon ?? leading;

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
          padding: iconPadding ?? const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: resolvedBg,
            borderRadius: iconBorderRadius ?? BorderRadius.circular(12),
          ),
          child: TIcon.raw(
            effectiveIcon,
            size: iconSize ?? 20,
            color: resolvedIconColor,
          ),
        );
      }
    }

    final titleChild = titleWidget ??
        (title != null
            ? Text(
                title!,
                style: titleStyle ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
              )
            : const SizedBox.shrink());

    final subtitleChild = subtitleWidget ??
        (subtitle != null
            ? Text(
                subtitle!,
                style: subtitleStyle ??
                    TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colors.onSurfaceVariant,
                    ),
              )
            : null);

    Widget content = Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (leadingWidget != null) ...[
          leadingWidget,
          SizedBox(width: spacing),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleChild,
              if (subtitleChild != null) ...[
                const SizedBox(height: 2),
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
