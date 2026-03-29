import 'package:flutter/material.dart';

/// Theme configuration for [TTableRowCard].
///
/// `TTableRowCardTheme` styles the desktop/tablet row view in tables, including:
/// - Margins/Padding
/// - Elevation
/// - Text content style
/// - Background colors for rows
class TTableRowCardTheme {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final BorderRadius borderRadius;
  final WidgetStateProperty<Color> backgroundColor;
  final WidgetStateProperty<Border> border;
  final TextStyle? contentTextStyle;

  /// Creates a table row card theme.
  const TTableRowCardTheme({
    this.margin = const EdgeInsets.only(bottom: 8),
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.elevation = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    required this.backgroundColor,
    required this.border,
    required this.contentTextStyle,
  });

  factory TTableRowCardTheme.defaultTheme(ColorScheme colors) {
    return TTableRowCardTheme(
      backgroundColor:
          WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? colors.primaryContainer : colors.surface),
      border: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Border.all(color: colors.primary, width: 2) : Border.all(color: colors.outline),
      ),
      contentTextStyle: TextStyle(fontSize: 13.6, fontWeight: FontWeight.w300, color: colors.onSurface),
    );
  }

  TTableRowCardTheme copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? elevation,
    BorderRadius? borderRadius,
    WidgetStateProperty<Color>? backgroundColor,
    WidgetStateProperty<Border>? border,
    TextStyle? contentTextStyle,
  }) {
    return TTableRowCardTheme(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      contentTextStyle: contentTextStyle ?? this.contentTextStyle,
    );
  }
}
