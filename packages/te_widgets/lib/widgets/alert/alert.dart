import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TAlert extends StatelessWidget {
  final AlertProps props;

  const TAlert(this.props, {super.key});

  @override
  Widget build(BuildContext context) {
    final icon = props.icon ?? alertIcons[props.type]!;
    final color = alertColors[props.type]!;

    return IntrinsicHeight(
      child: AlertDialog(
        insetPadding: EdgeInsets.all(12.0),
        icon: Icon(icon, size: 64, color: color),
        title: Text(props.title!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: AppColors.grey.shade600)),
        contentPadding: EdgeInsets.all(20),
        content: props.text is String
            ? Text(
                props.text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: AppColors.grey.shade700),
              )
            : (props.text is Widget ? props.text : null),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.only(bottom: 15),
        actions: [
          if (props.closeButton != null)
            TButton(
              width: 100,
              color: props.confirmButton != null ? AppColors.grey : color,
              type: TButtonType.text,
              icon: props.closeButton!.icon,
              text: props.closeButton!.text,
              onPressed: (_) => props.closeButton!.onClick?.call(),
            ),
          if (props.confirmButton != null)
            TButton(
              width: 80,
              color: color,
              type: TButtonType.text,
              icon: props.confirmButton!.icon,
              text: props.confirmButton!.text,
              onPressed: (_) => props.confirmButton!.onClick?.call(),
            ),
        ],
      ),
    );
  }
}
