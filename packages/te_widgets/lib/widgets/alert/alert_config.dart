import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

enum AlertType { success, info, warning, danger }

class AlertButton {
  final String? text;
  final IconData? icon;
  final VoidCallback? onClick;

  AlertButton({this.text, this.icon, this.onClick});
}

class AlertProps {
  final String? title;
  final dynamic text; // String or Widget
  final IconData? icon;
  final AlertType type;
  final AlertButton? closeButton;
  final AlertButton? confirmButton;

  AlertProps({
    this.title,
    this.text,
    this.icon,
    this.type = AlertType.info,
    this.closeButton,
    this.confirmButton,
  });
}

final Map<AlertType, IconData> alertIcons = {
  AlertType.success: Icons.check_circle_rounded,
  AlertType.info: Icons.info_rounded,
  AlertType.warning: Icons.error_rounded,
  AlertType.danger: Icons.cancel_rounded,
};

final Map<AlertType, MaterialColor> alertColors = {
  AlertType.success: AppColors.success,
  AlertType.info: AppColors.info,
  AlertType.warning: AppColors.warning,
  AlertType.danger: AppColors.danger,
};
