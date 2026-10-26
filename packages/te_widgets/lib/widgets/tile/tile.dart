import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  /// Custom leading widget/icon. Overrides [icon] and [imageUrl] when provided.
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

  /// Where [trailing] goes when it doesn't fit beside the title.
  ///
  /// `false` (default) tries the end of the subtitle, then below the subtitle.
  /// `true` skips the subtitle and puts it above the title, right-aligned.
  final bool trailingAboveOnOverflow;

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

  /// Optional image URL for entity/product thumbnail. Used when [leading] is null; takes precedence over [icon].
  final String? imageUrl;

  /// Whether [imageUrl] is persistently cached via [TImageStorage] instead of
  /// just Flutter's in-memory [ImageCache]. See [TImage.forceCache]. Defaults to `true`.
  final bool forceCache;

  /// Optional status/attribute chips ([TChip], [TBadge]) shown below the
  /// subtitle. Leave their `size` null so they follow the subtitle font size.
  final List<Widget>? highlights;

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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    this.forceCache = true,
    this.highlights,
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
    this.trailingAboveOnOverflow = false,
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
    final defaultTitleStyle = TextStyle(
      fontSize: size.font,
      fontWeight: size.resolveFontWeight(),
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
    final effectiveIcon = leading ?? ((imageUrl != null && imageUrl!.isNotEmpty) ? null : icon);
    final effectiveIconSize = iconSize ?? size.icon;
    final effectiveIconPadding = iconPadding ?? (size.hPad > 0 || size.vPad > 0 ? size.padding : const EdgeInsets.all(8));
    final effectiveSpacing = spacing ?? size.spacing;

    final subtitleStyle = TextStyle(
      fontSize: size.resolveSubtitleFontSize(),
      fontWeight: size.resolveSubtitleFontWeight(),
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
    final effectiveIcon = leading ?? ((imageUrl != null && imageUrl!.isNotEmpty) ? null : icon);

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
          forceCache: forceCache,
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
      fontWeight: size.resolveSubtitleFontWeight(),
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
      fontWeight: FontWeight.w300,
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

    return _HeadCenterHost(
      builder: (headCenter) => LayoutBuilder(
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

              // Desc spans under the trailing widget, so it only loses the leading/padding width.
              final descTextWidth =
                  availableWidth.isFinite ? math.max(0.0, availableWidth - leadingReserve - paddingReserve) : double.infinity;

              double measureHeight(String? text, TextStyle style, [double? width]) {
                final maxWidth = width ?? maxTextWidth;
                if (text == null || text.isEmpty || maxWidth <= 0) return 0.0;
                final painter = TextPainter(
                  text: TextSpan(text: text, style: style),
                  textDirection: direction,
                  textScaler: textScaler,
                );
                painter.layout(maxWidth: maxWidth);
                final h = painter.height;
                painter.dispose();
                return h;
              }

              final titleH = title != null ? measureHeight(title, effectiveTitleStyle) : (titleWidget != null ? size.font * 1.3 : 0.0);

              final subH = subtitle != null
                  ? measureHeight(subtitle, effectiveSubtitleStyle)
                  : (subtitleWidget != null ? subtitleFontSize * 1.3 : 0.0);

              final descH =
                  desc != null ? measureHeight(desc, effectiveDescStyle, descTextWidth) : (descWidget != null ? descFontSize * 1.3 : 0.0);

              double requiredTextHeight = titleH;
              if (subtitleChild != null) {
                requiredTextHeight += subtitleGap + subH;
              }
              requiredTextHeight += descGap + descH;

              // If in image height then below subtitle else go below image
              descInColumn = requiredTextHeight <= leadingHeight;
            }
          }

          final headChildren = <Widget>[
            titleChild,
            if (subtitleChild != null) ...[
              SizedBox(height: subtitleGap),
              subtitleChild,
            ],
          ];

          // Trailing sits beside title/subtitle only, so desc gets the full text width.
          final trailingBesideHead = trailing != null && !iconOnTop;

          final columnChildren = <Widget>[
            if (trailingBesideHead)
              _TileHead(
                title: titleChild,
                subtitle: subtitleChild,
                trailing: trailing!,
                subtitleGap: subtitleGap,
                gap: 8,
                rowGap: 3,
                trailingAbove: trailingAboveOnOverflow,
                textCenter: crossAxisAlignment == null ? headCenter : null,
              )
            else
              ...headChildren,
            if (highlights != null && highlights!.isNotEmpty) ...[
              SizedBox(height: subtitleGap + 4),
              THighlights(items: highlights!, fontSize: subtitleFontSize),
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
              crossAxisAlignment:
                  (trailingBesideHead && crossAxisAlignment == null) ? CrossAxisAlignment.start : effectiveCrossAxisAlignment,
              children: [
                if (leadingWidget != null) ...[
                  if (trailingBesideHead && crossAxisAlignment == null)
                    ValueListenableBuilder<double?>(
                      valueListenable: headCenter,
                      child: leadingWidget,
                      builder: (_, c, child) => c == null
                          ? child!
                          : Transform.translate(
                              offset: Offset(0, c),
                              child: FractionalTranslation(translation: const Offset(0, -0.5), child: child),
                            ),
                    )
                  else
                    leadingWidget,
                  SizedBox(width: effectiveSpacing),
                ],
                if (trailing != null) Expanded(child: textColumn) else Flexible(child: textColumn),
                if (trailing != null && iconOnTop) trailing!,
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
                SizedBox(height: valuesSpacing ?? 16.0),
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
      ),
    );
  }
}

/// Owns the notifier through which [_TileHead] reports the center of its text block.
class _HeadCenterHost extends StatefulWidget {
  final Widget Function(ValueNotifier<double?> center) builder;

  const _HeadCenterHost({required this.builder});

  @override
  State<_HeadCenterHost> createState() => _HeadCenterHostState();
}

class _HeadCenterHostState extends State<_HeadCenterHost> {
  final _center = ValueNotifier<double?>(null);

  @override
  void dispose() {
    _center.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_center);
}

enum _HeadSlot { title, subtitle, trailing }

/// Places [trailing] at the end of the title row when it fits beside the
/// title, else at the end of the subtitle row, else below the subtitle.
class _TileHead extends SlottedMultiChildRenderObjectWidget<_HeadSlot, RenderBox> {
  final Widget title;
  final Widget? subtitle;
  final Widget trailing;
  final double subtitleGap;
  final double gap;
  final double rowGap;
  final bool trailingAbove;
  final ValueNotifier<double?>? textCenter;

  const _TileHead({
    required this.title,
    this.subtitle,
    required this.trailing,
    required this.subtitleGap,
    this.gap = 8,
    this.rowGap = 3,
    this.trailingAbove = false,
    this.textCenter,
  });

  @override
  Iterable<_HeadSlot> get slots => _HeadSlot.values;

  @override
  Widget? childForSlot(_HeadSlot slot) => switch (slot) {
        _HeadSlot.title => title,
        _HeadSlot.subtitle => subtitle,
        _HeadSlot.trailing => trailing,
      };

  @override
  SlottedContainerRenderObjectMixin<_HeadSlot, RenderBox> createRenderObject(BuildContext context) =>
      _RenderTileHead(subtitleGap, gap, rowGap, trailingAbove)..textCenter = textCenter;

  @override
  void updateRenderObject(BuildContext context, covariant _RenderTileHead renderObject) {
    renderObject
      ..subtitleGap = subtitleGap
      ..gap = gap
      ..rowGap = rowGap
      ..trailingAbove = trailingAbove
      ..textCenter = textCenter;
  }
}

class _RenderTileHead extends RenderBox with SlottedContainerRenderObjectMixin<_HeadSlot, RenderBox> {
  double _subtitleGap;
  double _gap;
  double _rowGap;
  bool _trailingAbove;

  _RenderTileHead(this._subtitleGap, this._gap, this._rowGap, this._trailingAbove);

  /// Receives the vertical center of the title/subtitle block after each layout.
  ValueNotifier<double?>? textCenter;

  set trailingAbove(bool v) {
    if (_trailingAbove == v) return;
    _trailingAbove = v;
    markNeedsLayout();
  }

  set subtitleGap(double v) {
    if (_subtitleGap == v) return;
    _subtitleGap = v;
    markNeedsLayout();
  }

  set gap(double v) {
    if (_gap == v) return;
    _gap = v;
    markNeedsLayout();
  }

  set rowGap(double v) {
    if (_rowGap == v) return;
    _rowGap = v;
    markNeedsLayout();
  }

  RenderBox get _title => childForSlot(_HeadSlot.title)!;
  RenderBox? get _subtitle => childForSlot(_HeadSlot.subtitle);
  RenderBox get _trailing => childForSlot(_HeadSlot.trailing)!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxParentData) child.parentData = BoxParentData();
  }

  Size _compute(
    BoxConstraints constraints,
    Size Function(RenderBox, BoxConstraints) layout, {
    void Function(RenderBox, Offset)? place,
  }) {
    final title = _title;
    final subtitle = _subtitle;
    final trailing = _trailing;

    final trailSize = layout(trailing, BoxConstraints(maxWidth: constraints.maxWidth));
    final titleNatural = title.getMaxIntrinsicWidth(double.infinity);
    final subNatural = subtitle?.getMaxIntrinsicWidth(double.infinity) ?? 0.0;
    final width = constraints.maxWidth.isFinite ? constraints.maxWidth : math.max(titleNatural, subNatural) + _gap + trailSize.width;
    final beside = math.max(0.0, width - _gap - trailSize.width);
    final trailX = width - trailSize.width;
    final subGap = subtitle != null ? _subtitleGap : 0.0;

    double centered(double rowH, double h) => (rowH - h) / 2;

    if (titleNatural <= beside) {
      // Trailing at the end of the title row.
      final titleSize = layout(title, BoxConstraints(maxWidth: beside));
      final rowH = math.max(titleSize.height, trailSize.height);
      place?.call(title, Offset(0, centered(rowH, titleSize.height)));
      place?.call(trailing, Offset(trailX, centered(rowH, trailSize.height)));
      var height = rowH;
      if (subtitle != null) {
        final subSize = layout(subtitle, BoxConstraints(maxWidth: width));
        place?.call(subtitle, Offset(0, height + subGap));
        height += subGap + subSize.height;
      }
      return constraints.constrain(Size(width, height));
    }

    final titleSize = layout(title, BoxConstraints(maxWidth: width));
    if (!_trailingAbove && subtitle != null && subNatural <= beside) {
      // Trailing at the end of the subtitle row.
      final subSize = layout(subtitle, BoxConstraints(maxWidth: beside));
      final rowH = math.max(subSize.height, trailSize.height);
      final y = titleSize.height + subGap;
      place?.call(title, Offset.zero);
      place?.call(subtitle, Offset(0, y + centered(rowH, subSize.height)));
      place?.call(trailing, Offset(trailX, y + centered(rowH, trailSize.height)));
      return constraints.constrain(Size(width, y + rowH));
    }

    // No room beside either: below the subtitle (or title), or above the title.
    final top = _trailingAbove ? trailSize.height + _rowGap : 0.0;
    place?.call(title, Offset(0, top));
    var height = top + titleSize.height;
    if (subtitle != null) {
      final subSize = layout(subtitle, BoxConstraints(maxWidth: width));
      place?.call(subtitle, Offset(0, height + subGap));
      height += subGap + subSize.height;
    }
    if (_trailingAbove) {
      place?.call(trailing, Offset(trailX, 0));
      return constraints.constrain(Size(width, height));
    }
    place?.call(trailing, Offset(trailX, height + _rowGap));
    return constraints.constrain(Size(width, height + _rowGap + trailSize.height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _compute(constraints, (c, cons) => c.getDryLayout(cons));

  @override
  void performLayout() {
    size = _compute(
      constraints,
      (c, cons) {
        c.layout(cons, parentUsesSize: true);
        return c.size;
      },
      place: (c, o) => (c.parentData! as BoxParentData).offset = o,
    );
    final notifier = textCenter;
    if (notifier != null) {
      final last = _subtitle ?? _title;
      final top = _trailingAbove ? _trailing.size.height + _rowGap : 0.0;
      final bottom = (last.parentData! as BoxParentData).offset.dy + last.size.height;
      final center = (top + bottom) / 2;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (notifier.value != center) notifier.value = center;
      });
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => children.fold(0.0, (m, c) => math.max(m, c.getMinIntrinsicWidth(height)));

  @override
  double computeMaxIntrinsicWidth(double height) {
    final text = math.max(
      _title.getMaxIntrinsicWidth(height),
      _subtitle?.getMaxIntrinsicWidth(height) ?? 0.0,
    );
    return text + _gap + _trailing.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) => getDryLayout(BoxConstraints(maxWidth: width)).height;

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final c in children) {
      context.paintChild(c, (c.parentData! as BoxParentData).offset + offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final c in children) {
      final hit = result.addWithPaintOffset(
        offset: (c.parentData! as BoxParentData).offset,
        position: position,
        hitTest: (r, p) => c.hitTest(r, position: p),
      );
      if (hit) return true;
    }
    return false;
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
