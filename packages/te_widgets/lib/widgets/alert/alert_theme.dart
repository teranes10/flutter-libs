import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Theme configuration for [TAlert].
///
/// `TAlertTheme` defines the visual style of alerts, including:
/// - Background color
/// - Padding and alignment
/// - Text styles (title, content)
/// - Button styles (close, confirm)
/// - Icon size
///
/// ## Usage
///
/// ```dart
/// TAlertTheme(
///   backgroundColor: Colors.white,
///   contentStyle: TextStyle(fontSize: 16),
///   confirmButtonType: TButtonType.solid,
/// )
/// ```
class TAlertTheme {
  final Color backgroundColor;
  final EdgeInsets? insetPadding;
  final EdgeInsets? contentPadding;
  final EdgeInsets? actionsPadding;
  final MainAxisAlignment actionsAlignment;
  final double? iconSize;
  final TextStyle titleStyle;
  final TextStyle contentStyle;
  final TextAlign? contentTextAlign;
  final double? closeButtonWidth;
  final TButtonType? closeButtonType;
  final MaterialColor? closeButtonColor;
  final double? confirmButtonWidth;
  final TButtonType? confirmButtonType;

  /// Creates an alert theme.
  const TAlertTheme({
    required this.backgroundColor,
    this.insetPadding = const EdgeInsets.all(12.0),
    this.contentPadding = const EdgeInsets.all(20),
    this.actionsPadding = const EdgeInsets.only(bottom: 15),
    this.actionsAlignment = MainAxisAlignment.center,
    this.iconSize = 64,
    required this.titleStyle,
    required this.contentStyle,
    this.contentTextAlign = TextAlign.center,
    this.closeButtonWidth = 100,
    this.confirmButtonWidth = 80,
    this.closeButtonType = TButtonType.softText,
    this.confirmButtonType = TButtonType.softText,
    this.closeButtonColor,
  });

  /// Creates a copy of the theme with updated properties.
  TAlertTheme copyWith({
    Color? backgroundColor,
    EdgeInsets? insetPadding,
    EdgeInsets? contentPadding,
    EdgeInsets? actionsPadding,
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
      backgroundColor: backgroundColor ?? this.backgroundColor,
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

  /// Creates a default theme derived from the context colors.
  factory TAlertTheme.defaultTheme(ColorScheme colors) {
    return TAlertTheme(
      backgroundColor: colors.surface,
      titleStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant),
      contentStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: colors.onSurface),
      closeButtonColor: AppColors.grey,
    );
  }
}
