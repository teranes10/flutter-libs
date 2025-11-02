import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class AlertButton {
  final String? text;
  final IconData? icon;
  final VoidCallback? onClick;

  AlertButton({this.text, this.icon, this.onClick});
}

class TAlert extends StatelessWidget {
  final dynamic text; // String or Widget
  final String? title;
  final IconData? icon;
  final Color? color;
  final AlertButton? closeButton;
  final AlertButton? confirmButton;
  final TAlertTheme? theme;

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
