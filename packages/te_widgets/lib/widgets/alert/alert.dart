import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/alert/alert_config.dart';

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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: AppColors.grey.shade700),
              )
            : (props.text is Widget ? props.text : null),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.only(bottom: 5),
        actions: [
          if (props.closeButton != null)
            TextButton.icon(
              icon: props.closeButton!.icon != null ? Icon(props.closeButton!.icon) : const SizedBox.shrink(),
              label: Text(props.closeButton!.text ?? 'OK'),
              onPressed: props.closeButton!.onClick,
            ),
          if (props.confirmButton != null)
            TextButton.icon(
              icon: props.confirmButton!.icon != null ? Icon(props.confirmButton!.icon, color: color) : const SizedBox.shrink(),
              label: Text(props.confirmButton!.text ?? 'Confirm'),
              onPressed: props.confirmButton!.onClick,
            ),
        ],
      ),
    );
  }
}
