import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/app_colors.dart';
import 'package:te_widgets/extensions/build_context_x.dart';
import 'package:te_widgets/widgets/icon/icon.dart';

/// Semantic outcome status for [TResult].
enum TResultStatus {
  success,
  error,
  warning,
  info,
  forbidden,
  notFound,
  serverError,
}

/// An operation result / status presentation widget.
///
/// Used to communicate the outcome of a significant user workflow (e.g. checkout success,
/// 403 forbidden access, 404 not found, or 500 internal server failure).
/// Can be displayed standalone as a full screen, or embedded inside cards and modal sheets.
class TResult extends StatelessWidget {
  /// Primary outcome title.
  final String? title;

  /// Custom title widget override.
  final Widget? titleWidget;

  /// Explanatory subtitle or guidance text.
  final String? subtitle;

  /// Custom subtitle widget override.
  final Widget? subtitleWidget;

  /// Outcome status.
  final TResultStatus status;

  /// Leading icon override (defaults to status-based semantic icon).
  final dynamic icon;

  /// Custom color override for the result icon.
  final Color? iconColor;

  /// Size of the status icon. Defaults to 64.0.
  final double iconSize;

  /// Primary call-to-action (e.g. "Go to Dashboard", "Try Again").
  final Widget? primaryAction;

  /// Secondary call-to-action (e.g. "View Order", "Contact Support").
  final Widget? secondaryAction;

  /// Extra structured information widget (e.g. receipt card, stack trace).
  final Widget? extra;

  /// Whether this result occupies the full page (centers with expanded padding).
  final bool fullPage;

  /// Padding around the result widget.
  final EdgeInsetsGeometry padding;

  const TResult({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.status = TResultStatus.info,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.primaryAction,
    this.secondaryAction,
    this.extra,
    this.fullPage = false,
    this.padding = const EdgeInsets.all(32.0),
  });

  /// Success outcome preset (green checkmark).
  const TResult.success({
    super.key,
    this.title = 'Successfully Completed',
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.primaryAction,
    this.secondaryAction,
    this.extra,
    this.fullPage = false,
    this.padding = const EdgeInsets.all(32.0),
  }) : status = TResultStatus.success;

  /// Generic error outcome preset (red alert icon).
  const TResult.error({
    super.key,
    this.title = 'Operation Failed',
    this.titleWidget,
    this.subtitle = 'Please check your input parameters and try again.',
    this.subtitleWidget,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.primaryAction,
    this.secondaryAction,
    this.extra,
    this.fullPage = false,
    this.padding = const EdgeInsets.all(32.0),
  }) : status = TResultStatus.error;

  /// Warning outcome preset (amber warning triangle).
  const TResult.warning({
    super.key,
    this.title = 'Warning',
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.primaryAction,
    this.secondaryAction,
    this.extra,
    this.fullPage = false,
    this.padding = const EdgeInsets.all(32.0),
  }) : status = TResultStatus.warning;

  /// Informational outcome preset (blue info circle).
  const TResult.info({
    super.key,
    this.title = 'Notice',
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.primaryAction,
    this.secondaryAction,
    this.extra,
    this.fullPage = false,
    this.padding = const EdgeInsets.all(32.0),
  }) : status = TResultStatus.info;

  /// 403 Forbidden preset (security shield lock).
  const TResult.forbidden({
    super.key,
    this.title = '403 Forbidden',
    this.titleWidget,
    this.subtitle = 'Sorry, you do not have permission to access this resource.',
    this.subtitleWidget,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.primaryAction,
    this.secondaryAction,
    this.extra,
    this.fullPage = false,
    this.padding = const EdgeInsets.all(32.0),
  }) : status = TResultStatus.forbidden;

  /// 404 Not Found preset (missing route/entity search).
  const TResult.notFound({
    super.key,
    this.title = '404 Not Found',
    this.titleWidget,
    this.subtitle = 'Sorry, the requested page or data record does not exist.',
    this.subtitleWidget,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.primaryAction,
    this.secondaryAction,
    this.extra,
    this.fullPage = false,
    this.padding = const EdgeInsets.all(32.0),
  }) : status = TResultStatus.notFound;

  /// 500 Internal Server Error preset (cloud error breakdown).
  const TResult.serverError({
    super.key,
    this.title = '500 Server Error',
    this.titleWidget,
    this.subtitle = 'Internal system error occurred. Our engineering team has been notified.',
    this.subtitleWidget,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.primaryAction,
    this.secondaryAction,
    this.extra,
    this.fullPage = false,
    this.padding = const EdgeInsets.all(32.0),
  }) : status = TResultStatus.serverError;

  (dynamic, Color, Color) _resolveStatusVisuals(BuildContext context) {
    final colors = context.colors;
    final theme = context.themeOrNull;
    final successColor = theme?.success ?? AppColors.success;
    final dangerColor = theme?.danger ?? AppColors.danger;
    final primaryColor = colors.primary;
    final warningColor = Colors.amber.shade700;

    return switch (status) {
      TResultStatus.success => (
          icon ?? Icons.check_circle_rounded,
          iconColor ?? successColor,
          (iconColor ?? successColor).withValues(alpha: 0.12),
        ),
      TResultStatus.error => (
          icon ?? Icons.cancel_rounded,
          iconColor ?? dangerColor,
          (iconColor ?? dangerColor).withValues(alpha: 0.12),
        ),
      TResultStatus.warning => (
          icon ?? Icons.warning_rounded,
          iconColor ?? warningColor,
          (iconColor ?? warningColor).withValues(alpha: 0.12),
        ),
      TResultStatus.info => (
          icon ?? Icons.info_rounded,
          iconColor ?? primaryColor,
          (iconColor ?? primaryColor).withValues(alpha: 0.12),
        ),
      TResultStatus.forbidden => (
          icon ?? Icons.gpp_bad_rounded,
          iconColor ?? Colors.deepOrange,
          (iconColor ?? Colors.deepOrange).withValues(alpha: 0.12),
        ),
      TResultStatus.notFound => (
          icon ?? Icons.explore_off_rounded,
          iconColor ?? colors.onSurfaceVariant,
          colors.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
      TResultStatus.serverError => (
          icon ?? Icons.cloud_off_rounded,
          iconColor ?? dangerColor,
          (iconColor ?? dangerColor).withValues(alpha: 0.12),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (resolvedIcon, effectiveColor, effectiveBg) = _resolveStatusVisuals(context);

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large Semantic Icon with Subtle Glow Background
              Container(
                width: iconSize * 1.5,
                height: iconSize * 1.5,
                decoration: BoxDecoration(
                  color: effectiveBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: TIcon(
                  icon: resolvedIcon,
                  size: iconSize,
                  color: effectiveColor,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              if (titleWidget != null)
                titleWidget!
              else if (title != null)
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

              // Subtitle
              if (subtitleWidget != null) ...[
                const SizedBox(height: 8),
                subtitleWidget!,
              ] else if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Extra Details Widget (e.g. receipt, stack trace, status badges)
              if (extra != null) ...[
                const SizedBox(height: 24),
                extra!,
              ],

              // Actions Row
              if (primaryAction != null || secondaryAction != null) ...[
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (secondaryAction != null) secondaryAction!,
                    if (primaryAction != null) primaryAction!,
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (fullPage) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(child: SingleChildScrollView(child: content)),
      );
    }

    return content;
  }
}
