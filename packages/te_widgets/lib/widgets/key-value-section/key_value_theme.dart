import 'package:flutter/material.dart';

/// Theme configuration for [TKeyValueSection].
///
/// `TKeyValueTheme` controls the appearance of key-value pairs, including:
/// - Text styles for keys, labels, and values
/// - Grid layout spacing and breakpoints
class TKeyValueTheme {
  final TextStyle? keyStyle;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double gridSpacing;
  final double minGridColWidth;
  final bool forceKeyValue;
  final double keyValueBreakPoint;

  /// Creates a key-value theme.
  const TKeyValueTheme({
    this.keyStyle,
    this.labelStyle,
    this.valueStyle,
    this.gridSpacing = 0,
    this.minGridColWidth = 110,
    this.forceKeyValue = false,
    this.keyValueBreakPoint = 350,
  });

  /// Returns the effective key style.
  TextStyle getKeyStyle(ColorScheme colors) {
    return keyStyle ?? TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant);
  }

  /// Returns the effective label style.
  TextStyle getLabelStyle(ColorScheme colors) {
    return labelStyle ?? TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant);
  }

  /// Returns the effective value style.
  TextStyle getValueStyle(ColorScheme colors) {
    return valueStyle ?? TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurface);
  }
}
