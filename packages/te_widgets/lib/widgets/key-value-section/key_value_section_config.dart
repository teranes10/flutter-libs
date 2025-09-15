import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/table/table_configs.dart';

class TKeyValue {
  final String key;
  final String? value;
  final Widget? widget;
  final double? width;

  TKeyValue(this.key, {this.value, this.widget, this.width});

  factory TKeyValue.text(String key, String? value) {
    return TKeyValue(key, value: value);
  }

  static TKeyValue mapHeader<T>(TTableHeader<T> header, T item) {
    return TKeyValue(
      header.text,
      value: header.getValue(item),
      widget: header.builder != null ? Builder(builder: (context) => header.builder!(context, item)) : null,
    );
  }

  static List<TKeyValue> mapHeaders<T>(List<TTableHeader<T>> headers, T item) {
    return headers.map((header) => TKeyValue.mapHeader(header, item)).toList();
  }
}

class TKeyValueStyle {
  final TextStyle? keyStyle;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double gridSpacing;
  final double minGridColWidth;
  final bool forceKeyValue;
  final double keyValueBreakPoint;

  const TKeyValueStyle({
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
