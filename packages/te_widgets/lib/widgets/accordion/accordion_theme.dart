import 'package:flutter/material.dart';

class TAccordionTheme {
  final Color backgroundColor;
  final Color headerColor;
  final Color contentColor;
  final Color borderColor;
  final double borderRadius;
  final double elevation;
  final EdgeInsets tilePadding;
  final EdgeInsets padding;

  const TAccordionTheme({
    required this.backgroundColor,
    required this.headerColor,
    required this.contentColor,
    required this.borderColor,
    this.borderRadius = 8.0,
    this.elevation = 0,
    this.tilePadding = const EdgeInsets.all(16.0),
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
  });

  factory TAccordionTheme.defaultTheme(ColorScheme colors) {
    return TAccordionTheme(
      backgroundColor: colors.surface,
      headerColor: colors.onSurface,
      contentColor: colors.onSurfaceVariant,
      borderColor: colors.outlineVariant,
    );
  }
}
