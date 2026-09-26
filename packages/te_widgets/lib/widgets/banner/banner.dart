import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Defines the semantic intent of a [TBanner].
enum TBannerType {
  info,
  success,
  warning,
  error,
  neutral;

  /// Default icon corresponding to the banner semantic type.
  IconData get defaultIcon => switch (this) {
        info => Icons.info_outline_rounded,
        success => Icons.check_circle_outline_rounded,
        warning => Icons.warning_amber_rounded,
        error => Icons.error_outline_rounded,
        neutral => Icons.notifications_none_rounded,
      };

  /// Resolves the semantic color from the current context.
  Color getColor(BuildContext context) {
    final colors = context.colors;
    final theme = context.themeOrNull;
    return switch (this) {
      info => theme?.info ?? AppColors.info,
      success => theme?.success ?? AppColors.success,
      warning => theme?.warning ?? AppColors.warning,
      error => colors.error,
      neutral => colors.onSurfaceVariant,
    };
  }
}

/// A non-modal in-page contextual alert banner or callout widget.
///
/// `TBanner` displays informational, warning, success, or error messages directly
/// inside pages, forms, cards, or tables.
///
/// ## Named Constructors
/// - [TBanner.info] — Informational callout (blue).
/// - [TBanner.success] — Success notification (green).
/// - [TBanner.warning] — Warning callout (amber/orange).
/// - [TBanner.error] — Error or critical alert (red).
/// - [TBanner.neutral] — Neutral status notice (grey/surface).
///
/// ## Basic Usage
///
/// ```dart
/// // Simple info banner
/// TBanner.info(
///   message: 'A new software update is available for your system.',
/// )
///
/// // Rich banner with title, action, and dismiss button
/// TBanner.warning(
///   title: 'Storage Limit Warning',
///   message: 'You have used 85% of your available cloud storage.',
///   action: TButton(
///     text: 'Upgrade Plan',
///     type: TButtonType.tonal,
///     size: TButtonSize.xs,
///     onTap: () => openUpgrade(),
///   ),
///   onDismiss: () => dismissWarning(),
/// )
/// ```
class TBanner extends StatelessWidget {
  /// The semantic type of the banner.
  final TBannerType type;

  /// Optional bold heading title.
  final String? title;

  /// Primary message text.
  final String? message;

  /// Custom rich child widget replacing [message].
  final Widget? child;

  /// Custom icon replacing the type's [TBannerType.defaultIcon].
  /// Supports [IconData], HugeIcon, or a custom [Widget]. Set to `null` with [showIcon: false] to hide.
  final dynamic icon;

  /// Whether to display the leading icon. Defaults to true.
  final bool showIcon;

  /// Visual styling variant. Defaults to [TVariant.tonal].
  final TVariant variant;

  /// Custom color override for the banner.
  final Color? color;

  /// Primary action widget (typically a [TButton] or action link).
  final Widget? action;

  /// Dismiss callback. When provided, renders a close icon button on the top right.
  final VoidCallback? onDismiss;

  /// Padding inside the banner.
  final EdgeInsetsGeometry padding;

  /// Margin around the banner.
  final EdgeInsetsGeometry? margin;

  /// Border radius of the banner.
  final BorderRadius? borderRadius;

  /// Whether to render an explicit border.
  final bool bordered;

  /// Creates a banner widget.
  const TBanner({
    super.key,
    this.type = TBannerType.info,
    this.title,
    this.message,
    this.child,
    this.icon,
    this.showIcon = true,
    this.variant = TVariant.tonal,
    this.color,
    this.action,
    this.onDismiss,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
    this.margin = const EdgeInsets.only(bottom: 12.0),
    this.borderRadius,
    this.bordered = true,
  });

  /// Creates an informational banner.
  const TBanner.info({
    super.key,
    this.title,
    this.message,
    this.child,
    this.icon,
    this.showIcon = true,
    this.variant = TVariant.tonal,
    this.color,
    this.action,
    this.onDismiss,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
    this.margin = const EdgeInsets.only(bottom: 12.0),
    this.borderRadius,
    this.bordered = true,
  }) : type = TBannerType.info;

