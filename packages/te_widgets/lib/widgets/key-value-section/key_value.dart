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

  /// Optional alignment for the item.
  final Alignment? alignment;

  /// Optional minimum width for the item.
  final double? minWidth;

  /// Optional maximum width for the item.
  final double? maxWidth;

  /// Creates a key-value item.
  TKeyValue(
    this.key, {
    this.value,
    this.widget,
    this.width,
    this.alignment,
    this.minWidth,
    this.maxWidth,
  });

  /// Creates a key-value item with text value.
  factory TKeyValue.text(
    String key,
    String? value, {
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) =>
      TKeyValue(
        key,
        value: value,
        alignment: alignment,
        minWidth: minWidth,
        maxWidth: maxWidth,
      );

  /// Creates a key-value item for displaying a formatted date/time.
  factory TKeyValue.datetime(
    String key,
    String? value, {
    bool utc = true,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) {
    Widget? widget;
    if (!value.isNullOrBlank) {
      final dateTime = utc ? TFormatter.parseUtcISO(value!)?.toLocal() : DateTime.tryParse(value!);
      if (dateTime != null) {
        widget = TDateTimeText(dateTime: dateTime);
      }
    }
    return TKeyValue(
      key,
      value: widget == null ? value : null,
      widget: widget,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Maps table headers to key-value items for list view representation.
  static List<TKeyValue> mapHeaders<T, K>(BuildContext ctx, List<TTableHeader<T, K>> headers, TListItem<T, K> item, int index) {
    return headers
        .map((h) => TKeyValue(
              h.text,
              value: h.getValue(item.data),
              widget: h.builder != null ? h.builder!(ctx, item, index) : null,
              width: h.minWidth,
              minWidth: h.minWidth,
            ))
        .toList();
  }
}
