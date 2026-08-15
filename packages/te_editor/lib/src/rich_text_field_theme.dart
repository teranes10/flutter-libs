import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TRichTextFieldTheme extends TTextFieldTheme {
  const TRichTextFieldTheme({
    required super.color,
    required super.backgroundColor,
    required super.borderColor,
    required super.labelStyle,
    required super.helperTextStyle,
    required super.errorTextStyle,
    required super.borderRadius,
    required super.borderWidth,
    required super.labelBuilder,
    required super.helperTextBuilder,
    required super.errorsBuilder,
    required super.textStyle,
    required super.hintStyle,
    required super.tagStyle,
    super.size = TInputSize.md,
    required super.decorationType,
    required super.labelPosition,
    super.preWidget,
    super.postWidget,
    super.height,
    super.padding,
    super.fontSize,
  });

  factory TRichTextFieldTheme.defaultTheme(ColorScheme colors) {
    final baseTheme = TTextFieldTheme.defaultTheme(colors);

    return TRichTextFieldTheme(
      size: baseTheme.size,
      decorationType: baseTheme.decorationType,
      labelPosition: baseTheme.labelPosition,
      color: baseTheme.color,
      backgroundColor: baseTheme.backgroundColor,
      borderColor: baseTheme.borderColor,
      labelStyle: baseTheme.labelStyle,
      helperTextStyle: baseTheme.helperTextStyle,
      errorTextStyle: baseTheme.errorTextStyle,
      borderRadius: baseTheme.borderRadius,
      borderWidth: baseTheme.borderWidth,
      labelBuilder: baseTheme.labelBuilder,
      helperTextBuilder: baseTheme.helperTextBuilder,
      errorsBuilder: baseTheme.errorsBuilder,
      preWidget: baseTheme.preWidget,
      postWidget: baseTheme.postWidget,
      height: baseTheme.height,
      padding: baseTheme.padding,
      fontSize: baseTheme.fontSize,
      textStyle: baseTheme.textStyle,
      tagStyle: baseTheme.tagStyle,
      hintStyle: baseTheme.hintStyle,
    );
  }
}
