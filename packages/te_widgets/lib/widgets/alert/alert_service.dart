import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/alert/alert.dart';
import 'package:te_widgets/widgets/alert/alert_config.dart';
import 'package:te_widgets/widgets/modal/modal_service.dart';

class TAlertService {
  static Future<void> show(BuildContext context, AlertProps props) async {
    TModalService.show(context, (context) {
      final AlertProps finalProps = AlertProps(
        title: props.title,
        text: props.text,
        icon: props.icon,
        type: props.type,
        confirmButton: props.confirmButton != null
            ? AlertButton(
                text: props.confirmButton!.text,
                icon: props.confirmButton!.icon,
                onClick: () {
                  context.close();
                  props.confirmButton?.onClick?.call();
                },
              )
            : null,
        closeButton: AlertButton(
          text: props.closeButton?.text ?? (props.confirmButton != null ? 'Cancel' : 'OK'),
          icon: props.closeButton?.icon,
          onClick: () {
            context.close();
            props.closeButton?.onClick?.call();
          },
        ),
      );

      return TAlert(finalProps);
    });
  }

  static void confirmArchive(
    BuildContext context,
    VoidCallback onConfirm, {
    String? name,
  }) {
    final msg = name != null
        ? Text.rich(TextSpan(
            text: 'Do you really want to archive ',
            children: [
              TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '?'),
            ],
          ))
        : 'Do you really want to archive this item?';

    show(
      context,
      AlertProps(
        title: 'Are you sure?',
        text: msg,
        icon: Icons.archive_rounded,
        type: AlertType.danger,
        confirmButton: AlertButton(text: 'Archive', onClick: onConfirm),
      ),
    );
  }

  static void confirmRestore(
    BuildContext context,
    VoidCallback onConfirm, {
    String? name,
  }) {
    final msg = name != null
        ? Text.rich(TextSpan(
            text: 'Do you really want to restore ',
            children: [
              TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '?'),
            ],
          ))
        : 'Do you really want to restore this item?';

    show(
      context,
      AlertProps(
        title: 'Are you sure?',
        text: msg,
        icon: Icons.unarchive_rounded,
        type: AlertType.info,
        confirmButton: AlertButton(text: 'Restore', onClick: onConfirm),
      ),
    );
  }

  static void confirmDelete(
    BuildContext context,
    VoidCallback onConfirm, {
    String? name,
  }) {
    final msg = name != null
        ? Text.rich(TextSpan(
            text: 'Do you really want to delete ',
            children: [
              TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '?'),
            ],
          ))
        : 'Do you really want to delete this item?';

    show(
      context,
      AlertProps(
          title: 'Are you sure?',
          text: msg,
          icon: Icons.delete_forever_rounded,
          type: AlertType.danger,
          confirmButton: AlertButton(text: 'Delete', onClick: onConfirm)),
    );
  }
}