  /// Creates a success banner.
  const TBanner.success({
    super.key,
    this.title,
    this.message,
    this.child,
    this.icon,
    this.showIcon = true,
    this.variant = TVariant.tonal,
    this.color,
    this.action,
    this.onDismiss,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
    this.margin = const EdgeInsets.only(bottom: 12.0),
    this.borderRadius,
    this.bordered = true,
  }) : type = TBannerType.success;

  /// Creates a warning banner.
  const TBanner.warning({
    super.key,
    this.title,
    this.message,
    this.child,
    this.icon,
    this.showIcon = true,
    this.variant = TVariant.tonal,
    this.color,
    this.action,
    this.onDismiss,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
    this.margin = const EdgeInsets.only(bottom: 12.0),
    this.borderRadius,
    this.bordered = true,
  }) : type = TBannerType.warning;

  /// Creates an error banner.
  const TBanner.error({
    super.key,
    this.title,
    this.message,
    this.child,
    this.icon,
    this.showIcon = true,
    this.variant = TVariant.tonal,
    this.color,
    this.action,
    this.onDismiss,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
    this.margin = const EdgeInsets.only(bottom: 12.0),
    this.borderRadius,
    this.bordered = true,
  }) : type = TBannerType.error;

  /// Creates a neutral status banner.
  const TBanner.neutral({
    super.key,
    this.title,
    this.message,
    this.child,
    this.icon,
    this.showIcon = true,
    this.variant = TVariant.tonal,
    this.color,
    this.action,
    this.onDismiss,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
    this.margin = const EdgeInsets.only(bottom: 12.0),
    this.borderRadius,
    this.bordered = true,
  }) : type = TBannerType.neutral;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = color ?? type.getColor(context);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(8.0);

    // Compute surface background and border colors based on variant
    final Color backgroundColor;
    final Color? borderColor;
    final Color textColor;
    final Color iconColor;

    switch (variant) {
      case TVariant.solid:
        backgroundColor = primaryColor;
        borderColor = null;
        textColor = Colors.white;
        iconColor = Colors.white;
      case TVariant.outline:
        backgroundColor = Colors.transparent;
        borderColor = primaryColor.withValues(alpha: isDark ? 0.6 : 0.8);
        textColor = colors.onSurface;
        iconColor = primaryColor;
      case TVariant.softOutline:
        backgroundColor = primaryColor.withValues(alpha: isDark ? 0.08 : 0.05);
        borderColor = primaryColor.withValues(alpha: isDark ? 0.4 : 0.35);
        textColor = colors.onSurface;
        iconColor = primaryColor;
      case TVariant.tonal:
      default:
        backgroundColor = primaryColor.withValues(alpha: isDark ? 0.15 : 0.10);
        borderColor = bordered ? primaryColor.withValues(alpha: isDark ? 0.35 : 0.25) : null;
        textColor = isDark ? colors.onSurface : Color.lerp(primaryColor, Colors.black, 0.45) ?? primaryColor;
        iconColor = primaryColor;
    }

    final effectiveIcon = icon ?? type.defaultIcon;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveRadius,
        border: borderColor != null ? Border.all(color: borderColor, width: 1.0) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon && effectiveIcon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: TIcon.raw(
                effectiveIcon,
                size: 18.0,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 10.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (message != null || child != null) const SizedBox(height: 3.0),
                ],
                if (message != null)
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: textColor.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                if (child != null) child!,
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: action!,
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 6.0),
            IconButton(
              icon: Icon(Icons.close_rounded, size: 16.0, color: textColor.withValues(alpha: 0.7)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24.0, minHeight: 24.0),
              splashRadius: 16.0,
              onPressed: onDismiss,
              tooltip: 'Dismiss',
            ),
          ],
        ],
      ),
    );
  }
}
