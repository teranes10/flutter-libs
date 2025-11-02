import 'package:flutter/material.dart';

class TTableRowHeaderTheme {
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextStyle? textStyle;

  const TTableRowHeaderTheme({
    this.decoration,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.textStyle,
  });

  TextStyle getHeaderStyle(ColorScheme colors) {
    return textStyle ?? TextStyle(fontSize: 13.6, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant);
  }
}
