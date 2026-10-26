import 'dart:typed_data';
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

  /// Optional icon to display before the key (IconData, HugeIcon data or Widget), rendered via [TIcon].
  final dynamic icon;

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
    this.icon,
    this.width,
    this.alignment,
    this.minWidth,
    this.maxWidth,
  });

  /// Whether this item has no value to show: no [widget] and a null or blank
  /// [value]. Values like `0`, `-` or `n/a` are real values and are kept.
  bool get isEmptyValue => widget == null && (value == null || value!.trim().isEmpty);

  /// Creates a key-value item with text value.
  factory TKeyValue.text(
    String key,
    String? value, {
    dynamic icon,
    double? width,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) =>
      TKeyValue(
        key,
        value: value,
        icon: icon,
        width: width,
        alignment: alignment,
        minWidth: minWidth,
        maxWidth: maxWidth,
      );

  /// Creates a key-value item for displaying a formatted date/time using [TDateTimeText].
  factory TKeyValue.datetime(
    String key,
    dynamic value, {
    bool utc = true,
    dynamic icon,
    double? width,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) {
    Widget? widget;
    String? valStr;
    DateTime? dateTime;
    if (value is DateTime) {
      dateTime = value;
      valStr = value.toIso8601String();
    } else if (value is String && !value.isNullOrBlank) {
      valStr = value;
      dateTime = utc ? TFormatter.parseUtcISO(value)?.toLocal() : DateTime.tryParse(value);
    }
    if (dateTime != null) {
      widget = TDateTimeText(dateTime: dateTime);
    }
    return TKeyValue(
      key,
      value: widget == null ? valStr : null,
      widget: widget,
      icon: icon,
      width: width,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Creates a key-value item for displaying an image using [TImage].
  factory TKeyValue.image(
    String key,
    String? url, {
    Uint8List? bytes,
    double size = 40.0,
    double? imageWidth,
    double? imageHeight,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    bool forceCache = false,
    dynamic icon,
    double? width,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) {
    Widget? widget;
    final hasUrl = url != null && url.isNotEmpty;
    final hasBytes = bytes != null && bytes.isNotEmpty;
    if (hasUrl || hasBytes) {
      widget = TImage(
        url: url,
        bytes: bytes,
        size: (imageWidth == null && imageHeight == null) ? size : null,
        width: imageWidth,
        height: imageHeight,
        fit: fit,
        border: borderRadius != null
            ? RoundedRectangleBorder(borderRadius: borderRadius)
            : const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
        forceCache: forceCache,
      );
    }
    return TKeyValue(
      key,
      value: widget == null ? (url ?? '') : null,
      widget: widget,
      icon: icon,
      width: width,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Creates a key-value item for displaying a chip using [TChip].
  factory TKeyValue.chip(
    String key,
    String? text, {
    dynamic chipIcon,
    Color? color,
    Color? background,
    Color? textColor,
    TVariant? type,
    TSize size = TChipSize.sm,
    VoidCallback? onTap,
    Widget? trailing,
    BorderRadius? chipBorderRadius,
    dynamic icon,
    double? width,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) {
    Widget? widget;
    if (text != null && text.isNotEmpty) {
      widget = TChip(
        text: text,
        icon: chipIcon,
        trailing: trailing,
        color: color,
        background: background,
        textColor: textColor,
        type: type,
        size: size,
        onTap: onTap,
        borderRadius: chipBorderRadius,
      );
    }
    return TKeyValue(
      key,
      value: text,
      widget: widget,
      icon: icon,
      width: width,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Creates a key-value item for displaying multiple chips in a [Wrap].
  factory TKeyValue.chips(
    String key,
    List<dynamic> items, {
    Color? color,
    Color? Function(String chipText)? colorBuilder,
    dynamic chipIcon,
    dynamic Function(String chipText)? iconBuilder,
    TVariant? type,
    TVariant? Function(String chipText)? typeBuilder,
    TSize size = TChipSize.sm,
    double spacing = 4.0,
    double runSpacing = 4.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.center,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    void Function(String chipText)? onTap,
    dynamic icon,
    double? width,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) {
    final chipWidgets = <Widget>[];
    final stringValues = <String>[];
    for (final item in items) {
      if (item is TChip) {
        chipWidgets.add(item);
        if (item.text != null && item.text!.isNotEmpty) {
          stringValues.add(item.text!);
        }
      } else if (item != null) {
        final text = item.toString();
        if (text.isNotEmpty) {
          stringValues.add(text);
          chipWidgets.add(
            TChip(
              text: text,
              icon: iconBuilder?.call(text) ?? chipIcon,
              color: colorBuilder?.call(text) ?? color,
              type: typeBuilder?.call(text) ?? type,
              size: size,
              onTap: onTap != null ? () => onTap(text) : null,
            ),
          );
        }
      }
    }

    Widget? widget = chipWidgets.isNotEmpty
        ? Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            crossAxisAlignment: crossAxisAlignment,
            alignment: wrapAlignment,
            children: chipWidgets,
          )
        : null;

    return TKeyValue(
      key,
      value: stringValues.isNotEmpty ? stringValues.join(', ') : null,
      widget: widget,
      icon: icon,
      width: width,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Creates a key-value item for displaying star ratings using [TRating].
  factory TKeyValue.rating(
    String key,
    double? rating, {
    int itemCount = 5,
    double itemSize = 14.0,
    Color? color,
    Color? unratedColor,
    bool allowHalfRating = true,
    double spacing = 2.0,
    bool disabled = true,
    ValueChanged<double?>? onValueChanged,
    dynamic icon,
    double? width,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) {
    Widget? widget;
    if (rating != null) {
      widget = TRating(
        value: rating,
        itemCount: itemCount,
        itemSize: itemSize,
        color: color,
        unratedColor: unratedColor,
        disabled: disabled,
        allowHalfRating: allowHalfRating,
        spacing: spacing,
        onValueChanged: onValueChanged,
      );
    }
    return TKeyValue(
      key,
      value: rating?.toString(),
      widget: widget,
      icon: icon,
      width: width,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Creates a key-value item for displaying progress bars using [TProgressBar].
  factory TKeyValue.progress(
    String key,
    double? value, {
    double progressMaxWidth = 180.0,
    double height = 6.0,
    bool showPercentage = true,
    String? valueText,
    TProgressValuePosition valuePosition = TProgressValuePosition.afterProgress,
    Color? color,
    Color? Function(double value, double percentage)? colorBuilder,
    Color? backgroundColor,
    bool flowing = false,
    TextStyle? valueStyle,
    dynamic icon,
    double? width,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) {
    Widget? widget;
    if (value != null) {
      widget = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: progressMaxWidth),
        child: TProgressBar(
          value: value,
          height: height,
          showPercentage: showPercentage,
          valueText: valueText,
          valuePosition: valuePosition,
          color: color,
          colorBuilder: colorBuilder,
          backgroundColor: backgroundColor,
          flowing: flowing,
          valueStyle: valueStyle,
        ),
      );
    }
    return TKeyValue(
      key,
      value: value != null ? (valueText ?? '${(value * 100).toInt()}%') : null,
      widget: widget,
      icon: icon,
      width: width,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Creates a key-value item for displaying and editing boolean values using [TSwitch].
  factory TKeyValue.toggle(
    String key,
    bool? value, {
    ValueChanged<bool?>? onValueChanged,
    bool disabled = false,
    TInputSize size = TInputSize.sm,
    Color? color,
    Color? inactiveColor,
    dynamic icon,
    double? width,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) {
    Widget? widget;
    if (value != null) {
      widget = TSwitch(
        value: value,
        disabled: disabled,
        size: size,
        color: color,
        inactiveColor: inactiveColor,
        onValueChanged: disabled ? null : onValueChanged,
      );
    }
    return TKeyValue(
      key,
      value: value?.toString(),
      widget: widget,
      icon: icon,
      width: width,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Creates a key-value item for displaying a color hex code using [TColor].
  factory TKeyValue.color(
    String key,
    String? hex, {
    dynamic icon,
    double? width,
    Alignment? alignment,
    double? minWidth,
    double? maxWidth,
  }) {
    return TKeyValue(
      key,
      widget: TColor(hex: hex),
      icon: icon,
      width: width,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  /// Maps table headers to key-value items for list view representation.
  static List<TKeyValue> mapHeaders<T, K>(BuildContext ctx, List<TTableHeader<T, K>> headers, TListItem<T, K> item, int index) {
    return headers.expand((h) => h.toKeyValues(ctx, item, index)).toList();
  }
}
