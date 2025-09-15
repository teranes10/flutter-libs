import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class AlertButton {
  final String? text;
  final IconData? icon;
  final VoidCallback? onClick;

  AlertButton({this.text, this.icon, this.onClick});
}

class TAlertTheme {
  final Color? backgroundColor;
  final EdgeInsetsGeometry? insetPadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final MainAxisAlignment? actionsAlignment;
  final double? iconSize;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final TextAlign? contentTextAlign;
  final double? closeButtonWidth;
  final double? confirmButtonWidth;
  final TButtonType? closeButtonType;
  final TButtonType? confirmButtonType;

  const TAlertTheme({
    this.backgroundColor,
    this.insetPadding = const EdgeInsets.all(12.0),
    this.contentPadding = const EdgeInsets.all(20),
    this.actionsPadding = const EdgeInsets.only(bottom: 15),
    this.actionsAlignment = MainAxisAlignment.center,
    this.iconSize = 64,
    this.titleStyle,
    this.contentStyle,
    this.contentTextAlign = TextAlign.center,
    this.closeButtonWidth = 100,
    this.confirmButtonWidth = 80,
    this.closeButtonType = TButtonType.softText,
    this.confirmButtonType = TButtonType.softText,
  });

  Color getBackground(ColorScheme colors) {
    return backgroundColor ?? colors.surface;
  }

  TextStyle getTitleStyle(ColorScheme colors) {
    return titleStyle ?? TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant);
  }

  TextStyle getContentStyle(ColorScheme colors) {
    return contentStyle ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: colors.onSurface);
  }

  TAlertTheme copyWith({
    EdgeInsetsGeometry? insetPadding,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? actionsPadding,
    MainAxisAlignment? actionsAlignment,
    double? iconSize,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
    TextAlign? contentTextAlign,
    double? closeButtonWidth,
    double? confirmButtonWidth,
    TButtonType? closeButtonType,
    TButtonType? confirmButtonType,
  }) {
    return TAlertTheme(
      insetPadding: insetPadding ?? this.insetPadding,
      contentPadding: contentPadding ?? this.contentPadding,
      actionsPadding: actionsPadding ?? this.actionsPadding,
      actionsAlignment: actionsAlignment ?? this.actionsAlignment,
      iconSize: iconSize ?? this.iconSize,
      titleStyle: titleStyle ?? this.titleStyle,
      contentStyle: contentStyle ?? this.contentStyle,
      contentTextAlign: contentTextAlign ?? this.contentTextAlign,
      closeButtonWidth: closeButtonWidth ?? this.closeButtonWidth,
      confirmButtonWidth: confirmButtonWidth ?? this.confirmButtonWidth,
      closeButtonType: closeButtonType ?? this.closeButtonType,
      confirmButtonType: confirmButtonType ?? this.confirmButtonType,
    );
  }
}
