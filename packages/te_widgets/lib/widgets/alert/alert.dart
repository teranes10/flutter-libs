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

  const TAlert({
    super.key,
    this.title,
    this.text,
    this.icon,
    this.closeButton,
    this.confirmButton,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;

    return IntrinsicHeight(
      child: AlertDialog(
        backgroundColor: colors.surface,
        insetPadding: EdgeInsets.all(12.0),
        contentPadding: EdgeInsets.all(20),
        icon: icon != null ? Icon(icon, size: 64, color: color) : null,
        title: title != null
            ? Text(title!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant))
            : null,
        content: text is String
            ? Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: colors.onSurface))
            : (text is Widget ? text : null),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.only(bottom: 15),
        actions: [
          if (closeButton != null)
            TButton(
              size: TButtonSize.md.copyWith(minW: 100),
              color: confirmButton != null ? theme.grey : color,
              type: TButtonType.softText,
              icon: closeButton!.icon,
              text: closeButton!.text,
              onPressed: (_) => closeButton!.onClick?.call(),
            ),
          if (confirmButton != null)
            TButton(
              size: TButtonSize.md.copyWith(minW: 80),
              color: color,
              type: TButtonType.softText,
              icon: confirmButton!.icon,
              text: confirmButton!.text,
              onPressed: (_) => confirmButton!.onClick?.call(),
            ),
        ],
      ),
    );
  }
}
