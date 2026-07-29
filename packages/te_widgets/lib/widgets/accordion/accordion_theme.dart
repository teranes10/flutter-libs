import 'package:flutter/material.dart';

class TAccordionTheme {
  final Color backgroundColor;
  final Color headerColor;
  final Color contentColor;
  final Color borderColor;
  final double borderRadius;
  final double elevation;
  final EdgeInsets tilePadding;
  final EdgeInsets contentPadding;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? expandedMargin;

  const TAccordionTheme({
    required this.backgroundColor,
    required this.headerColor,
    required this.contentColor,
    required this.borderColor,
    this.borderRadius = 8.0,
    this.elevation = 0,
    this.tilePadding = const EdgeInsets.all(16.0),
    this.contentPadding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
    this.margin,
    this.expandedMargin,
  });

  factory TAccordionTheme.defaultTheme(ColorScheme colors) {
    return TAccordionTheme(
      backgroundColor: colors.surface,
      headerColor: colors.onSurface,
      contentColor: colors.onSurfaceVariant,
      borderColor: Colors.transparent,
    );
  }

  TAccordionTheme copyWith({
    Color? backgroundColor,
    Color? headerColor,
    Color? contentColor,
    Color? borderColor,
    double? borderRadius,
    double? elevation,
    EdgeInsets? tilePadding,
    EdgeInsets? contentPadding,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? expandedMargin,
  }) {
    return TAccordionTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerColor: headerColor ?? this.headerColor,
      contentColor: contentColor ?? this.contentColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      tilePadding: tilePadding ?? this.tilePadding,
      contentPadding: contentPadding ?? this.contentPadding,
      margin: margin ?? this.margin,
      expandedMargin: expandedMargin ?? this.expandedMargin,
    );
  }
}
