import 'package:flutter/material.dart';

/// Theme configuration for [TTableRowHeader].
///
/// `TTableRowHeaderTheme` styles the header row of a table, including:
/// - Padding
/// - Decoration (background, border)
/// - Text style for column titles
class TTableRowHeaderTheme {
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextStyle? textStyle;

  /// Creates a table row header theme.
  const TTableRowHeaderTheme({
    this.decoration,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.textStyle,
  });

  /// Returns the text style for headers.
  TextStyle getHeaderStyle(ColorScheme colors) {
    return textStyle ?? TextStyle(fontSize: 13.6, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant);
  }
}
