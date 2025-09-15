import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/tags-field/tags_field_theme.dart';

@immutable
class TWidgetThemeExtension extends ThemeExtension<TWidgetThemeExtension> {
  final MaterialColor primary;
  final MaterialColor success;
  final MaterialColor warning;
  final MaterialColor info;
  final MaterialColor danger;
  final MaterialColor grey;

  final Color layoutFrame;
  final TButtonType buttonType;
  final TVariant chipType;
  final TVariant toastType;
  final TVariant tooltipType;
  final TInputFieldTheme inputFieldTheme;
  final TTextFieldTheme textFieldTheme;
  final TTagsFieldTheme tagsFieldTheme;
  final TNumberFieldTheme numberFieldTheme;
  final TFilePickerTheme filePickerTheme;

  const TWidgetThemeExtension({
    this.primary = AppColors.primary,
    this.success = AppColors.success,
    this.warning = AppColors.warning,
    this.info = AppColors.info,
    this.danger = AppColors.danger,
    this.grey = AppColors.grey,
    this.layoutFrame = AppColors.grey,
    this.buttonType = TButtonType.solid,
    this.chipType = TVariant.tonal,
    this.toastType = TVariant.outline,
    this.tooltipType = TVariant.tonal,
    this.inputFieldTheme = const TInputFieldTheme(),
    this.textFieldTheme = const TTextFieldTheme(),
    this.tagsFieldTheme = const TTagsFieldTheme(),
    this.numberFieldTheme = const TNumberFieldTheme(),
    this.filePickerTheme = const TFilePickerTheme(),
  });

  @override
  TWidgetThemeExtension copyWith({
    MaterialColor? primary,
    MaterialColor? success,
    MaterialColor? warning,
    MaterialColor? info,
    MaterialColor? danger,
    MaterialColor? grey,
    Color? layoutFrame,
    TButtonType? buttonType,
    TVariant? chipType,
    TVariant? toastType,
    TVariant? tooltipType,
    TInputFieldTheme? inputFieldTheme,
    TTextFieldTheme? textFieldTheme,
    TTagsFieldTheme? tagsFieldTheme,
    TNumberFieldTheme? numberFieldTheme,
    TFilePickerTheme? filePickerTheme,
  }) {
    return TWidgetThemeExtension(
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
      inputFieldTheme: inputFieldTheme ?? this.inputFieldTheme,
      textFieldTheme: textFieldTheme ?? this.textFieldTheme,
      tagsFieldTheme: tagsFieldTheme ?? this.tagsFieldTheme,
      numberFieldTheme: numberFieldTheme ?? this.numberFieldTheme,
      filePickerTheme: filePickerTheme ?? this.filePickerTheme,
    );
  }

  @override
  TWidgetThemeExtension lerp(ThemeExtension<TWidgetThemeExtension>? other, double t) {
    return this;
  }
}
