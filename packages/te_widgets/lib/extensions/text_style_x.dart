import 'package:flutter/material.dart';

extension FontWeightX on FontWeight {
  /// Steps font weight thicker (positive) or lighter (negative) by [step]
  /// clamped within [FontWeight.w100] to [FontWeight.w900].
  ///
  /// Example:
  /// - `FontWeight.w100.step(1)` -> `FontWeight.w200`
  /// - `FontWeight.w300.step(1)` -> `FontWeight.w400`
  /// - `FontWeight.w400.step(-1)` -> `FontWeight.w300`
  FontWeight step(int step) {
    final newValue = (value + step * 100).clamp(100, 900);
    return FontWeight.values[(newValue ~/ 100) - 1];
  }

  /// Convenience getter for 1 step thicker font weight.
  FontWeight get thicker => step(1);

  /// Convenience getter for 1 step lighter font weight.
  FontWeight get lighter => step(-1);
}

extension TextStyleX on TextStyle {
  /// Returns a new [TextStyle] with adjusted properties such as [sizeMultiplier] and [weightStep].
  ///
  /// - [sizeMultiplier]: Multiplies [fontSize] by this factor (if [fontSize] is not null).
  /// - [weightStep]: Steps the [fontWeight] by an offset (e.g. +1 changes w100 to w200, w300 to w400; -1 makes it lighter).
  ///   If [fontWeight] is currently null, defaults to [FontWeight.normal] before stepping.
  /// - All other parameters standardly override properties via [copyWith].
  TextStyle adjust({
    double? sizeMultiplier,
    int? weightStep,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    bool clearColor = false,
    Color? backgroundColor,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    Paint? foreground,
    Paint? background,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    List<Shadow>? shadows,
    FontStyle? fontStyle,
  }) {
    final effectiveFontSize =
        fontSize ?? (sizeMultiplier != null && this.fontSize != null ? this.fontSize! * sizeMultiplier : this.fontSize);

    final effectiveFontWeight =
        fontWeight ?? (weightStep != null ? (this.fontWeight ?? FontWeight.normal).step(weightStep) : this.fontWeight);

    if (clearColor) {
      return TextStyle(
        inherit: inherit,
        color: null,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        fontSize: effectiveFontSize,
        fontWeight: effectiveFontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        wordSpacing: wordSpacing ?? this.wordSpacing,
        textBaseline: textBaseline,
        height: height ?? this.height,
        leadingDistribution: leadingDistribution,
        locale: locale,
        foreground: foreground ?? this.foreground,
        background: background ?? this.background,
        shadows: shadows ?? this.shadows,
        fontFeatures: fontFeatures,
        fontVariations: fontVariations,
        decoration: decoration ?? this.decoration,
        decorationColor: decorationColor ?? this.decorationColor,
        decorationStyle: decorationStyle ?? this.decorationStyle,
        decorationThickness: decorationThickness ?? this.decorationThickness,
        debugLabel: debugLabel,
        fontFamily: fontFamily ?? this.fontFamily,
        fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
        overflow: overflow,
      );
    }

    return copyWith(
      fontSize: effectiveFontSize,
      fontWeight: effectiveFontWeight,
      color: color,
      backgroundColor: backgroundColor,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      foreground: foreground,
      background: background,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      shadows: shadows,
      fontStyle: fontStyle,
    );
  }

  /// Scales the [fontSize] by [multiplier] if [fontSize] is not null.
  TextStyle scale(double multiplier) {
    if (fontSize == null) return this;
    return copyWith(fontSize: fontSize! * multiplier);
  }

  /// Steps [fontWeight] by [steps] (positive = bolder/thicker, negative = lighter).
  /// If [fontWeight] is null, defaults to [FontWeight.normal] before stepping.
  TextStyle stepWeight([int steps = 1]) {
    final current = fontWeight ?? FontWeight.normal;
    return copyWith(fontWeight: current.step(steps));
  }

  /// Convenience getter to make the text one step thicker (+1).
  TextStyle get thicker => stepWeight(1);

  /// Convenience getter to make the text one step lighter (-1).
  TextStyle get lighter => stepWeight(-1);
}
