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
///   icon: Icons.inventory_2_rounded,
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
///   icon: Icons.monetization_on_rounded,
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
  final IconData? icon;

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

  /// Visual variant type (e.g. [TVariant.tonal], [TVariant.outline], [TVariant.solid]).
  final TVariant type;

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
    this.type = TVariant.tonal,
    this.compact = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accentColor = color ?? colors.primary;
    final radius = borderRadius ?? BorderRadius.circular(10);
    final effectivePadding = padding ??
        (compact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 12));

    final effectiveBgColor = backgroundColor ?? colors.surfaceContainerLow;
    final effectiveBorderColor = borderColor ?? colors.outlineVariant.withAlpha(60);

    Widget content = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: radius,
        border: Border.all(color: effectiveBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container
          if (iconWidget != null || icon != null) ...[
            Container(
              padding: EdgeInsets.all(compact ? 6 : 8),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: iconWidget ??
                  Icon(
                    icon,
                    color: accentColor,
                    size: compact ? 16 : 20,
                  ),
            ),
            SizedBox(width: compact ? 8 : 12),
          ],

          // Label, Value & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: labelStyle ??
                            TextStyle(
                              fontSize: compact ? 10 : 11,
                              fontWeight: FontWeight.w500,
                              color: colors.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 4),
                      badge!,
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: valueStyle ??
                            TextStyle(
                              fontSize: compact ? 13 : 15,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trend != null) ...[
                      const SizedBox(width: 6),
                      _buildTrendBadge(context),
                    ],
                  ],
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: subtitleStyle ??
                        TextStyle(
                          fontSize: compact ? 9 : 10,
                          color: colors.onSurfaceVariant.withAlpha(180),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Trailing Action / Chevron
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: compact ? 16 : 18,
              color: colors.onSurfaceVariant.withAlpha(140),
            ),
          ],
        ],
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
      content = Tooltip(
        message: tooltip!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildTrendBadge(BuildContext context) {
    final isUp = trendUp ?? true;
    final trendColor = isUp ? AppColors.success : AppColors.danger;
    final trendIcon = isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: trendColor.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, size: 10, color: trendColor),
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
