import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Service for displaying alert dialogs.
///
/// `TAlertService` provides static methods to show varying types of alerts:
/// - Info, Success, Warning, Error
/// - Confirmations (Archive, Restore, Delete)
/// - Custom alerts with [show]
/// Controller for managing alert dialogs programmatically.
class TAlertController {
  VoidCallback? _close;

  /// Closes the alert dialog if it is currently showing.
  void close() {
    _close?.call();
  }
}

class TAlertService {
  /// Shows a custom alert dialog.
  static TAlertController show(
    BuildContext context, {
    final dynamic text,
    final String? title,
    final IconData? icon,
    final Color? color,
    final AlertButton? closeButton,
    final AlertButton? confirmButton,
    final bool progress = false,
    final Stream<String>? progressStream,
    final bool hideCloseButton = false,
    final double? width,
    final double? minWidth = 0,
    final double? minHeight = 0,
    final bool persistent = true,
  }) {
    final controller = TAlertController();

    TModalService.show(context, width: width ?? 400, minWidth: minWidth, minHeight: minHeight, persistent: persistent, (modalContext) {
      controller._close = modalContext.close;
      return TAlert(
        title: title,
        text: text,
        icon: icon,
        color: color,
        progress: progress,
        progressStream: progressStream,
        confirmButton: confirmButton != null
            ? AlertButton(
                text: confirmButton.text,
                icon: confirmButton.icon,
                onClick: () {
                  modalContext.close();
                  confirmButton.onClick?.call();
                },
              )
            : null,
        closeButton: hideCloseButton
            ? null
            : AlertButton(
                text: closeButton?.text ?? (confirmButton != null ? 'Cancel' : 'OK'),
                icon: closeButton?.icon,
                onClick: () {
                  modalContext.close();
                  closeButton?.onClick?.call();
                },
              ),
      );
    });

    return controller;
  }

  /// Shows an informational alert.
  static void info(BuildContext context, String title, String message) {
    show(context, title: title, text: message, icon: Icons.info_outline_rounded, color: context.theme.info);
  }

  /// Shows a success alert.
  static void success(BuildContext context, String title, String message) {
    show(context, title: title, text: message, icon: Icons.check_circle_outline_rounded, color: context.theme.success);
  }

  /// Shows a warning alert.
  static void warning(BuildContext context, String title, String message) {
    show(context, title: title, text: message, icon: Icons.warning_amber_rounded, color: context.theme.warning);
  }

  /// Shows an error alert.
  static void error(BuildContext context, String title, String message) {
    show(context, title: title, text: message, icon: Icons.error_outline_rounded, color: context.theme.danger);
  }

  /// Shows a progress alert.
  static TAlertController progress(BuildContext context, String title, String message, {Stream<String>? progressStream}) {
    return show(
      context,
      title: title,
      text: message,
      progress: true,
      progressStream: progressStream,
      hideCloseButton: true,
      color: context.theme.info,
      minHeight: 0,
      minWidth: 0,
    );
  }

  /// Shows a confirmation dialog for archiving an item.
  static void confirmArchive(BuildContext context, VoidCallback onConfirm, {String? name}) {
    final msg = name != null
        ? Text.rich(TextSpan(
            style: TextStyle(fontSize: 14),
            text: 'Do you really want to archive ',
            children: [TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)), const TextSpan(text: '?')],
          ))
        : 'Do you really want to archive this item?';

    show(context,
        title: 'Are you sure?',
        text: msg,
        icon: Icons.archive_rounded,
        color: context.theme.danger,
        confirmButton: AlertButton(text: 'Archive', onClick: onConfirm));
  }

  /// Shows a confirmation dialog for restoring an item.
  static void confirmRestore(BuildContext context, VoidCallback onConfirm, {String? name}) {
    final msg = name != null
        ? Text.rich(TextSpan(
            style: TextStyle(fontSize: 14),
            text: 'Do you really want to restore ',
            children: [TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)), const TextSpan(text: '?')],
          ))
        : 'Do you really want to restore this item?';

    show(context,
        title: 'Are you sure?',
        text: msg,
        icon: Icons.unarchive_rounded,
        color: context.theme.info,
        confirmButton: AlertButton(text: 'Restore', onClick: onConfirm));
  }

  /// Shows a confirmation dialog for deleting an item.
  static void confirmDelete(BuildContext context, VoidCallback onConfirm, {String? name}) {
    final msg = name != null
        ? Text.rich(TextSpan(
            style: TextStyle(fontSize: 14),
            text: 'Do you really want to delete ',
            children: [TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)), const TextSpan(text: '?')],
          ))
        : 'Do you really want to delete this item?';

    show(context,
        title: 'Are you sure?',
        text: msg,
        icon: Icons.delete_forever_rounded,
        color: context.theme.danger,
        confirmButton: AlertButton(text: 'Delete', onClick: onConfirm));
  }
}
