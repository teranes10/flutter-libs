import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/configs/theme/theme_widget_color_scheme.dart';
import 'package:te_widgets/widgets/button/button_config.dart';

@immutable
class TColorScheme extends ThemeExtension<TColorScheme> {
  final MaterialColor primary;
  final MaterialColor success;
  final MaterialColor warning;
  final MaterialColor info;
  final MaterialColor danger;
  final MaterialColor grey;

  final Color layoutFrame;
  final TButtonType buttonType;
  final TColorType chipType;
  final TColorType toastType;
  final TColorType tooltipType;

  const TColorScheme({
    this.primary = AppColors.primary,
    this.success = AppColors.success,
    this.warning = AppColors.warning,
    this.info = AppColors.info,
    this.danger = AppColors.danger,
    this.grey = AppColors.grey,
    this.layoutFrame = AppColors.grey,
    this.buttonType = TButtonType.solid,
    this.chipType = TColorType.tonal,
    this.toastType = TColorType.outline,
    this.tooltipType = TColorType.tonal,
  });

  @override
  TColorScheme copyWith({
    MaterialColor? primary,
    MaterialColor? success,
    MaterialColor? warning,
    MaterialColor? info,
    MaterialColor? danger,
    MaterialColor? grey,
    Color? layoutFrame,
    TButtonType? buttonType,
    TColorType? chipType,
    TColorType? toastType,
    TColorType? tooltipType,
  }) {
    return TColorScheme(
      primary: primary ?? this.primary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      danger: danger ?? this.danger,
      grey: grey ?? this.grey,
      layoutFrame: layoutFrame ?? this.layoutFrame,
      buttonType: buttonType ?? this.buttonType,
      chipType: chipType ?? this.chipType,
      toastType: toastType ?? this.toastType,
      tooltipType: tooltipType ?? this.tooltipType,
    );
  }

  @override
  TColorScheme lerp(ThemeExtension<TColorScheme>? other, double t) {
    return this;
  }
}
