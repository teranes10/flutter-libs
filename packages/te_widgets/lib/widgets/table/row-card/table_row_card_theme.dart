import 'package:flutter/material.dart';

class TTableRowCardTheme {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Border? border;
  final TextStyle? contentTextStyle;

  const TTableRowCardTheme({
    this.margin = const EdgeInsets.only(bottom: 8),
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.elevation = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.border,
    this.contentTextStyle,
  });

  Color getBackgroundColor(ColorScheme colors, bool isSelected) {
    return isSelected ? (selectedBackgroundColor ?? colors.primaryContainer) : (backgroundColor ?? colors.surface);
  }

  TextStyle getContentTextStyle(ColorScheme colors) {
    return contentTextStyle ?? TextStyle(fontSize: 13.6, fontWeight: FontWeight.w300, color: colors.onSurface);
  }
}
