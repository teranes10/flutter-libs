import 'package:flutter/material.dart';

/// Theme configuration for [TKeyValueSection].
///
/// `TKeyValueTheme` controls the appearance of key-value pairs, including:
/// - Text styles for keys, labels, and values
/// - Grid layout spacing and breakpoints
class TKeyValueTheme {
  final TextStyle keyStyle;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final double gridSpacing;
  final double minGridColWidth;
  final bool forceKeyValue;
  final double keyValueBreakPoint;

  /// Creates a key-value theme.
  const TKeyValueTheme({
    required this.keyStyle,
    required this.labelStyle,
    required this.valueStyle,
    this.gridSpacing = 0,
    this.minGridColWidth = 110,
    this.forceKeyValue = false,
    this.keyValueBreakPoint = 350,
  });

  factory TKeyValueTheme.defaultTheme(ColorScheme colors) {
    return TKeyValueTheme(
      keyStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant),
      labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant),
      valueStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurface),
    );
  }
}
