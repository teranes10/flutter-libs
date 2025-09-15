import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TAlertService {
  static Future<void> show(
    BuildContext context, {
    final dynamic text,
    final String? title,
    final IconData? icon,
    final Color? color,
    final AlertButton? closeButton,
    final AlertButton? confirmButton,
  }) async {
    TModalService.show(context, (context) {
      return TAlert(
        title: title,
        text: text,
        icon: icon,
        color: color,
        confirmButton: confirmButton != null
            ? AlertButton(
                text: confirmButton.text,
                icon: confirmButton.icon,
                onClick: () {
                  context.close();
                  confirmButton.onClick?.call();
                },
              )
            : null,
        closeButton: AlertButton(
          text: closeButton?.text ?? (confirmButton != null ? 'Cancel' : 'OK'),
          icon: closeButton?.icon,
          onClick: () {
            context.close();
            closeButton?.onClick?.call();
          },
        ),
      );
    });
  }

  static void info(BuildContext context, String title, String message) {
    show(context, title: title, text: message, icon: Icons.info_outline_rounded, color: context.theme.info);
  }

  static void success(BuildContext context, String title, String message) {
    show(context, title: title, text: message, icon: Icons.check_circle_outline_rounded, color: context.theme.success);
  }

  static void warning(BuildContext context, String title, String message) {
    show(context, title: title, text: message, icon: Icons.warning_amber_rounded, color: context.theme.warning);
  }

  static void error(BuildContext context, String title, String message) {
    show(context, title: title, text: message, icon: Icons.error_outline_rounded, color: context.theme.danger);
  }

  static void confirmArchive(BuildContext context, VoidCallback onConfirm, {String? name}) {
    final msg = name != null
        ? Text.rich(TextSpan(
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

  static void confirmRestore(BuildContext context, VoidCallback onConfirm, {String? name}) {
    final msg = name != null
        ? Text.rich(TextSpan(
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

  static void confirmDelete(BuildContext context, VoidCallback onConfirm, {String? name}) {
    final msg = name != null
        ? Text.rich(TextSpan(
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
