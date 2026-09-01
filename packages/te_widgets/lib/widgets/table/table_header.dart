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
    return map?.call(item)?.toString() ?? '';
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
    double? minWidth,
    double? maxWidth,
    bool forceCache = false,
  })  : map = null,
        minWidth = minWidth ?? (width + 16),
        maxWidth = maxWidth ?? (flex != null ? null : (width + 16)),
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          final imgUrl = map(item.data);
          if (imgUrl == null) return const SizedBox.shrink();
          return TImage(
            url: imgUrl,
            size: isDense ? width * 0.8 : width,
            forceCache: forceCache,
          );
        });

  /// Creates a header for displaying chips.
  TTableHeader.chip(
    this.text,
    this.map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    Color Function(T)? color,
    TVariant? type,
    void Function()? Function(T)? onTap,
  }) : builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          return TChip(
            text: map?.call(item.data).toString(),
            color: color?.call(item.data),
            type: type,
            onTap: onTap?.call(item.data),
            padding: isDense ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : null,
          );
        });

  /// Creates a header for displaying hex colors using [TColor].
  TTableHeader.color(
    this.text,
    String? Function(T) map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    String? Function(T)? label,
  })  : map = null,
        builder = ((ctx, item, __) {
          final hex = map(item.data);
          final colorLabel = label?.call(item.data);
          return TColor(hex: hex, label: colorLabel);
        });

  /// Creates a header for displaying ratings.
  TTableHeader.rating(
    this.text,
    double? Function(T) map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    int itemCount = 5,
    double itemSize = 10.0,
    Color? color,
    Color? unratedColor,
    bool allowHalfRating = false,
    double spacing = 0.0,
  })  : map = null,
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          final ratingValue = map(item.data) ?? 0.0;
          return TRating(
            value: ratingValue,
            itemCount: itemCount,
            itemSize: isDense ? itemSize * 0.8 : itemSize,
            color: color,
            unratedColor: unratedColor,
            disabled: true,
            allowHalfRating: allowHalfRating,
            spacing: spacing,
          );
        });

  /// Create an date formatter
  TTableHeader.datetime(
    this.text,
    this.map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    bool utc = true,
  }) : builder = ((_, item, __) {
          final value = map?.call(item.data)?.toString();
          if (value.isNullOrBlank) return SizedBox.shrink();

          final dateTime = utc ? TFormatter.parseUtcISO(value!)?.toLocal() : DateTime.tryParse(value!);
          return dateTime != null ? TDateTimeText(dateTime: dateTime) : SizedBox.shrink();
        });

  /// Creates a header for displaying and editing boolean values using [TSwitch].
  TTableHeader.toggle(
    this.text,
    bool? Function(T) get,
    void Function(T, bool)? set, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment = Alignment.center,
    bool disabled = false,
    bool Function(T data)? isDisabled,
  })  : map = get,
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          final val = get(item.data) ?? false;
          final isOff = disabled || (isDisabled?.call(item.data) ?? false);

          return TSwitch(
            value: val,
            disabled: isOff,
            size: isDense ? TInputSize.xs : TInputSize.sm,
            onValueChanged: isOff || set == null ? null : (newVal) => set(item.data, newVal ?? false),
          );
        });

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
        maxWidth = maxWidth != null
            ? maxWidth.clamp(75.0, 150.0)
            : count != null
                ? (50.0 * count).clamp(75.0, 150.0)
                : null,
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          return TButtonGroup(
            type: TButtonGroupType.icon,
            alignment: WrapAlignment.end,
            size: isDense ? TButtonSize.sm.copyWith(hPad: 4, vPad: 2) : TButtonSize.sm,
            items: builder(item),
          );
        });

  /// Creates an editable cell header.
  TTableHeader.editable(
    this.text, {
    required Object? Function(T) get,
    required Widget Function(BuildContext ctx, T data) builder,
    Widget Function(BuildContext ctx, T data)? displayBuilder,
    String? Function(T data)? error,
    String? placeholder,
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
  })  : map = get,
        builder = ((ctx, item, index) {
          final cellScope = TTableCellScope.maybeScopeOf(ctx);
          final activeCursor = cellScope?.activeCellNotifier ?? TTableCellScope.maybeOf(ctx);
          final data = item.data;
          final cellKey = "${item.key}_$text";
          final colors = ctx.colors;
          final textStyle =
              TTableScope.maybeOf(ctx)?.theme?.rowCardTheme.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;

          final cellError = error?.call(data) ?? cellScope?.getError(data, text, cellKey);
          final hasError = cellError != null && cellError.isNotEmpty;

          final textAlign = alignment == null
              ? TextAlign.left
              : (alignment == Alignment.centerRight || alignment == Alignment.topRight || alignment == Alignment.bottomRight
                  ? TextAlign.right
                  : (alignment == Alignment.center ? TextAlign.center : TextAlign.left));

          Widget buildDisplay() {
            if (displayBuilder != null) {
              return displayBuilder(ctx, data);
            }

            final rawVal = get(data);
            final displayStr = rawVal?.toString() ?? '';
            final isEmpty = displayStr.trim().isEmpty;

            if (hasError) {
              return Tooltip(
                message: cellError,
                waitDuration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        isEmpty ? (placeholder ?? '—') : displayStr,
                        style: textStyle?.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w600,
                            ) ??
                            TextStyle(
                              color: colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: textAlign,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TIcon.raw(
                      HugeIcons.strokeRoundedAlert02,
                      size: 14,
                      color: colors.error,
                    ),
                  ],
                ),
              );
            }

            if (isEmpty && placeholder != null) {
              return Text(
                placeholder,
                style: textStyle?.copyWith(
                      color: colors.onSurfaceVariant.withAlpha(100),
                      fontStyle: FontStyle.italic,
                    ) ??
                    TextStyle(
                      color: colors.onSurfaceVariant.withAlpha(100),
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: textAlign,
                overflow: TextOverflow.ellipsis,
              );
            }

            return Text(
              displayStr,
              style: textStyle,
              textAlign: textAlign,
              overflow: TextOverflow.ellipsis,
            );
          }

          Widget buildEditor() {
            final editorWidget = builder(ctx, data);
            if (hasError) {
              return Tooltip(
                message: cellError,
                waitDuration: const Duration(milliseconds: 200),
                child: editorWidget,
              );
            }
            return editorWidget;
          }

          if (activeCursor != null) {
            return InkWell(
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () => activeCursor.value = cellKey,
              child: Container(
                width: double.infinity,
                alignment: alignment ?? Alignment.centerLeft,
                child: ValueListenableBuilder(
                  valueListenable: activeCursor,
                  builder: (ctx, active, _) => active == cellKey ? buildEditor() : buildDisplay(),
                ),
              ),
            );
          }
          return buildDisplay();
        });

  /// Creates an editable text field header.
  TTableHeader.textField(
    String text,
    String? Function(T) get,
    void Function(T, String?) set, {
    int? flex,
    double? minWidth,
    double? maxWidth,
    Alignment? alignment,
    String? Function(T data)? error,
    String? placeholder,
    Widget Function(BuildContext ctx, T data)? displayBuilder,
  }) : this.editable(
          text,
          get: get,
          flex: flex,
          minWidth: minWidth,
          maxWidth: maxWidth,
          alignment: alignment,
          error: error,
          placeholder: placeholder,
          displayBuilder: displayBuilder,
          builder: (ctx, data) {
            final style =
                TTableScope.maybeOf(ctx)?.theme?.rowCardTheme.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
            final fontSize = style?.fontSize ?? 13.6;
            return TTextField<String>(
              theme: ctx.theme.textFieldTheme.copyWith(
                decorationType: TInputDecorationType.none,
                labelPosition: TLabelPosition.aboveField,
                padding: EdgeInsets.zero,
                fontSize: fontSize,
                height: fontSize + 6,
              ),
              placeholder: placeholder,
              autoFocus: true,
              value: get(data),
              onValueChanged: (v) => set(data, v),
            );
          },
        );

  /// Creates an editable number field header.
  TTableHeader.numberField(
    String text,
    num? Function(T) get,
    void Function(T, num?) set, {
    int? flex,
    double? minWidth,
    double? maxWidth,
    Alignment? alignment,
    String? Function(T data)? error,
    String? placeholder,
    Widget Function(BuildContext ctx, T data)? displayBuilder,
  }) : this.editable(
          text,
          get: get,
          flex: flex,
          minWidth: minWidth,
          maxWidth: maxWidth,
          alignment: alignment,
          error: error,
          placeholder: placeholder,
          displayBuilder: displayBuilder,
          builder: (ctx, data) {
            final style =
                TTableScope.maybeOf(ctx)?.theme?.rowCardTheme.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
            final fontSize = style?.fontSize ?? 13.6;
            return TNumberField<num>(
              theme: ctx.theme.numberFieldTheme.copyWith(
                decorationType: TInputDecorationType.none,
                labelPosition: TLabelPosition.aboveField,
                padding: EdgeInsets.zero,
                fontSize: fontSize,
                height: fontSize + 6,
                splitStepper: true,
              ),
              placeholder: placeholder,
              autoFocus: true,
              value: get(data),
              onValueChanged: (v) => set(data, v),
            );
          },
        );
}
