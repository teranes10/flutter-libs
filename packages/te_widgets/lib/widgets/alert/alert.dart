import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A button configuration for alert dialogs.
///
/// Used to define action buttons in [TAlert] dialogs.
class AlertButton {
  /// The text to display on the button.
  final String? text;

  /// The icon to display on the button.
  final IconData? icon;

  /// Callback fired when the button is clicked.
  final VoidCallback? onClick;

  /// Creates an alert button configuration.
  AlertButton({this.text, this.icon, this.onClick});
}

/// A customizable alert dialog with title, content, and action buttons.
///
/// `TAlert` provides a Material Design alert dialog with:
/// - Optional title and icon
/// - Flexible content (String or Widget)
/// - Close and confirm action buttons
/// - Custom theming and colors
///
/// ## Basic Usage
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => TAlert(
///     title: 'Confirm Action',
///     text: 'Are you sure you want to proceed?',
///     icon: Icons.warning,
///     color: AppColors.warning,
///     closeButton: AlertButton(
///       text: 'Cancel',
///       onClick: () => Navigator.pop(context),
///     ),
///     confirmButton: AlertButton(
///       text: 'Confirm',
///       onClick: () {
///         // Perform action
///         Navigator.pop(context);
///       },
///     ),
///   ),
/// );
/// ```
///
/// ## Simple Alert
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => TAlert(
///     title: 'Success',
///     text: 'Operation completed successfully!',
///     icon: Icons.check_circle,
///     color: AppColors.success,
///     closeButton: AlertButton(
///       text: 'OK',
///       onClick: () => Navigator.pop(context),
///     ),
///   ),
/// );
/// ```
///
/// See also:
/// - [AlertButton] for button configuration
/// - [TAlertTheme] for customizing appearance
class TAlert extends StatelessWidget {
  /// The content text or widget to display.
  ///
  /// Can be either a String or a Widget.
  final dynamic text;

  /// The title of the alert dialog.
  final String? title;

  /// The icon to display at the top of the dialog.
  final IconData? icon;

  /// The primary color for the alert and confirm button.
  final Color? color;

  /// Configuration for the close/cancel button.
  final AlertButton? closeButton;

  /// Configuration for the confirm/action button.
  final AlertButton? confirmButton;

  /// Custom theme for the alert dialog.
  final TAlertTheme? theme;

  /// Creates an alert dialog.
  const TAlert({
    super.key,
    this.title,
    this.text,
    this.icon,
    this.closeButton,
    this.confirmButton,
    this.color,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final wTheme = theme ?? context.theme.alertTheme;

    return IntrinsicHeight(
      child: AlertDialog(
        backgroundColor: colors.surface,
        insetPadding: wTheme.insetPadding,
        contentPadding: wTheme.contentPadding,
        actionsPadding: wTheme.actionsPadding,
        actionsAlignment: wTheme.actionsAlignment,
        icon: icon != null ? Icon(icon, size: wTheme.iconSize, color: color) : null,
        title: title != null ? Text(title!, style: wTheme.titleStyle) : null,
        content:
            text is String ? Text(text, textAlign: wTheme.contentTextAlign, style: wTheme.contentStyle) : (text is Widget ? text : null),
        actions: [
          if (closeButton != null)
            TButton(
              size: TButtonSize.md.copyWith(minW: wTheme.closeButtonWidth),
              type: wTheme.closeButtonType,
              color: confirmButton != null ? wTheme.closeButtonColor : color,
              icon: closeButton!.icon,
              text: closeButton!.text,
              onPressed: (_) => closeButton!.onClick?.call(),
            ),
          if (confirmButton != null)
            TButton(
              size: TButtonSize.md.copyWith(minW: wTheme.confirmButtonWidth),
              type: wTheme.confirmButtonType,
              color: color,
              icon: confirmButton!.icon,
              text: confirmButton!.text,
              onPressed: (_) => confirmButton!.onClick?.call(),
            ),
        ],
      ),
    );
  }
}
