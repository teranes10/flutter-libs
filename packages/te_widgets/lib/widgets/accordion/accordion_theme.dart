import 'package:flutter/material.dart';

class TAccordionTheme {
  final Color backgroundColor;
  final Color headerColor;
  final Color contentColor;
  final Color borderColor;
  final double borderRadius;

  const TAccordionTheme({
    required this.backgroundColor,
    required this.headerColor,
    required this.contentColor,
    required this.borderColor,
    this.borderRadius = 8.0,
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
