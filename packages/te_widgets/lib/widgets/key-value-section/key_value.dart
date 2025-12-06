import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Represents a single key-value item in a [TKeyValueSection].
class TKeyValue {
  /// The label/key text.
  final String key;

  /// The value text.
  final String? value;

  /// Custom widget to display instead of text value.
  final Widget? widget;

  /// Optional fixed width for the column.
  final double? width;

  /// Creates a key-value item.
  TKeyValue(this.key, {this.value, this.widget, this.width});

  /// Creates a key-value item with text value.
  factory TKeyValue.text(String key, String? value) {
    return TKeyValue(key, value: value);
  }

  /// Maps table headers to key-value items for list view representation.
  static List<TKeyValue> mapHeaders<T, K>(BuildContext ctx, List<TTableHeader<T, K>> headers, TListItem<T, K> item, int index) {
    return headers
        .map((header) => TKeyValue(
              header.text,
              value: header.getValue(item.data),
              widget: header.builder != null ? header.builder!(ctx, item, index) : null,
              width: header.minWidth,
            ))
        .toList();
  }

  /// Estimates the width of the column based on content and theme.
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
