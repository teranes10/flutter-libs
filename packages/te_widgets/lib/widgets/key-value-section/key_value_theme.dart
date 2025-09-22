import 'package:flutter/material.dart';

class TKeyValueTheme {
  final TextStyle? keyStyle;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double gridSpacing;
  final double minGridColWidth;
  final bool forceKeyValue;
  final double keyValueBreakPoint;

  const TKeyValueTheme({
    this.keyStyle,
    this.labelStyle,
    this.valueStyle,
    this.gridSpacing = 0,
    this.minGridColWidth = 110,
    this.forceKeyValue = false,
    this.keyValueBreakPoint = 350,
  });

  TextStyle getKeyStyle(ColorScheme colors) {
    return keyStyle ?? TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant);
  }

  TextStyle getLabelStyle(ColorScheme colors) {
    return labelStyle ?? TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant);
  }

  TextStyle getValueStyle(ColorScheme colors) {
    return valueStyle ?? TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurface);
  }
}
