import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableHeader<T> {
  final String text;
  final String? value;
  final Object? Function(T)? map;
  final Widget Function(BuildContext, T)? builder;
  final int? flex;
  final double? minWidth;
  final double? maxWidth;
  final Alignment? alignment;

  const TTableHeader(
    this.text, {
    this.value,
    this.map,
    this.builder,
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
  });

  const TTableHeader.map(
    this.text,
    this.map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
  })  : value = null,
        builder = null;

  TTableHeader.image(
    this.text,
    String? Function(T) map, {
    this.flex,
    this.alignment,
    double width = 50,
  })  : value = null,
        map = null,
        minWidth = width + 12,
        maxWidth = width + 12,
        builder = ((_, item) => map(item) != null ? TImage(url: map(item)!, size: width) : const SizedBox.shrink());

  TTableHeader.chip(
    this.text,
    this.map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    Color? color,
    TVariant? type,
  })  : value = null,
        builder = ((_, item) => TChip(text: map?.call(item).toString(), color: color, type: type));

  TTableHeader.actions(
    List<TButtonGroupItem> Function(T) builder, {
    this.text = "Actions",
    this.alignment = Alignment.center,
    this.flex,
    this.minWidth,
    this.maxWidth,
  })  : value = null,
        map = null,
        builder = ((ctx, item) => TButtonGroup(type: TButtonGroupType.icon, items: builder(item)));

  String getValue(T item) {
    if (this.map != null) {
      return this.map!(item)?.toString() ?? '';
    } else if (item is Map<String, dynamic> && value != null) {
      return item[value]?.toString() ?? '';
    }

    return '';
  }

  TextAlign getTextAlign() {
    if (alignment == null) return TextAlign.left;

    if (alignment == Alignment.centerLeft || alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) {
      return TextAlign.left;
    } else if (alignment == Alignment.centerRight || alignment == Alignment.topRight || alignment == Alignment.bottomRight) {
      return TextAlign.right;
    } else {
      return TextAlign.center;
    }
  }
}
