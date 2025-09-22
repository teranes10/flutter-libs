import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

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

  double estimateColumnWidth(double availableWidth, TKeyValueTheme theme) {
    if (width != null) {
      return width!;
    }

    const double charWidth = 8.0;
    const double basePadding = 16.0;

    final headerLength = key.length;

    if (widget != null) {
      final finalWidth = (headerLength * charWidth) + basePadding;
      return math.max(theme.minGridColWidth, math.min(finalWidth, availableWidth * 0.6));
    }

    final valueLength = value?.length.toDouble() ?? 0;
    final maxLength = math.max(headerLength.toDouble(), valueLength);

    double scaledWidth;
    if (maxLength <= 32) {
      scaledWidth = maxLength * charWidth;
    } else if (maxLength <= 50) {
      final ratio = (maxLength - 32) / 18;
      scaledWidth = (32 * charWidth) + (ratio * (32 * charWidth * 0.2));
    } else if (maxLength <= 60) {
      final ratio = (maxLength - 50) / 10;
      scaledWidth = (32 * charWidth * 1.2) + (ratio * (42 * charWidth - 32 * charWidth * 1.2));
    } else {
      scaledWidth = math.min(42 * charWidth, availableWidth * 0.4);
    }

    final finalWidth = scaledWidth + basePadding;
    return math.max(theme.minGridColWidth, math.min(finalWidth, availableWidth * 0.6));
  }
}
