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
  dynamic get defaultIcon => switch (this) {
        info => HugeIcons.strokeRoundedInformationCircle,
        success => HugeIcons.strokeRoundedCheckmarkCircle01,
        warning => HugeIcons.strokeRoundedAlert02,
        error => HugeIcons.strokeRoundedAlertCircle,
        neutral => HugeIcons.strokeRoundedNotification01,
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

  /// Custom size for the leading icon.
  /// Defaults to 20.0 when [title] is present, or 18.0 for message-only callouts.
  final double? iconSize;

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
    this.iconSize,
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

  /// Creates a connectivity / sync-status banner for offline-capable apps.
  ///
  /// Renders nothing when everything is synced (`online`, not [syncing], no
  /// [pendingCount] and no [error]). Otherwise shows, in priority order:
  /// a sync failure with a Retry action, a syncing progress notice, an
  /// "offline" notice (with the pending count and [lastSync]), or a
  /// "changes waiting to sync" notice with a Sync now action.
  ///
  /// Set [sticky] to dock it flush to the top/bottom edge of a screen.
  static Widget offline({
    Key? key,
    bool online = false,
    bool syncing = false,
    int pendingCount = 0,
    DateTime? lastSync,
    String? error,
    VoidCallback? onRetry,
    VoidCallback? onViewPending,
    bool sticky = false,
    dynamic icon,
    double? iconSize,
  }) {
    final isSynced = online && !syncing && pendingCount == 0 && error == null;
    if (isSynced) return const SizedBox.shrink();

    final actionSize = TSize.lg.copyWith(minH: 48);
    final pending = pendingCount > 0 ? '$pendingCount pending' : null;
    final last = lastSync != null ? 'Last sync ${lastSync.formatAgo()}' : null;
    final details = [if (pending != null) pending, if (last != null) last].join(' · ');

    final TBannerType type;
    final String title;
    final String? message;
    Widget? action;
    dynamic resolvedIcon;
    final effectiveIconSize = iconSize ?? 20.0;

    if (error != null) {
      type = TBannerType.error;
      title = 'Sync failed';
      message = error;
      action = onRetry == null ? null : TButton(text: 'Retry', type: TButtonType.tonal, size: actionSize, onTap: onRetry);
      resolvedIcon = icon ?? HugeIcons.strokeRoundedAlertCircle;
    } else if (syncing) {
      type = TBannerType.info;
      title = pendingCount > 0 ? 'Syncing $pendingCount changes…' : 'Syncing…';
      message = null;
      resolvedIcon = icon ??
          SizedBox(
            width: effectiveIconSize,
            height: effectiveIconSize,
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          );
    } else if (!online) {
      type = TBannerType.warning;
      title = "You're offline";
      message = details.isEmpty
          ? 'Tasks and scans are saved on this device and sync when you are back online.'
          : 'Saved on this device and synced when back online. $details';
      action = onViewPending == null || pendingCount == 0
          ? null
          : TButton(text: 'View pending', type: TButtonType.tonal, size: actionSize, onTap: onViewPending);
      resolvedIcon = icon ?? HugeIcons.strokeRoundedCloudOff;
    } else {
      type = TBannerType.info;
      title = '$pendingCount changes waiting to sync';
      message = last;
      action = onRetry == null ? null : TButton(text: 'Sync now', type: TButtonType.tonal, size: actionSize, onTap: onRetry);
      resolvedIcon = icon ?? HugeIcons.strokeRoundedCloudUpload;
    }

    return TBanner(
      key: key,
      type: type,
      title: title,
      message: message,
      icon: resolvedIcon,
      iconSize: effectiveIconSize,
      action: action,
      margin: sticky ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12.0),
      borderRadius: sticky ? BorderRadius.zero : null,
      bordered: !sticky,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }

  /// Creates an informational banner.
  const TBanner.info({
    super.key,
    this.title,
    this.message,
    this.child,
    this.icon,
    this.iconSize,
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
    this.iconSize,
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
    this.iconSize,
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
    this.iconSize,
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
    this.iconSize,
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
    final double effectiveIconSize = iconSize ?? (title != null ? 20.0 : 18.0);
    final double firstLineHeight = title != null ? 20.0 : 18.0;

    final Widget iconWidget = icon is Widget && icon is! IconData
        ? (icon as Widget)
        : TIcon.raw(
            effectiveIcon,
            size: effectiveIconSize,
            color: iconColor,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        // On narrow (phone) widths an inline action starves the text of
        // width, so the action drops under the text instead.
        final stackAction = action != null && constraints.maxWidth < 480;

        final messageStyle = TextStyle(
          fontSize: 12.5,
          color: textColor.withValues(alpha: 0.9),
          height: 1.35,
        );

        bool isSingleLineMessage = false;
        if (title != null && message != null) {
          if (!message!.contains('\n')) {
            if (!constraints.hasBoundedWidth) {
              isSingleLineMessage = true;
            } else {
              final double iconSpace = (showIcon && effectiveIcon != null) ? (effectiveIconSize + 8.0) : 0.0;
              final EdgeInsets resolvedPadding = padding.resolve(Directionality.maybeOf(context) ?? TextDirection.ltr);
              final double paddingSpace = resolvedPadding.left + resolvedPadding.right;
              final double dismissSpace = (onDismiss != null) ? (20.0 + 6.0) : 0.0;
              final double actionSpace = (action != null && !stackAction) ? 100.0 : 0.0;
              final double availableWidthUnderTitle = constraints.maxWidth - paddingSpace - iconSpace - dismissSpace - actionSpace;

              if (availableWidthUnderTitle > 0) {
                final textScaler = MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;
                final textPainter = TextPainter(
                  text: TextSpan(text: message!, style: messageStyle),
                  textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
                  textScaler: textScaler,
                  maxLines: 1,
                )..layout(maxWidth: availableWidthUnderTitle);

                isSingleLineMessage = !textPainter.didExceedMaxLines;
              }
            }
          }
        }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      if (isSingleLineMessage) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showIcon && effectiveIcon != null) ...[
                              SizedBox(
                                height: firstLineHeight,
                                width: effectiveIconSize,
                                child: Center(child: iconWidget),
                              ),
                              const SizedBox(width: 8.0),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title!,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    message!,
                                    style: messageStyle,
                                  ),
                                  if (child != null) ...[
                                    const SizedBox(height: 4.0),
                                    child!,
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (showIcon && effectiveIcon != null) ...[
                              SizedBox(
                                height: firstLineHeight,
                                width: effectiveIconSize,
                                child: Center(child: iconWidget),
                              ),
                              const SizedBox(width: 8.0),
                            ],
                            Expanded(
                              child: Text(
                                title!,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (message != null || child != null) const SizedBox(height: 4.0),
                        if (message != null)
                          Text(
                            message!,
                            style: messageStyle,
                          ),
                        if (child != null) child!,
                      ],
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showIcon && effectiveIcon != null) ...[
                            SizedBox(
                              height: firstLineHeight,
                              width: effectiveIconSize,
                              child: Center(child: iconWidget),
                            ),
                            const SizedBox(width: 8.0),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (message != null)
                                  Text(
                                    message!,
                                    style: messageStyle,
                                  ),
                                if (child != null) child!,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (stackAction) ...[
                      const SizedBox(height: 10.0),
                      Align(alignment: Alignment.centerLeft, child: action!),
                    ],
                  ],
                ),
              ),
              if (action != null && !stackAction) ...[
                const SizedBox(width: 10.0),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: action!,
                ),
              ],
              if (onDismiss != null) ...[
                const SizedBox(width: 6.0),
                SizedBox(
                  height: firstLineHeight,
                  child: Center(
                    child: IconButton(
                      icon: TIcon.raw(HugeIcons.strokeRoundedCancel01, size: 16.0, color: textColor.withValues(alpha: 0.7)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 20.0, minHeight: 20.0),
                      splashRadius: 16.0,
                      onPressed: onDismiss,
                      tooltip: 'Dismiss',
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
