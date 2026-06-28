import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A service for displaying snackbar notifications.
///
/// `TSnackbarService` provides snackbar messages with:
/// - Success, info, warning, and error variants
/// - Customizable action text and [onTap] callback
/// - Custom styling based on the current theme or variant
/// - Automatic support for mobile and desktop sizing/spacing
///
/// ## Basic Usage
///
/// ```dart
/// TSnackbarService.success(context, 'Changes saved successfully');
/// TSnackbarService.error(context, 'Failed to connect to server');
/// ```
///
/// ## With Action
///
/// ```dart
/// TSnackbarService.info(
///   context,
///   'Message archived',
///   actionText: 'Undo',
///   onTap: () {
///     // Perform undo operation
///   },
/// );
/// ```
///
/// ## Custom Snackbar
///
/// ```dart
/// TSnackbarService.show(
///   context,
///   'Custom notification text',
///   title: 'Custom Title',
///   icon: Icons.star,
///   color: Colors.purple,
///   duration: Duration(seconds: 5),
///   actionText: 'Retry',
///   onTap: () => print('Retry tapped'),
/// )
/// ```
class TSnackbarService {
  /// Shows a custom snackbar notification.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    String? title,
    IconData? icon,
    Duration? duration,
    Color? color,
    TVariant? type,
    String? actionText,
    VoidCallback? onTap,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    double? elevation,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    bool showCloseBtn = false,
    Alignment? alignment,
    double? maxWidth,
  }) {
    final theme = context.theme;
    final mType = type ?? theme.snackbarType;
    final wTheme = color != null ? context.getWidgetTheme(mType, color) : TWidgetTheme.surfaceTheme(context.colors, variant: mType);
    final isMobile = context.isMobile;
    final resolvedAlignment = alignment ?? Alignment.bottomCenter;

    // Dismiss any active snackbars before displaying a new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final defaultBorderRadius = BorderRadius.circular(8);
    final effectiveShape = shape ??
        RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
          side: BorderSide(color: wTheme.outline ?? context.colors.outlineVariant),
        );

    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: behavior,
      duration: duration ?? const Duration(seconds: 4),
      margin: behavior == SnackBarBehavior.floating
          ? (margin ?? (isMobile ? const EdgeInsets.all(12) : const EdgeInsets.symmetric(horizontal: 40, vertical: 24)))
          : null,
      padding: EdgeInsets.zero,
      shape: shape,
      content: Align(
        alignment: resolvedAlignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.isMobile ? double.infinity : maxWidth ?? 480),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: defaultBorderRadius,
              boxShadow: wTheme.shadow != null
                  ? [BoxShadow(color: wTheme.shadow!, blurRadius: 12, spreadRadius: 2)]
                  : [BoxShadow(color: context.colors.shadow, offset: const Offset(0, 1), blurRadius: 0, spreadRadius: 0)],
            ),
            child: Material(
              elevation: elevation ?? 6,
              color: wTheme.container,
              shadowColor: wTheme.shadow ?? context.colors.shadow,
              shape: effectiveShape,
              child: Padding(
                padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: title != null ? 10 : 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: wTheme.onContainer, size: 20),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null) ...[
                            Text(
                              title,
                              style: TextStyle(color: wTheme.onContainer, fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            message,
                            style: TextStyle(color: wTheme.onContainer, fontWeight: FontWeight.w400, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (actionText != null && onTap != null) ...[
                      const SizedBox(width: 12),
                      TButton(
                        type: TButtonType.text,
                        size: TButtonSize.xs,
                        color: wTheme.onContainer,
                        text: actionText,
                        onTap: onTap,
                      ),
                    ],
                    if (showCloseBtn) const SizedBox(width: 8),
                    if (showCloseBtn)
                      TButton(
                        type: TButtonType.text,
                        size: TButtonSize.xxs,
                        icon: Icons.close_rounded,
                        color: wTheme.onContainer,
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shows a success snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> success(
    BuildContext context,
    String message, {
    String? title,
    String? actionText,
    VoidCallback? onTap,
    Duration? duration,
  }) {
    return show(
      context,
      message,
      title: title,
      icon: Icons.check_circle_outline_rounded,
      color: context.theme.success,
      actionText: actionText,
      onTap: onTap,
      duration: duration,
    );
  }

  /// Shows an info snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> info(
    BuildContext context,
    String message, {
    String? title,
    String? actionText,
    VoidCallback? onTap,
    Duration? duration,
  }) {
    return show(
      context,
      message,
      title: title,
      icon: Icons.info_outline_rounded,
      color: context.theme.info,
      actionText: actionText,
      onTap: onTap,
      duration: duration,
    );
  }

  /// Shows a warning snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> warning(
    BuildContext context,
    String message, {
    String? title,
    String? actionText,
    VoidCallback? onTap,
    Duration? duration,
  }) {
    return show(
      context,
      message,
      title: title,
      icon: Icons.warning_amber_rounded,
      color: context.theme.warning,
      actionText: actionText,
      onTap: onTap,
      duration: duration,
    );
  }

  /// Shows an error/danger snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> error(
    BuildContext context,
    String message, {
    String? title,
    String? actionText,
    VoidCallback? onTap,
    Duration? duration,
  }) {
    return show(
      context,
      message,
      title: title,
      icon: Icons.error_outline_rounded,
      color: context.theme.danger,
      actionText: actionText,
      onTap: onTap,
      duration: duration,
    );
  }
}
