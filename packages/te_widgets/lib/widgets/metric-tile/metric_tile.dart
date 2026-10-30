import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A versatile KPI Metric Tile widget used for displaying at-a-glance analytical metrics,
/// counters, quantitative stats, and relationship KPI summary cards in dashboards and entity headers.
///
/// ## Basic Usage
///
/// ```dart
/// TMetricTile(
///   label: 'Attached Products',
///   value: '14',
///   icon: HugeIcons.strokeRoundedPackage,
///   color: AppColors.primary,
///   subtitle: 'Limit: 7/step',
/// )
/// ```
///
/// ## Interactive with Trend
///
/// ```dart
/// TMetricTile(
///   label: 'Total Revenue',
///   value: '\$24,500.00',
///   icon: HugeIcons.strokeRoundedInvestigation,
///   color: AppColors.success,
///   trend: '+12.5%',
///   trendUp: true,
///   onTap: () => context.go('/admin/sales/orders'),
/// )
/// ```
class TMetricTile extends StatelessWidget {
  /// Primary metric label (e.g. 'Total Revenue', 'Published Channels').
  final String label;

  /// Primary metric numerical or status value (e.g. '$12,450', '24', 'Active').
  final String value;

  /// Optional subtitle or contextual guidance text beneath the value.
  final String? subtitle;

  /// Leading icon.
  final dynamic icon;

  /// Custom icon widget replacing [icon].
  final Widget? iconWidget;

  /// Accent theme color for the icon container and highlight styling.
  final Color? color;

  /// Optional trend text (e.g. '+12.4%', '-2.1%').
  final String? trend;

  /// Whether the trend is positive (true) or negative (false).
  final bool? trendUp;

  /// Optional trailing widget placed on the right side.
  final Widget? trailing;

  /// Optional status chip/badge text or widget.
  final Widget? badge;

  /// Optional tap interaction callback.
  final VoidCallback? onTap;

  /// Padding around the content.
  /// Defaults to `EdgeInsets.symmetric(horizontal: 14, vertical: 12)`.
  final EdgeInsetsGeometry? padding;

  /// Border radius of the tile.
  /// Defaults to `BorderRadius.circular(10)`.
  final BorderRadius? borderRadius;

  /// Custom background color.
  /// Defaults to `context.colors.surfaceContainerLow`.
  final Color? backgroundColor;

  /// Custom border color.
  final Color? borderColor;

  /// Custom text style for the [label].
  final TextStyle? labelStyle;

  /// Custom text style for the [value].
  final TextStyle? valueStyle;

  /// Custom text style for the [subtitle].
  final TextStyle? subtitleStyle;

  /// Visual variant (e.g. [TVariant.tonal], [TVariant.outline], [TVariant.solid]).
  /// When null (default) the tile keeps the neutral surface style and [color] only accents the icon.
  final TVariant? type;

  /// If true, renders a more compact horizontal layout.
  final bool compact;

  /// Optional tooltip message.
  final String? tooltip;

