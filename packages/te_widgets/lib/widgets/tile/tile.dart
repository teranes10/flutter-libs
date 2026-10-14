import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

export 'tile_size.dart';

/// A versatile tile widget containing a leading icon/image container, title, subtitle, optional description, and optional trailing widget.
///
/// `TTile` can be used standalone, inside cards, lists, accordions, product catalogs, and table cells.
/// Sizing uses the unified [TSize] system, with presets [TTileSize.h1] through [TTileSize.h7] for headings
/// and [TTileSize.sm], [TTileSize.md], [TTileSize.lg] for image/product tiles,
/// available via [size] or named constructors [TTile.h1] through [TTile.h7] and [TTile.sm] through [TTile.lg].
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

  /// Optional description text displayed below the image/icon and title/subtitle row.
  final String? desc;

  /// Custom widget for the description.
  final Widget? descWidget;

  /// Text style for the description. Merged on top of default sizing style if provided.
  final TextStyle? descStyle;

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
  final CrossAxisAlignment? crossAxisAlignment;

  /// Optional trailing widget.
  ///
  /// With a trailing widget the tile expands to the available width and pins
  /// it to the end. Without one the tile shrinks to fit its content.
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

  /// Stacks the leading icon/image above the title block instead of beside it.
  ///
  /// Useful for hub/launcher tiles. [trailing] moves onto the icon row
  /// (far right) and [crossAxisAlignment] aligns the stacked content
  /// (defaults to [CrossAxisAlignment.start]).
  final bool iconOnTop;

  /// Optional image URL for entity/product thumbnail. Used when [icon] and [leading] are null.
  final String? imageUrl;

  /// Optional key-value items to display below the tile content.
  final List<TKeyValue>? values;

  /// Layout mode for [values]. Defaults to [TKeyValueMode.inlineFlow].
  final TKeyValueMode? valuesMode;

  /// Vertical spacing between the tile content and the [values] key-value section.
  ///
  /// Defaults to 16.0.
  final double? valuesSpacing;

  const TTile({
    super.key,
    this.size = TTileSize.h5,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  });

  /// Heading 1: Extra-large tile for hero headers, primary dashboards, and page titles.
  /// Creates a touch-friendly **task card** for mobile task lists.
  ///
  /// A left status strip, a bold [title] with an optional [status] chip, an
  /// optional [subtitle] and [meta] line (e.g. due time), and an optional
  /// `done / total` progress bar. The whole card is at least 72dp tall and
  /// tappable via [onTap].
  ///
  /// ```dart
  /// TTile.task(
  ///   title: 'SO-10452',
  ///   subtitle: '12 lines · 5 items',
  ///   meta: 'Due today 3:00 PM',
  ///   status: 'Picking',
  ///   statusColor: Colors.blue,
  ///   done: 4,
  ///   total: 12,
  ///   onTap: open,
  /// )
  /// ```
  static Widget task({
    Key? key,
    required String title,
    String? subtitle,
    String? meta,
    String? status,
    Color? statusColor,
    int? done,
    int? total,
    dynamic icon,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return _TTaskTile(
      key: key,
      title: title,
      subtitle: subtitle,
      meta: meta,
      status: status,
      statusColor: statusColor,
      done: done,
      total: total,
      icon: icon,
      selected: selected,
      onTap: onTap,
    );
  }

  const TTile.h1({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.h1;

  /// Heading 2: Large tile for major section headers and modal titles.
  const TTile.h2({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.h2;

  /// Heading 3: Medium-large tile for secondary sections and large card headers.
  const TTile.h3({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.h3;

  /// Heading 4: Standard prominent tile for regular cards and dialog sections.
  const TTile.h4({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.h4;

  /// Heading 5: Standard default tile for lists, accordions, and table cells.
  const TTile.h5({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.h5;

  /// Heading 6: Compact/dense tile for tight lists, sidebars, and dense table rows.
  const TTile.h6({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.h6;

  /// Heading 7: Extra-compact tile for nested rows such as batch lines.
  const TTile.h7({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.h7;

  /// Small product / image tile (50px image, 14px font).
  const TTile.sm({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.sm;

  /// Medium product / image tile (75px image, 16px font).
  const TTile.md({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.md;

  /// Large product / image tile (100px image, 18px font).
  const TTile.lg({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.desc,
    this.descWidget,
    this.descStyle,
    this.icon,
    this.leading,
    this.imageUrl,
    this.values,
    this.valuesMode,
    this.valuesSpacing,
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
    this.crossAxisAlignment,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.isHovered = false,
    this.isExpanded = false,
    this.iconOnTop = false,
  }) : size = TTileSize.lg;

  (double width, double height) _resolveLeadingDimensions({
    required dynamic leading,
    required double defaultSize,
    required EdgeInsetsGeometry iconPadding,
  }) {
    if (leading == null) return (0.0, 0.0);
    if (leading is TImage) {
      final w = leading.width ?? leading.size ?? defaultSize;
      final h = leading.height ?? leading.size ?? defaultSize;
      return (w, h);
    }
    if (leading is SizedBox) {
      final w = leading.width ?? defaultSize;
      final h = leading.height ?? defaultSize;
      return (w, h);
    }
    if (leading is ClipRRect && leading.child != null) {
      return _resolveLeadingDimensions(
        leading: leading.child,
        defaultSize: defaultSize,
        iconPadding: iconPadding,
      );
    }
    if (leading is Container) {
      final c = leading.constraints;
      if (c != null && c.hasBoundedWidth && c.hasBoundedHeight) {
        return (c.maxWidth, c.maxHeight);
      }
      if (leading.child != null) {
        return _resolveLeadingDimensions(
          leading: leading.child,
          defaultSize: defaultSize,
          iconPadding: iconPadding,
        );
      }
    }
    if (leading is Widget) {
      return (defaultSize, defaultSize);
    }
    if (leading is String) {
      return (defaultSize, defaultSize);
    }
    final padH = iconPadding.horizontal;
    final padV = iconPadding.vertical;
    return (defaultSize + padH, defaultSize + padV);
  }

  TextStyle _resolveTitleStyle(ColorScheme colors) {
    final titleFontWeight = size.font >= 22.0 ? FontWeight.w700 : (size.font >= 16.0 ? FontWeight.w600 : FontWeight.w500);
    final defaultTitleStyle = TextStyle(
      fontSize: size.font,
      fontWeight: titleFontWeight,
      color: colors.onSurface,
    );
    return titleStyle != null ? defaultTitleStyle.merge(titleStyle) : defaultTitleStyle;
  }

  /// Estimates the natural single-line width of this tile (leading, [title] /
  /// [subtitle] text measured with their resolved styles, padding, trailing).
  ///
  /// Used by [TGrid] to size tiles by content. Wrapping [desc] and [values] are
  /// ignored since they reflow to the available width.
  double estimateWidth(BuildContext context) {
    final colors = context.colors;
    final effectiveIcon = icon ?? leading;
    final effectiveIconSize = iconSize ?? size.icon;
    final effectiveIconPadding = iconPadding ?? (size.hPad > 0 || size.vPad > 0 ? size.padding : const EdgeInsets.all(8));
    final effectiveSpacing = spacing ?? size.spacing;

    final subtitleStyle = TextStyle(
      fontSize: size.resolveSubtitleFontSize(),
      fontWeight: FontWeight.w400,
      color: colors.onSurfaceVariant,
    ).merge(this.subtitleStyle);

    final text = math.max(
      title != null ? WidthHelper.measureText(context, title!, _resolveTitleStyle(colors)) : 0.0,
      subtitle != null ? WidthHelper.measureText(context, subtitle!, subtitleStyle) : 0.0,
    );

    final hasLeading = effectiveIcon != null || (imageUrl != null && imageUrl!.isNotEmpty);
    final leadingWidth = hasLeading
        ? _resolveLeadingDimensions(
            leading: effectiveIcon ?? imageUrl,
            defaultSize: effectiveIconSize,
            iconPadding: effectiveIconPadding,
          ).$1
        : 0.0;
    final trailingWidth = trailing != null ? 48.0 : 0.0;
    final body = iconOnTop
        ? math.max(text, leadingWidth + trailingWidth)
        : text + (hasLeading ? leadingWidth + effectiveSpacing : 0.0) + trailingWidth;
    return body + (padding?.horizontal ?? 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveCrossAxisAlignment = crossAxisAlignment ?? CrossAxisAlignment.center;
    final effectiveIcon = icon ?? leading;

    final effectiveIconSize = iconSize ?? size.icon;
    final effectiveIconPadding = iconPadding ?? (size.hPad > 0 || size.vPad > 0 ? size.padding : const EdgeInsets.all(8));
    final effectiveIconBorderRadius = iconBorderRadius ?? BorderRadius.circular(size.radius);
    final effectiveSpacing = spacing ?? size.spacing;

    final defaultBg = (isHovered || isExpanded) ? colors.primaryContainer.withAlpha(128) : colors.onSurface.withAlpha(13);
    final defaultIconColor = (isHovered || isExpanded) ? colors.primary : colors.onSurfaceVariant;

    Color resolvedIconColor;
    if (isExpanded && expandedIconColor != null) {
      resolvedIconColor = expandedIconColor!;
    } else if (isHovered && hoveredIconColor != null) {
      resolvedIconColor = hoveredIconColor!;
    } else {
      resolvedIconColor = iconColor ?? defaultIconColor;
    }

    Widget? leadingWidget;
    if (effectiveIcon != null) {
      if (effectiveIcon is Widget) {
        leadingWidget = IconTheme(
          data: IconThemeData(
            color: resolvedIconColor,
            size: effectiveIconSize,
          ),
          child: effectiveIcon,
        );
      } else {
        Color resolvedBg;
        if (isExpanded && expandedIconBackgroundColor != null) {
          resolvedBg = expandedIconBackgroundColor!;
        } else if (isHovered && hoveredIconBackgroundColor != null) {
          resolvedBg = hoveredIconBackgroundColor!;
        } else {
          resolvedBg = iconBackgroundColor ?? defaultBg;
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
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      leadingWidget = ClipRRect(
        borderRadius: effectiveIconBorderRadius,
        child: TImage(
          url: imageUrl,
          size: effectiveIconSize,
          disabled: true,
          forceCache: true,
        ),
      );
    }

    final effectiveTitleStyle = _resolveTitleStyle(colors);

    final titleChild = titleWidget ??
        (title != null
            ? Text(
                title!,
                style: effectiveTitleStyle,
              )
            : const SizedBox.shrink());

    final subtitleFontSize = size.resolveSubtitleFontSize();
    final subtitleGap = size.resolveSubtitleGap();

    final defaultSubtitleStyle = TextStyle(
      fontSize: subtitleFontSize,
      fontWeight: FontWeight.w400,
      color: colors.onSurfaceVariant,
    );

    final effectiveSubtitleStyle = subtitleStyle != null ? defaultSubtitleStyle.merge(subtitleStyle) : defaultSubtitleStyle;

    final subtitleChild = subtitleWidget ??
        (subtitle != null
            ? Text(
                subtitle!,
                style: effectiveSubtitleStyle,
              )
            : null);

    final descFontSize = size.resolveDescFontSize();
    final descGap = size.resolveDescGap();

    final defaultDescStyle = TextStyle(
      fontSize: descFontSize,
      fontWeight: FontWeight.w400,
      color: colors.onSurfaceVariant,
    );

    final effectiveDescStyle = descStyle != null ? defaultDescStyle.merge(descStyle) : defaultDescStyle;

    final descChild = descWidget ??
        (desc != null
            ? Text(
                desc!,
                style: effectiveDescStyle,
              )
            : null);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final hasLeading = leadingWidget != null;
        final (leadingWidth, leadingHeight) = _resolveLeadingDimensions(
          leading: effectiveIcon ?? (imageUrl != null && imageUrl!.isNotEmpty ? imageUrl : null),
          defaultSize: effectiveIconSize,
          iconPadding: effectiveIconPadding,
        );

        bool descInColumn = false;
        if (descChild != null) {
          if (!hasLeading || leadingHeight <= 0) {
            descInColumn = true;
          } else {
            final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
            final textScaler = MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;

            final trailingReserve = trailing != null ? 48.0 : 0.0;
            final paddingReserve = padding?.horizontal ?? 0.0;
            final leadingReserve = hasLeading ? leadingWidth + effectiveSpacing : 0.0;

            final maxTextWidth = availableWidth.isFinite
                ? math.max(0.0, availableWidth - leadingReserve - trailingReserve - paddingReserve)
                : double.infinity;

            double measureHeight(String? text, TextStyle style) {
              if (text == null || text.isEmpty || maxTextWidth <= 0) return 0.0;
              final painter = TextPainter(
                text: TextSpan(text: text, style: style),
                textDirection: direction,
                textScaler: textScaler,
              );
              painter.layout(maxWidth: maxTextWidth);
              final h = painter.height;
              painter.dispose();
              return h;
            }

            final titleH = title != null ? measureHeight(title, effectiveTitleStyle) : (titleWidget != null ? size.font * 1.3 : 0.0);

            final subH = subtitle != null
                ? measureHeight(subtitle, effectiveSubtitleStyle)
                : (subtitleWidget != null ? subtitleFontSize * 1.3 : 0.0);

            final descH = desc != null ? measureHeight(desc, effectiveDescStyle) : (descWidget != null ? descFontSize * 1.3 : 0.0);

            double requiredTextHeight = titleH;
            if (subtitleChild != null) {
              requiredTextHeight += subtitleGap + subH;
            }
            requiredTextHeight += descGap + descH;

            // If in image height then below subtitle else go below image
            descInColumn = requiredTextHeight <= leadingHeight;
          }
        }

        final columnChildren = <Widget>[
          titleChild,
          if (subtitleChild != null) ...[
            SizedBox(height: subtitleGap),
            subtitleChild,
          ],
          if (descChild != null && descInColumn) ...[
            SizedBox(height: descGap),
            descChild,
          ],
        ];

        final textColumn = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: iconOnTop ? (crossAxisAlignment ?? CrossAxisAlignment.start) : CrossAxisAlignment.start,
          children: columnChildren,
        );

        final Widget topRow;
        if (iconOnTop && leadingWidget != null) {
          topRow = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
            children: [
              if (trailing != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [leadingWidget, const Spacer(), trailing!],
                )
              else
                leadingWidget,
              SizedBox(height: effectiveSpacing),
              textColumn,
            ],
          );
        } else {
          topRow = Row(
            mainAxisSize: trailing != null ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: effectiveCrossAxisAlignment,
            children: [
              if (leadingWidget != null) ...[
                leadingWidget,
                SizedBox(width: effectiveSpacing),
              ],
              if (trailing != null) Expanded(child: textColumn) else Flexible(child: textColumn),
              if (trailing != null) trailing!,
            ],
          );
        }

        Widget content;
        if (descChild != null && !descInColumn) {
          content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              topRow,
              SizedBox(height: descGap),
              descChild,
            ],
          );
        } else {
          content = topRow;
        }

        if (values != null && values!.isNotEmpty) {
          content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              SizedBox(height: valuesSpacing ?? 24.0),
              TKeyValueSection(
                values: values!,
                mode: valuesMode ?? TKeyValueMode.inlineFlow,
              ),
            ],
          );
        }

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
      },
    );
  }
}

/// Shorthand alias for [TTile].
typedef TAccordionHeader = TTile;

/// Implementation of [TTile.task].
class _TTaskTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? meta;
  final String? status;
  final Color? statusColor;
  final int? done;
  final int? total;
  final dynamic icon;
  final bool selected;
  final VoidCallback? onTap;

  const _TTaskTile({
    super.key,
    required this.title,
    this.subtitle,
    this.meta,
    this.status,
    this.statusColor,
    this.done,
    this.total,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = statusColor ?? colors.primary;
    final hasProgress = total != null && total! > 0;
    final progress = hasProgress ? ((done ?? 0) / total!).clamp(0.0, 1.0) : 0.0;
    final radius = BorderRadius.circular(10);

    // No card chrome: wrap with `.card()` for a surface/border/shadow.
    return Material(
      color: selected ? accent.withAlpha(20) : Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: accent),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14, 12, 14, hasProgress ? 6 : 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (icon != null) ...[
                              TIcon.raw(icon, size: 18, color: accent),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: colors.onSurface),
                              ),
                            ),
                            if (status != null) ...[
                              const SizedBox(width: 8),
                              TChip(text: status, color: accent, size: TChipSize.sm),
                            ],
                          ],
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              subtitle!,
                              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant),
                            ),
                          ),
                        if (meta != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              meta!,
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant),
                            ),
                          ),
                        if (hasProgress)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TProgressBar(
                                    value: progress,
                                    height: 4,
                                    color: accent,
                                    valueText: '${done ?? 0} / $total',
                                    valuePosition: TProgressValuePosition.afterProgress,
                                    valueStyle: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
