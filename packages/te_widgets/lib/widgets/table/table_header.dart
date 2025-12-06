import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Defines a column in [TTable].
///
/// `TTableHeader` configures how a column renders, including:
/// - Header text and alignment
/// - Data mapping from item T
/// - Custom cell builders
/// - Column sizing (flex, min/max width)
/// - Specialized types (image, chip, actions, editable)
///
/// ## Basic Usage
///
/// ```dart
/// TTableHeader(text: 'Name', map: (user) => user.name)
/// ```
///
/// ## Specialized Constructors
///
/// - [TTableHeader.image]: Renders an image from URL
/// - [TTableHeader.chip]: Renders a [TChip]
/// - [TTableHeader.actions]: Renders action buttons
/// - [TTableHeader.editable]: Renders editable text
/// - [TTableHeader.textField]: Renders a text input
/// - [TTableHeader.numberField]: Renders a number input
class TTableHeader<T, K> {
  /// The header label text.
  final String text;

  /// Function to extract cell value from item.
  final Object? Function(T)? map;

  /// Custom builder for cell content.
  final Widget Function(BuildContext, TListItem<T, K>, int)? builder;

  /// Flex factor for column width.
  final int? flex;

  /// Minimum width of the column.
  final double? minWidth;

  /// Maximum width of the column.
  final double? maxWidth;

  /// Alignment of content within the cell.
  final Alignment? alignment;

  /// Creates a standard table header.
  const TTableHeader(
    this.text, {
    this.map,
    this.builder,
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
  });

  /// Gets the string display value for an item.
  String getValue(T item) {
    return this.map?.call(item)?.toString() ?? '';
  }

  /// Gets the text alignment based on [alignment].
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

  /// Creates a header using only a mapping function.
  const TTableHeader.map(
    this.text,
    this.map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
  }) : builder = null;

  /// Creates a header for displaying images.
  TTableHeader.image(
    this.text,
    String? Function(T) map, {
    this.flex,
    this.alignment,
    double width = 50,
  })  : map = null,
        minWidth = width + 12,
        maxWidth = width + 12,
        builder = ((_, item, __) => map(item.data) != null ? TImage(url: map(item.data)!, size: width) : const SizedBox.shrink());

  /// Creates a header for displaying chips.
  TTableHeader.chip(
    this.text,
    this.map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    Color? color,
    TVariant? type,
  }) : builder = ((_, item, __) => TChip(text: map?.call(item.data).toString(), color: color, type: type));

  /// Creates a header for row actions.
  TTableHeader.actions(
    List<TButtonGroupItem> Function(TListItem<T, K>) builder, {
    this.text = "Actions",
    this.alignment = Alignment.center,
    this.flex,
    this.minWidth,
    double? maxWidth,
    int? count,
  })  : map = null,
        maxWidth = maxWidth ?? (count != null ? (50.0 * count).clamp(50.0, 150.0) : null),
        builder = ((ctx, item, __) => TButtonGroup(type: TButtonGroupType.icon, alignment: WrapAlignment.end, items: builder(item)));

  /// Creates an editable cell header.
  TTableHeader.editable(
    this.text, {
    required Object? Function(T) get,
    required Widget Function(BuildContext ctx, T data) builder,
    this.flex,
    this.minWidth = 150,
    this.maxWidth,
    this.alignment,
  })  : map = get,
        builder = ((ctx, item, index) {
          final activeCursor = TTableScope.maybeOf(ctx)?.activeCellNotifier;
          final data = item.data;
          final cellKey = "${item.key}_$text";
          final textStyle = ctx.theme.tableTheme.rowCardTheme.getContentTextStyle(ctx.colors);

          if (activeCursor != null) {
            return InkWell(
              onTap: () => activeCursor.value = cellKey,
              child: ValueListenableBuilder(
                valueListenable: activeCursor,
                builder: (ctx, active, _) => active == cellKey ? builder(ctx, data) : Text(get(data)?.toString() ?? '', style: textStyle),
              ),
            );
          }
          return Text(get(data)?.toString() ?? '', style: textStyle);
        });

  /// Creates an editable text field header.
  TTableHeader.textField(
    String text,
    String? Function(T) get,
    void Function(T, String?) set,
  ) : this.editable(text,
            get: get, builder: (ctx, data) => TTextField(autoFocus: true, value: get(data), onValueChanged: (v) => set(data, v)));

  /// Creates an editable number field header.
  TTableHeader.numberField(
    String text,
    num? Function(T) get,
    void Function(T, num?) set,
  ) : this.editable(text,
            get: get,
            minWidth: 200,
            builder: (ctx, data) => TNumberField(autoFocus: true, value: get(data), onValueChanged: (v) => set(data, v)));
}
