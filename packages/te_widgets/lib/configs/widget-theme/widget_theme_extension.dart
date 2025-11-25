import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

@immutable
class TWidgetThemeExtension extends ThemeExtension<TWidgetThemeExtension> {
  final MaterialColor primary;
  final MaterialColor secondary;
  final MaterialColor success;
  final MaterialColor warning;
  final MaterialColor info;
  final MaterialColor danger;
  final MaterialColor grey;

  final Color layoutFrame;
  final TButtonTheme buttonTheme;
  final TVariant chipType;
  final TVariant toastType;
  final TVariant tooltipType;

  final TInputFieldTheme inputFieldTheme;
  final TTextFieldTheme textFieldTheme;
  final TTagsFieldTheme tagsFieldTheme;
  final TNumberFieldTheme numberFieldTheme;
  final TFilePickerTheme filePickerTheme;
  final TListTheme listTheme;
  final TTableTheme tableTheme;
  final TListCardTheme listCardTheme;
  final TAlertTheme alertTheme;

  const TWidgetThemeExtension({
    this.primary = AppColors.primary,
    this.secondary = AppColors.secondary,
    this.success = AppColors.success,
    this.warning = AppColors.warning,
    this.info = AppColors.info,
    this.danger = AppColors.danger,
    this.grey = AppColors.grey,
    this.layoutFrame = AppColors.grey,
    this.chipType = TVariant.tonal,
    this.toastType = TVariant.outline,
    this.tooltipType = TVariant.tonal,
    required this.buttonTheme,
    required this.inputFieldTheme,
    required this.textFieldTheme,
    required this.tagsFieldTheme,
    required this.numberFieldTheme,
    required this.filePickerTheme,
    required this.listTheme,
    required this.tableTheme,
    required this.listCardTheme,
    required this.alertTheme,
  });

  @override
  TWidgetThemeExtension copyWith({
    MaterialColor? primary,
    MaterialColor? secondary,
    MaterialColor? success,
    MaterialColor? warning,
    MaterialColor? info,
    MaterialColor? danger,
    MaterialColor? grey,
    Color? layoutFrame,
    TButtonTheme? buttonTheme,
    TVariant? chipType,
    TVariant? toastType,
    TVariant? tooltipType,
    TInputFieldTheme? inputFieldTheme,
    TTextFieldTheme? textFieldTheme,
    TTagsFieldTheme? tagsFieldTheme,
    TNumberFieldTheme? numberFieldTheme,
    TFilePickerTheme? filePickerTheme,
    TListTheme? listTheme,
    TTableTheme? tableTheme,
    TListCardTheme? listCardTheme,
    TAlertTheme? alertTheme,
  }) {
    return TWidgetThemeExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      danger: danger ?? this.danger,
      grey: grey ?? this.grey,
      layoutFrame: layoutFrame ?? this.layoutFrame,
      buttonTheme: buttonTheme ?? this.buttonTheme,
      chipType: chipType ?? this.chipType,
      toastType: toastType ?? this.toastType,
      tooltipType: tooltipType ?? this.tooltipType,
      inputFieldTheme: inputFieldTheme ?? this.inputFieldTheme,
      textFieldTheme: textFieldTheme ?? this.textFieldTheme,
      tagsFieldTheme: tagsFieldTheme ?? this.tagsFieldTheme,
      numberFieldTheme: numberFieldTheme ?? this.numberFieldTheme,
      filePickerTheme: filePickerTheme ?? this.filePickerTheme,
      listTheme: listTheme ?? this.listTheme,
      tableTheme: tableTheme ?? this.tableTheme,
      listCardTheme: listCardTheme ?? this.listCardTheme,
      alertTheme: alertTheme ?? this.alertTheme,
    );
  }

  @override
  TWidgetThemeExtension lerp(ThemeExtension<TWidgetThemeExtension>? other, double t) {
    return this;
  }

  factory TWidgetThemeExtension.defaultTheme(ColorScheme colors) {
    return TWidgetThemeExtension(
      layoutFrame: colors.brightness == Brightness.light ? const Color(0xFF536980) : const Color(0xFF3b3b3f),
      buttonTheme: TButtonTheme.defaultTheme(colors),
      inputFieldTheme: TInputFieldTheme.defaultTheme(colors),
      textFieldTheme: TTextFieldTheme.defaultTheme(colors),
      tagsFieldTheme: TTagsFieldTheme.defaultTheme(colors),
      numberFieldTheme: TNumberFieldTheme.defaultTheme(colors),
      filePickerTheme: TFilePickerTheme.defaultTheme(colors),
      listTheme: TListTheme.defaultTheme(colors),
      tableTheme: TTableTheme.defaultTheme(colors),
      listCardTheme: TListCardTheme.defaultTheme(colors),
      alertTheme: TAlertTheme.defaultTheme(colors),
    );
  }
}
