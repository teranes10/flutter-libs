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
  final MaterialColor? color;
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
    final theme = context.theme;
    final exTheme = context.exTheme;

    return IntrinsicHeight(
      child: AlertDialog(
        backgroundColor: theme.surface,
        insetPadding: EdgeInsets.all(12.0),
        contentPadding: EdgeInsets.all(20),
        icon: icon != null ? Icon(icon, size: 64, color: color) : null,
        title:
            title != null ? Text(title!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: theme.onSurfaceVariant)) : null,
        content: text is String
            ? Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: theme.onSurface))
            : (text is Widget ? text : null),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.only(bottom: 15),
        actions: [
          if (closeButton != null)
            TButton(
              width: 100,
              color: confirmButton != null ? exTheme.grey : color,
              type: TButtonType.softText,
              icon: closeButton!.icon,
              text: closeButton!.text,
              onPressed: (_) => closeButton!.onClick?.call(),
            ),
          if (confirmButton != null)
            TButton(
              width: 80,
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
