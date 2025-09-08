import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_widget_color_scheme.dart';
import 'package:te_widgets/widgets/button/button_config.dart';
import 'package:te_widgets/widgets/button/button_group.dart';
import 'package:te_widgets/widgets/chip/chip.dart';

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
    double width = 60,
  })  : value = null,
        map = null,
        minWidth = width + 12,
        maxWidth = width + 12,
        builder = ((_, item) => map(item) != null ? Image.network(map(item)!, width: width) : const SizedBox.shrink());

  TTableHeader.chip(
    this.text,
    this.map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    Color? color,
    TColorType? type,
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
}

enum TTableInteractionType { none, expand, select }

class TTableInteractionConfig<T> {
  final double scrollSensitivity;
  final TTableInteractionType tapAction;
  final TTableInteractionType longPressAction;
  final TTableInteractionType doubleTapAction;
  final Function(T item, int index)? onRowTap;
  final Function(T item, int index)? onRowDoubleTap;
  final Function(T item, int index)? onRowLongPress;

  const TTableInteractionConfig({
    this.tapAction = TTableInteractionType.expand,
    this.longPressAction = TTableInteractionType.none,
    this.doubleTapAction = TTableInteractionType.select,
    this.onRowTap,
    this.onRowDoubleTap,
    this.onRowLongPress,
    this.scrollSensitivity = 1.0,
  });
}

extension AlignmentExtension on Alignment {
  TextAlign toTextAlign() {
    if (this == Alignment.centerLeft || this == Alignment.topLeft || this == Alignment.bottomLeft) {
      return TextAlign.left;
    } else if (this == Alignment.centerRight || this == Alignment.topRight || this == Alignment.bottomRight) {
      return TextAlign.right;
    } else {
      return TextAlign.center;
    }
  }
}