  const TMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconWidget,
    this.color,
    this.trend,
    this.trendUp,
    this.trailing,
    this.badge,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.labelStyle,
    this.valueStyle,
    this.subtitleStyle,
    this.type,
    this.compact = false,
    this.tooltip,
  });

  /// Variant theme derived from [color] and [type]; null when no [type] is given
  /// (neutral surface look).
  TWidgetTheme? _variantTheme(ColorScheme colors) =>
      type == null ? null : TWidgetTheme.from(colors.isDarkMode, color ?? colors.primary, type!);

  TextStyle _labelStyle(ColorScheme colors, [TWidgetTheme? theme]) =>
      labelStyle ??
      TextStyle(fontSize: compact ? 10 : 11, fontWeight: FontWeight.w500, color: theme?.onContainerVariant ?? colors.onSurfaceVariant);

  TextStyle _valueStyle(ColorScheme colors, [TWidgetTheme? theme]) =>
      valueStyle ?? TextStyle(fontSize: compact ? 13 : 15, fontWeight: FontWeight.bold, color: theme?.onContainer ?? colors.onSurface);

  TextStyle _subtitleStyle(ColorScheme colors, [TWidgetTheme? theme]) =>
      subtitleStyle ??
      TextStyle(fontSize: compact ? 9 : 10, color: (theme?.onContainerVariant ?? colors.onSurfaceVariant).withAlpha(180));

  /// Estimates the natural single-line width of this tile: [label], [value]
  /// (plus [trend]) and [subtitle] measured with their resolved styles, plus
  /// padding, border, icon and trailing chrome. Used by [TGrid] to size tiles
  /// by content.
  double estimateWidth(BuildContext context) {
    final colors = context.colors;
    final effectivePadding = padding ??
        (compact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8) : const EdgeInsets.symmetric(horizontal: 14, vertical: 12));

    final trendWidth = trend != null
        ? 6 + 4 * 2 + 10 + 2 + WidthHelper.measureText(context, trend!, const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))
        : 0.0;
    final text = [
      WidthHelper.measureText(context, label, _labelStyle(colors)),
      WidthHelper.measureText(context, value, _valueStyle(colors)) + trendWidth,
      if (subtitle != null && subtitle!.isNotEmpty) WidthHelper.measureText(context, subtitle!, _subtitleStyle(colors)),
    ].reduce((a, b) => a > b ? a : b);

    final iconWidth = (iconWidget != null || icon != null) ? (compact ? 12 : 16) + (compact ? 16 : 20) + (compact ? 8 : 12) : 0.0;
    final trailingWidth = trailing != null ? 8 + 24.0 : (onTap != null ? 4 + (compact ? 16.0 : 18.0) : 0.0);
    return effectivePadding.horizontal + 2 + iconWidth + text + trailingWidth;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = _variantTheme(colors);
    final accentColor = theme?.onContainer ?? color ?? colors.primary;
    final radius = borderRadius ?? BorderRadius.circular(10);
    final effectivePadding = padding ??
        (compact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8) : const EdgeInsets.symmetric(horizontal: 14, vertical: 12));

    final effectiveBgColor = backgroundColor ?? theme?.container ?? colors.surfaceContainerLow;
    final effectiveBorderColor = borderColor ?? theme?.outline ?? (theme != null ? Colors.transparent : colors.outlineVariant.withAlpha(60));

    final iconPadding = EdgeInsets.all(compact ? 6 : 8);

    Widget content = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: radius,
        border: Border.all(color: effectiveBorderColor),
      ),
      child: TTile(
        size: TTileSize.h7,
        spacing: compact ? 8 : 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        icon: icon,
        leading: iconWidget == null
            ? null
            : Container(
                padding: iconPadding,
                decoration: BoxDecoration(color: accentColor.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                child: iconWidget,
              ),
        iconColor: accentColor,
        iconBackgroundColor: accentColor.withAlpha(25),
        iconPadding: iconPadding,
        iconSize: compact ? 16 : 20,
        iconBorderRadius: BorderRadius.circular(8),
        // Badge sits at the end of the label row, dropping below (right-aligned) when it doesn't fit.
        titleWidget: TAlignedRow(
          spacing: 4,
          rowSpacing: 2,
          left: [Text(label, style: _labelStyle(colors, theme))],
          right: [if (badge != null) badge!],
        ),
        subtitleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trend drops to its own right-aligned row when it doesn't fit beside the value.
            TAlignedRow(
              spacing: 6,
              rowSpacing: 2,
              left: [Text(value, style: _valueStyle(colors, theme))],
              right: [if (trend != null) _buildTrendBadge(context)],
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 1),
              Text(subtitle!, style: _subtitleStyle(colors, theme)),
            ],
          ],
        ),
        trailing: trailing ??
            (onTap != null
                ? TIcon.raw(HugeIcons.strokeRoundedArrowRight01,
                    size: compact ? 16 : 18,
                    color: colors.onSurfaceVariant.withAlpha(140),
                  )
                : null),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          hoverColor: accentColor.withAlpha(20),
          child: content,
        ),
      );
    }

    if (tooltip != null) {
      content = TTooltip(
        message: tooltip!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildTrendBadge(BuildContext context) {
    final isUp = trendUp ?? true;
    final trendColor = isUp ? AppColors.success : AppColors.danger;
    final trendIcon = isUp ? HugeIcons.strokeRoundedChartAverage : HugeIcons.strokeRoundedTrendingDown;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: trendColor.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TIcon.raw(trendIcon, size: 10, color: trendColor),
          const SizedBox(width: 2),
          Text(
            trend!,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: trendColor),
          ),
        ],
      ),
    );
  }
}
