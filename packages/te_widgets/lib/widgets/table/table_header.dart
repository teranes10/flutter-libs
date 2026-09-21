import 'dart:math' as math;
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
/// - [TTableHeader.tile]: Renders a custom [TTile]
/// - [TTableHeader.progress]: Renders a [TProgressBar]
/// - [TTableHeader.row]: Renders multiple widgets in a [Wrap]
/// - [TTableHeader.column]: Renders multiple widgets vertically in a [Column]
/// - [TTableHeader.keyValues]: Renders a list of [TKeyValue] pairs
/// - [TTableHeader.values]: Renders a hierarchical list of values (cascading font size & contrast)
/// - [TTableHeader.image]: Renders an image from URL
/// - [TTableHeader.chip]: Renders a [TChip]
/// - [TTableHeader.chips]: Renders multiple [TChip] widgets in a [Wrap] with auto-calculated width estimation
/// - [TTableHeader.color]: Renders a [TColor] swatch badge
/// - [TTableHeader.rating]: Renders a [TRating]
/// - [TTableHeader.datetime]: Renders formatted date/time text using [TDateTimeText]
/// - [TTableHeader.toggle]: Renders a [TSwitch]
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

  /// Optional unique key for filtering (defaults to camelCase of [text]).
  final String? key;

  /// Underlying filter data type for auto-generated filter fields.
  final TFilterType? filterType;

  /// Whether this column can be filtered in CRUD table filter forms. Defaults to true if [map] is non-null.
  final bool filterable;

  /// Optional custom list of filter operators for this column.
  final List<TFilterOperator>? filterOperators;

  /// Optional list of items for enum/select filters.
  final List<dynamic>? filterItems;

  /// Optional explicit filter definition override for this column.
  final TFilterDef<T>? filterDef;

  /// Optional explicit width estimator for cells whose true rendered size
  /// can't be inferred by measuring [map]'s raw value as plain text (e.g.
  /// a chip's padding/border, a star rating's icon row, a switch's fixed
  /// track size). Given the same [T] the column measures, return an
  /// estimated unwrapped pixel width for that cell. Takes priority over
  /// both [map]-based text measurement and the flat fallback used when
  /// there's no [map] at all.
  final double Function(T data)? widthEstimator;

  /// The underlying key-value generator when created via [TTableHeader.keyValues].
  final List<TKeyValue> Function(T data)? keyValuesBuilder;

  /// Whether sub-keyValues should be unpacked as individual flat rows on mobile cards.
  /// Defaults to `true` for [TTableHeader.keyValues].
  final bool flattenOnMobile;

  /// Optional prefix or formatting hook when flattened on mobile (e.g. `(header, key) => '$header: $key'`).
  final String Function(String headerText, String childKey)? mobileKeyPrefixBuilder;

  /// Creates a standard table header.
  const TTableHeader(
    this.text, {
    this.map,
    this.builder,
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    this.key,
    this.filterType,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    this.widthEstimator,
    this.keyValuesBuilder,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
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

  /// Converts this header into one or more [TKeyValue] items for mobile card representations.
  List<TKeyValue> toKeyValues(BuildContext ctx, TListItem<T, K> item, int index) {
    if (flattenOnMobile && keyValuesBuilder != null) {
      final subItems = keyValuesBuilder!(item.data);
      if (mobileKeyPrefixBuilder != null) {
        return subItems
            .map((kv) => TKeyValue(
                  mobileKeyPrefixBuilder!(text, kv.key),
                  value: kv.value,
                  widget: kv.widget,
                  icon: kv.icon,
                  width: kv.width,
                  alignment: kv.alignment ?? alignment,
                  minWidth: kv.minWidth ?? minWidth,
                  maxWidth: kv.maxWidth ?? maxWidth,
                ))
            .toList();
      }
      return subItems;
    }

    final estimatedWidth = widthEstimator?.call(item.data);
    final effectiveMinWidth = minWidth ?? estimatedWidth;

    return [
      TKeyValue(
        text,
        value: getValue(item.data),
        widget: builder != null ? builder!(ctx, item, index) : null,
        width: effectiveMinWidth,
        minWidth: effectiveMinWidth,
        maxWidth: maxWidth,
        alignment: alignment,
      ),
    ];
  }

  /// Creates a header using only a mapping function.
  const TTableHeader.map(
    this.text,
    this.map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    this.key,
    this.filterType,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    this.widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
  })  : builder = null,
        keyValuesBuilder = null;

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
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = null,
        key = null,
        filterType = null,
        filterable = false,
        filterOperators = null,
        filterItems = null,
        filterDef = null,
        widthEstimator = widthEstimator ?? ((_) => width),
        minWidth = minWidth ?? (width + 36),
        maxWidth = maxWidth ?? (flex != null ? null : (width + 36)),
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
    dynamic Function(T)? icon,
    TVariant? type,
    TVariant? Function(T)? typeBuilder,
    TSize size = TChipSize.sm,
    void Function()? Function(T)? onTap,
    this.key,
    this.filterType,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : widthEstimator = widthEstimator ??
            ((data) {
              final text = map?.call(data)?.toString() ?? '';
              if (text.isEmpty) return 0.0;
              final hasIcon = icon != null && icon(data) != null;
              return TTableTheme.measureTextWidth(text) + 24.0 + (hasIcon ? 18.0 : 0.0);
            }),
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          return TChip(
            text: map?.call(item.data).toString(),
            icon: icon?.call(item.data),
            color: color?.call(item.data),
            type: typeBuilder?.call(item.data) ?? type,
            size: size,
            onTap: onTap?.call(item.data),
            padding: isDense ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : null,
          );
        });

  /// Creates a header for displaying multiple chips in a [Wrap] with auto-calculated width estimation.
  ///
  /// Each [TChip] can define its own visual attributes ([TChip.solid], [TChip.tonal], [TChip.outline],
  /// [TChip.softOutline], [TChip.text], custom [TChip.icon], [TChip.color], [TChip.onTap]).
  /// Any properties omitted on individual chips automatically inherit the common header configuration
  /// ([type], [color], [size], [spacing], [runSpacing]).
  TTableHeader.chips(
    this.text,
    List<TChip> Function(T) builder, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    Color? Function(T data, String chipText)? color,
    dynamic Function(T data, String chipText)? icon,
    TVariant? type,
    TVariant? Function(T data, String chipText)? typeBuilder,
    TSize size = TChipSize.sm,
    double spacing = 4.0,
    double runSpacing = 4.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.center,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    void Function(String chipText)? Function(T data)? onTap,
    this.key,
    this.filterType,
    this.filterable = false,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = ((data) => builder(data).map((c) => c.text).where((s) => s != null && s.isNotEmpty).join(', ')),
        widthEstimator = widthEstimator ??
            ((data) {
              final items = builder(data);
              if (items.isEmpty) return 0.0;
              double totalWidth = 0.0;
              for (int i = 0; i < items.length; i++) {
                final chip = items[i];
                final text = chip.text ?? '';
                final hasIcon = chip.icon != null || (icon != null && icon(data, text) != null);
                final hasTrailing = chip.trailing != null;
                final textWidth = text.isNotEmpty ? TTableTheme.measureTextWidth(text) : 0.0;
                final iconWidth = hasIcon ? 18.0 : 0.0;
                final trailingWidth = hasTrailing ? 18.0 : 0.0;
                totalWidth += textWidth + 24.0 + iconWidth + trailingWidth;
              }
              if (items.length > 1) {
                totalWidth += (items.length - 1) * spacing;
              }
              return totalWidth;
            }),
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          final items = builder(item.data);
          if (items.isEmpty) return const SizedBox.shrink();

          final effectiveSpacing = isDense ? spacing * 0.75 : spacing;
          final effectiveRunSpacing = isDense ? runSpacing * 0.75 : runSpacing;

          return Wrap(
            spacing: effectiveSpacing,
            runSpacing: effectiveRunSpacing,
            crossAxisAlignment: crossAxisAlignment,
            alignment: wrapAlignment,
            children: [
              for (final chip in items)
                TChip(
                  key: chip.key,
                  text: chip.text,
                  icon: chip.icon ?? icon?.call(item.data, chip.text ?? ''),
                  trailing: chip.trailing,
                  color: chip.color ?? color?.call(item.data, chip.text ?? ''),
                  background: chip.background,
                  textColor: chip.textColor,
                  type: chip.type ?? typeBuilder?.call(item.data, chip.text ?? '') ?? type,
                  size: chip.size != TChipSize.md ? chip.size : size,
                  onTap: chip.onTap ?? (onTap?.call(item.data) != null ? () => onTap!(item.data)!(chip.text ?? '') : null),
                  padding: isDense ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : chip.padding,
                  borderRadius: chip.borderRadius,
                ),
            ],
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
    this.key,
    this.filterType = TFilterType.text,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = map,
        widthEstimator = widthEstimator ?? ((_) => 85.0),
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
    this.key,
    this.filterType = TFilterType.number,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = map,
        widthEstimator = widthEstimator ?? ((_) => itemCount * itemSize + (itemCount > 1 ? (itemCount - 1) * spacing : 0.0) + 4.0),
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

  /// Creates a header for displaying progress bars in table cells using [TProgressBar].
  TTableHeader.progress(
    this.text,
    double? Function(T) map, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    double progressMaxWidth = 200,
    double height = 4.0,
    bool showPercentage = true,
    String? Function(T)? valueText,
    TProgressValuePosition valuePosition = TProgressValuePosition.topRight,
    Color? color,
    Color? Function(double value, double percentage)? colorBuilder,
    Color? backgroundColor,
    bool flowing = false,
    TextStyle? valueStyle,
    this.key,
    this.filterType = TFilterType.number,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = map,
        widthEstimator = widthEstimator ??
            _defaultProgressWidthEstimator(
              map: map,
              valueText: valueText,
              showPercentage: showPercentage,
              valuePosition: valuePosition,
              progressMaxWidth: progressMaxWidth,
            ),
        builder = ((ctx, item, __) {
          final scope = TTableScope.maybeOf(ctx);
          final isDense = scope?.dense ?? false;
          final val = map(item.data) ?? 0.0;
          final customValueText = valueText?.call(item.data);

          final contentStyle = scope?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
          final fallbackValStyle = TextStyle(
            fontSize: isDense ? 10 : 11.0,
            fontWeight: FontWeight.w400,
          );
          final defaultValStyle = contentStyle?.adjust(sizeMultiplier: 0.8, weightStep: 1, clearColor: true) ?? fallbackValStyle;
          final effectiveValueStyle = valueStyle != null ? defaultValStyle.merge(valueStyle) : defaultValStyle;

          final effectiveEstimator = widthEstimator ??
              _defaultProgressWidthEstimator(
                map: map,
                valueText: valueText,
                showPercentage: showPercentage,
                valuePosition: valuePosition,
                progressMaxWidth: progressMaxWidth,
              );
          final estimatedWidth = effectiveEstimator(item.data);

          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: estimatedWidth),
            child: TProgressBar(
              value: val,
              height: isDense ? (height * 0.75).clamp(3.0, 12.0) : height,
              showPercentage: showPercentage,
              valueText: customValueText,
              valuePosition: valuePosition,
              color: color,
              colorBuilder: colorBuilder,
              backgroundColor: backgroundColor,
              flowing: flowing,
              valueStyle: effectiveValueStyle,
            ),
          );
        });

  /// Creates a header for displaying multiple widgets in a horizontal row/wrap in table cells.
  TTableHeader.row(
    this.text,
    List<Widget> Function(T) builder, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    double spacing = 8.0,
    double runSpacing = 4.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.center,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    this.key,
    this.filterType,
    this.filterable = false,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    this.widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = null,
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          final widgets = builder(item.data);
          if (widgets.isEmpty) return const SizedBox.shrink();

          return Wrap(
            spacing: isDense ? spacing * 0.75 : spacing,
            runSpacing: isDense ? runSpacing * 0.75 : runSpacing,
            crossAxisAlignment: crossAxisAlignment,
            alignment: wrapAlignment,
            children: widgets,
          );
        });

  /// Creates a header for displaying multiple widgets vertically in a column in table cells.
  TTableHeader.column(
    this.text,
    List<Widget> Function(T) builder, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    double spacing = 4.0,
    this.key,
    this.filterType,
    this.filterable = false,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    this.widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = null,
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          final widgets = builder(item.data);
          if (widgets.isEmpty) return const SizedBox.shrink();

          final effectiveSpacing = isDense ? spacing * 0.75 : spacing;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              for (int i = 0; i < widgets.length; i++) ...[
                if (i > 0) SizedBox(height: effectiveSpacing),
                widgets[i],
              ],
            ],
          );
        });

  /// Creates a header for displaying key-value pairs in table cells.
  TTableHeader.keyValues(
    this.text,
    List<TKeyValue> Function(T) builder, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    bool inline = true,
    double spacing = 4.0,
    TextStyle? keyStyle,
    TextStyle? valueStyle,
    this.flattenOnMobile = true,
    this.mobileKeyPrefixBuilder,
    this.key,
    this.filterType,
    this.filterable = false,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
  })  : map = null,
        keyValuesBuilder = builder,
        widthEstimator = widthEstimator ??
            ((data) {
              final items = builder(data);
              if (items.isEmpty) return 0.0;
              final effectiveKeyStyle = keyStyle ??
                  TTableTheme.fallbackTextStyle.adjust(
                    sizeMultiplier: 0.8,
                    weightStep: 1,
                  );
              final effectiveValueStyle = valueStyle ?? TTableTheme.fallbackTextStyle;
              double maxWidth = 0.0;
              for (int i = 0; i < items.length; i++) {
                final item = items[i];
                final keyText = inline ? '${item.key}: ' : item.key;
                final valText = item.value ?? '—';
                final keyWidth = TTableTheme.measureTextWidth(keyText, effectiveKeyStyle);
                final valWidth = TTableTheme.measureTextWidth(valText, effectiveValueStyle);
                final iconWidth = item.icon != null ? 20.0 : 0.0;
                final rowWidth = inline ? (iconWidth + keyWidth + valWidth) : math.max(iconWidth + keyWidth, valWidth);
                if (rowWidth > maxWidth) maxWidth = rowWidth;
              }
              return maxWidth;
            }),
        builder = ((ctx, item, __) {
          final scope = TTableScope.maybeOf(ctx);
          final isDense = scope?.dense ?? false;
          final items = builder(item.data);
          if (items.isEmpty) return const SizedBox.shrink();

          final defaultValueStyle = scope?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
          final defaultKeyStyle = defaultValueStyle?.adjust(
            sizeMultiplier: 0.8,
            color: defaultValueStyle.color?.adaptiveContrast(ctx, -0.35),
            weightStep: 1,
          );

          final effectiveSpacing = isDense ? spacing * 0.75 : spacing;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) SizedBox(height: effectiveSpacing),
                if (inline)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (items[i].icon != null) ...[
                        items[i].icon!,
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${items[i].key}: ',
                        style: keyStyle ?? defaultKeyStyle,
                      ),
                      if (items[i].widget != null)
                        Flexible(child: items[i].widget!)
                      else
                        Flexible(
                          child: Text(
                            items[i].value ?? '—',
                            style: valueStyle ?? defaultValueStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  )
                else ...[
                  Text(
                    items[i].key,
                    style: keyStyle ?? defaultKeyStyle,
                  ),
                  if (items[i].widget != null)
                    items[i].widget!
                  else
                    Text(
                      items[i].value ?? '—',
                      style: valueStyle ?? defaultValueStyle,
                    ),
                ],
              ],
            ],
          );
        });

  /// Creates a header for displaying a list of values with hierarchical font sizes
  /// and adaptive contrast in table cells, automatically flattened on mobile card views.
  ///
  /// Hierarchical styling by index:
  /// - 1st value (index 0): size multiplier `1.015`, color same as `contentTextStyle`
  /// - 2nd value (index 1): size multiplier `0.85`, color `adaptiveContrast(ctx, -0.5)`
  /// - 3rd value (index 2): size multiplier `0.7`, color `adaptiveContrast(ctx, -0.85)`
  /// - 4th+ values (index >= 3): size multiplier `0.55`, color `adaptiveContrast(ctx, -1.0)`
  TTableHeader.values(
    this.text,
    List<TKeyValue> Function(T) builder, {
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    double spacing = 2.0,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    this.flattenOnMobile = true,
    this.mobileKeyPrefixBuilder,
    this.key,
    this.filterType,
    this.filterable = false,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
  })  : map = null,
        keyValuesBuilder = builder,
        widthEstimator = widthEstimator ??
            ((data) {
              final items = builder(data);
              if (items.isEmpty) return 0.0;
              double maxWidth = 0.0;
              for (int i = 0; i < items.length; i++) {
                final kv = items[i];
                final displayValue = kv.value ?? kv.key;
                final double sizeMultiplier = switch (i) {
                  0 => 1.015,
                  1 => 0.85,
                  2 => 0.7,
                  _ => 0.55,
                };
                final style = TTableTheme.fallbackTextStyle.adjust(sizeMultiplier: sizeMultiplier);
                var itemWidth = TTableTheme.measureTextWidth(displayValue, style);
                if (kv.icon != null) itemWidth += 20.0;
                if (itemWidth > maxWidth) maxWidth = itemWidth;
              }
              return maxWidth;
            }),
        builder = ((ctx, item, __) {
          final scope = TTableScope.maybeOf(ctx);
          final isDense = scope?.dense ?? false;
          final items = builder(item.data);
          if (items.isEmpty) return const SizedBox.shrink();

          final contentStyle =
              scope?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle ?? const TextStyle(fontSize: 13.6);

          final effectiveSpacing = isDense ? spacing * 0.75 : spacing;

          TextStyle? getLevelStyle(int index) {
            final double sizeMultiplier;
            final double? contrast;

            switch (index) {
              case 0:
                sizeMultiplier = 1.015;
                contrast = null;
                break;
              case 1:
                sizeMultiplier = 0.85;
                contrast = -0.5;
                break;
              case 2:
                sizeMultiplier = 0.7;
                contrast = -0.85;
                break;
              default:
                sizeMultiplier = 0.55;
                contrast = -1.0;
                break;
            }

            final baseColor = contentStyle.color;
            final targetColor = (contrast != null && baseColor != null) ? baseColor.adaptiveContrast(ctx, contrast) : baseColor;

            return contentStyle.adjust(
              sizeMultiplier: sizeMultiplier,
              color: targetColor,
            );
          }

          Widget buildItemWidget(TKeyValue kv, int index) {
            final levelStyle = getLevelStyle(index);
            final displayValue = kv.value ?? kv.key;

            Widget content;
            if (kv.widget != null) {
              content = DefaultTextStyle(
                style: levelStyle ?? const TextStyle(),
                child: kv.widget!,
              );
            } else {
              content = Text(
                displayValue,
                style: levelStyle,
                overflow: TextOverflow.ellipsis,
              );
            }

            if (kv.icon != null) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  kv.icon!,
                  const SizedBox(width: 4),
                  Flexible(child: content),
                ],
              );
            }

            return content;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) SizedBox(height: effectiveSpacing),
                buildItemWidget(items[i], i),
              ],
            ],
          );
        });

  /// Creates a header for displaying a title and optional subtitle with leading icon using [TTile].
  TTableHeader.tile(
    this.text,
    String? Function(T) title, {
    String? Function(T)? subtitle,
    dynamic Function(T)? icon,
    dynamic Function(T)? leading,
    Color? Function(T)? iconColor,
    Color? Function(T)? iconBackgroundColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    double? iconSize,
    EdgeInsetsGeometry? iconPadding,
    BorderRadius? iconBorderRadius,
    double spacing = 10.0,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Widget Function(T)? trailing,
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    this.key,
    this.filterType = TFilterType.text,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = title,
        widthEstimator = widthEstimator ??
            ((data) {
              final t = title(data);
              final sub = subtitle?.call(data);
              final tWidth = t != null ? TTableTheme.measureTextWidth(t) : 0.0;
              final sWidth = sub != null ? TTableTheme.measureTextWidth(sub) * 0.85 : 0.0;
              final textWidth = math.max(tWidth, sWidth);
              final lead = leading?.call(data) ?? icon?.call(data);
              final hasIcon = lead != null;
              final iconWidth = hasIcon ? ((iconSize ?? (lead is Widget ? 80.0 : 20.0)) + 12.0 + spacing) : 0.0;
              final trailingWidth = trailing != null ? 30.0 : 0.0;
              return iconWidth + textWidth + trailingWidth;
            }),
        builder = ((ctx, item, __) {
          final scope = TTableScope.maybeOf(ctx);
          final isDense = scope?.dense ?? false;
          final t = title(item.data);
          final sub = subtitle?.call(item.data);
          final lead = leading?.call(item.data) ?? icon?.call(item.data);
          final icColor = iconColor?.call(item.data);
          final icBgColor = iconBackgroundColor?.call(item.data);
          final tr = trailing?.call(item.data);

          final contentStyle = scope?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
          final defaultTitleStyle = contentStyle?.adjust(
            sizeMultiplier: 1.015,
          );
          final defaultSubtitleStyle = contentStyle?.adjust(
            color: contentStyle.color?.adaptiveContrast(ctx, -0.5),
            sizeMultiplier: 0.85,
          );

          return TTile(
            title: t,
            subtitle: sub,
            icon: lead,
            iconColor: icColor,
            iconBackgroundColor: icBgColor,
            iconSize: isDense ? (iconSize != null ? iconSize * 0.8 : 16.0) : (iconSize ?? 20.0),
            iconPadding: isDense ? const EdgeInsets.all(6) : iconPadding,
            iconBorderRadius: iconBorderRadius,
            spacing: isDense ? spacing * 0.75 : spacing,
            crossAxisAlignment: crossAxisAlignment,
            titleStyle: titleStyle ?? defaultTitleStyle,
            subtitleStyle: subtitleStyle ?? defaultSubtitleStyle,
            trailing: tr,
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
    this.key,
    this.filterType = TFilterType.dateTime,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    this.widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
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
    this.key,
    this.filterType = TFilterType.boolean,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    Color? color,
    Color? inactiveColor,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = get,
        widthEstimator = widthEstimator ?? ((_) => 48.0),
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          final val = get(item.data) ?? false;
          final isOff = disabled || (isDisabled?.call(item.data) ?? false);

          return TSwitch(
            value: val,
            disabled: isOff,
            size: isDense ? TInputSize.xs : TInputSize.sm,
            color: color,
            inactiveColor: inactiveColor,
            onValueChanged: isOff || set == null ? null : (newVal) => set(item.data, newVal ?? false),
          );
        });

  /// Creates a header for row actions.
  ///
  /// Automatically separates items into flat inline buttons (when [TButtonGroupItem.showFlat] is true)
  /// and an overflow dropdown menu (triple-dots icon) for remaining actions.
  TTableHeader.actions(
    List<TButtonGroupItem> Function(TListItem<T, K>) builder, {
    this.text = "Actions",
    this.alignment = Alignment.center,
    this.flex,
    this.minWidth,
    double? maxWidth,
    int? count,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = null,
        key = null,
        filterType = null,
        filterable = false,
        filterOperators = null,
        filterItems = null,
        filterDef = null,
        widthEstimator = widthEstimator ?? ((_) => (count != null ? (40.0 * count + 16.0) : 75.0)),
        maxWidth = maxWidth != null
            ? maxWidth.clamp(75.0, 300.0)
            : count != null
                ? (40.0 * count + 36.0).clamp(75.0, 300.0)
                : null,
        builder = ((ctx, item, __) {
          final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
          final allItems = builder(item);
          if (allItems.isEmpty) return const SizedBox.shrink();

          final hasExplicitFlat = allItems.any((b) => b.showFlat);
          final hasExplicitChild = allItems.any((b) => b.child != null);

          final List<TButtonGroupItem> effectiveItems;
          if (!hasExplicitFlat && !hasExplicitChild && allItems.length <= 2) {
            effectiveItems = allItems;
          } else if (!hasExplicitFlat && !hasExplicitChild && allItems.length > 2) {
            effectiveItems = [
              TButtonGroupItem(
                child: _buildActionDropdownMenu(ctx, allItems, isDense),
              ),
            ];
          } else {
            final flatButtons = <TButtonGroupItem>[];
            final menuButtons = <TButtonGroupItem>[];

            for (final btn in allItems) {
              if (btn.showFlat || btn.child != null) {
                flatButtons.add(btn);
              } else {
                menuButtons.add(btn);
              }
            }

            effectiveItems = <TButtonGroupItem>[...flatButtons];
            if (menuButtons.isNotEmpty) {
              effectiveItems.add(TButtonGroupItem(
                child: _buildActionDropdownMenu(ctx, menuButtons, isDense),
              ));
            }
          }

          return TButtonGroup(
            type: TButtonGroupType.icon,
            alignment: WrapAlignment.end,
            size: isDense ? TButtonSize.sm.copyWith(hPad: 4, vPad: 2) : TButtonSize.sm,
            items: effectiveItems,
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
    this.key,
    this.filterType,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    this.widthEstimator,
    this.flattenOnMobile = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : map = get,
        builder = ((ctx, item, index) {
          final cellScope = TTableCellScope.maybeScopeOf(ctx);
          final activeCursor = cellScope?.activeCellNotifier ?? TTableCellScope.maybeOf(ctx);
          final data = item.data;
          final cellKey = "${item.key}_$text";
          final colors = ctx.colors;
          final cellError = error?.call(data) ?? cellScope?.getError(data, text, cellKey);
          final hasError = cellError != null && cellError.isNotEmpty;
          final textStyle = TTableScope.maybeOf(ctx)?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
          Widget buildDisplay() {
            if (displayBuilder != null) {
              return displayBuilder(ctx, data);
            }

            final rawVal = get(data);
            final displayStr = rawVal?.toString() ?? '';
            final isEmpty = displayStr.trim().isEmpty;

            if (hasError) {
              return TTooltip(
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
                overflow: TextOverflow.ellipsis,
              );
            }

            return Text(
              displayStr,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            );
          }

          Widget buildEditor() {
            final editorWidget = builder(ctx, data);
            if (hasError) {
              return TTooltip(
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
              child: ValueListenableBuilder(
                valueListenable: activeCursor,
                builder: (ctx, active, _) => active == cellKey ? buildEditor() : buildDisplay(),
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
    String? key,
    TFilterType filterType = TFilterType.text,
    bool filterable = true,
    List<TFilterOperator>? filterOperators,
    List<dynamic>? filterItems,
    TFilterDef<T>? filterDef,
    double Function(T data)? widthEstimator,
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
          key: key,
          filterType: filterType,
          filterable: filterable,
          filterOperators: filterOperators,
          filterItems: filterItems,
          filterDef: filterDef,
          widthEstimator: widthEstimator ??
              ((data) {
                final v = get(data);
                final str = v?.toString() ?? placeholder ?? '';
                final w = str.isNotEmpty ? TTableTheme.measureTextWidth(str) : 0.0;
                return math.max(w, 80.0);
              }),
          builder: (ctx, data) {
            final style = TTableScope.maybeOf(ctx)?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
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
    String? key,
    TFilterType filterType = TFilterType.number,
    bool filterable = true,
    List<TFilterOperator>? filterOperators,
    List<dynamic>? filterItems,
    TFilterDef<T>? filterDef,
    double Function(T data)? widthEstimator,
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
          key: key,
          filterType: filterType,
          filterable: filterable,
          filterOperators: filterOperators,
          filterItems: filterItems,
          filterDef: filterDef,
          widthEstimator: widthEstimator ??
              ((data) {
                final v = get(data);
                final str = v?.toString() ?? placeholder ?? '';
                final w = str.isNotEmpty ? TTableTheme.measureTextWidth(str) : 0.0;
                return math.max(w + 56.0, 90.0);
              }),
          builder: (ctx, data) {
            final style = TTableScope.maybeOf(ctx)?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
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

  /// Automatically generates a list of [TFilterDef]s from the given [headers]
  /// and optional [sampleItems] to infer field data types.
  static List<TFilterDef<T>> autoGenerateFilterDefs<T, K>(
    List<TTableHeader<T, K>> headers, {
    List<T>? sampleItems,
  }) {
    final defs = <TFilterDef<T>>[];

    for (final header in headers) {
      if (!header.filterable || header.map == null) continue;

      if (header.filterDef != null) {
        final def = header.filterDef!;
        final effectiveLabel = def.label.isNotEmpty ? def.label : header.text;
        final effectiveKey = def.key.isNotEmpty ? def.key : (header.key ?? _toCamelCase(header.text));
        defs.add(def.copyWith(
          label: effectiveLabel,
          key: effectiveKey,
          getter: def.map ?? (x) => header.map?.call(x),
        ));
        continue;
      }

      final key = header.key ?? _toCamelCase(header.text);
      TFilterType type = header.filterType ?? TFilterType.text;

      // If filterType was not explicitly provided on header, infer from sample items
      if (header.filterType == null && sampleItems != null && sampleItems.isNotEmpty) {
        dynamic sampleVal;
        for (final item in sampleItems) {
          try {
            sampleVal = header.map!(item);
            if (sampleVal != null) break;
          } catch (_) {}
        }

        if (sampleVal is int || sampleVal is double || sampleVal is num) {
          type = TFilterType.number;
        } else if (sampleVal is bool) {
          type = TFilterType.boolean;
        } else if (sampleVal is DateTime) {
          type = TFilterType.dateTime;
        } else if (sampleVal is Enum) {
          type = TFilterType.enumFilter;
        } else {
          type = TFilterType.text;
        }
      }

      switch (type) {
        case TFilterType.text:
          defs.add(TFilter.text<T>(
            header.text,
            key: key,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
        case TFilterType.number:
          defs.add(TFilter.number<T>(
            header.text,
            key: key,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
        case TFilterType.dateTime:
          defs.add(TFilter.dateTime<T>(
            header.text,
            key: key,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
        case TFilterType.date:
          defs.add(TFilter.date<T>(
            header.text,
            key: key,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
        case TFilterType.boolean:
          defs.add(TFilter.boolean<T>(
            header.text,
            key: key,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
        case TFilterType.enumFilter:
          if (header.filterItems != null && header.filterItems is List<Enum>) {
            defs.add(TFilter.enumFilter<T>(
              header.text,
              key: key,
              values: header.filterItems as List<Enum>,
              getter: (x) => header.map?.call(x),
              operators: header.filterOperators,
            ));
          } else {
            defs.add(TFilter.text<T>(
              header.text,
              key: key,
              getter: (x) => header.map?.call(x),
              operators: header.filterOperators,
            ));
          }
        case TFilterType.select:
          if (header.filterItems != null) {
            defs.add(TFilter.select<T>(
              header.text,
              key: key,
              items: header.filterItems,
              itemText: (x) => x.toString(),
              itemValue: (x) => x,
              getter: (x) => header.map?.call(x),
              operators: header.filterOperators,
            ));
          } else {
            defs.add(TFilter.text<T>(
              header.text,
              key: key,
              getter: (x) => header.map?.call(x),
              operators: header.filterOperators,
            ));
          }
        case TFilterType.guid:
          defs.add(TFilter.guid<T>(
            header.text,
            key: key,
            items: header.filterItems,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
      }
    }

    return defs;
  }

  static String _toCamelCase(String text) {
    final words = text.trim().split(RegExp(r'[\s_\-]+'));
    if (words.isEmpty) return '';
    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join();
    return '$first$rest';
  }

  static double Function(T data) _defaultProgressWidthEstimator<T>({
    required double? Function(T) map,
    required String? Function(T)? valueText,
    required bool showPercentage,
    required TProgressValuePosition valuePosition,
    required double progressMaxWidth,
  }) {
    return (data) {
      final val = map(data) ?? 0.0;
      final customValText = valueText?.call(data);
      String displayVal = '';
      if (customValText != null && showPercentage) {
        displayVal = '$customValText (${(val * 100).toInt()}%)';
      } else if (customValText != null) {
        displayVal = customValText;
      } else if (showPercentage) {
        displayVal = '${(val * 100).toInt()}%';
      }
      final valWidth = displayVal.isNotEmpty ? TTableTheme.measureTextWidth(displayVal) : 0.0;
      final isInline = valuePosition == TProgressValuePosition.afterProgress || valuePosition == TProgressValuePosition.beforeProgress;
      final minBarWidth = isInline ? 60.0 : 80.0;
      return math.min(progressMaxWidth, isInline ? (valWidth + minBarWidth + 16.0) : math.max(valWidth, minBarWidth));
    };
  }

  static Widget _buildActionDropdownMenu(BuildContext ctx, List<TButtonGroupItem> buttons, bool isDense) {
    final dropdownItems = buttons.map((button) {
      return TDropdownItem(
        icon: button.icon,
        text: button.tooltip ?? button.text ?? '',
        color: button.color,
        onTap: () {
          if (button.onPressed != null) {
            button.onPressed!(TButtonPressOptions(stopLoading: () {}));
          } else if (button.onTap != null) {
            button.onTap!();
          }
        },
      );
    }).toList();

    return TDropdown(
      items: dropdownItems,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.more_vert_rounded,
            size: isDense ? 16 : 18,
            color: ctx.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
