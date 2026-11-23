import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'table_header_cells.dart';
part 'table_header_editable.dart';
part 'table_header_filters.dart';

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
/// - [TTableHeader.stacked]: Renders fixed-height sub-rows via [TSubRows], aligned across columns
/// - [TTableHeader.keyValues]: Renders a list of [TKeyValue] pairs
/// - [TTableHeader.values]: Renders a hierarchical list of values (cascading font size & contrast)
/// - [TTableHeader.image]: Renders an image from URL
/// - [TTableHeader.chip]: Renders a [TChip]
/// - [TTableHeader.statusChip]: Renders a [TChip] that opens a dropdown of [TStatusOption]s and reports the pick
/// - [TTableHeader.statusEnum]: [TTableHeader.statusChip] quick setup from an enum's values plus color/icon getters
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

  /// Whether this column is listed in the default key-value details of [TCrudTable].
  /// Defaults to false for [TTableHeader.image] and [TTableHeader.actions], which the
  /// details header already shows; set to false on any other redundant column.
  final bool showInDetails;

  /// Optional prefix or formatting hook when flattened on mobile (e.g. `(header, key) => '$header: $key'`).
  final String Function(String headerText, String childKey)? mobileKeyPrefixBuilder;

  /// Estimated height of this column's content in a comfortable row, used to estimate the page size before any
  /// row has been rendered. Null for single-line content (text, chip, switch, ...); set for columns that grow
  /// the row, such as images and multi-value cells.
  final double? estimatedHeight;

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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.estimatedHeight,
  });

  /// Whether the cell skips the table's default horizontal cell padding and fills its full column width.
  ///
  /// Used by [TTableHeader.stacked] so dividers of adjacent columns connect.
  bool get fullBleedCell => false;

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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
  })  : estimatedHeight = null,
        builder = null,
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
    this.showInDetails = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = width,
        map = null,
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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        widthEstimator = widthEstimator ??
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

  /// Creates a status column: a [TChip] showing the current value's text, icon and color, which opens a dropdown
  /// of every [TStatusOption] when pressed.
  ///
  /// [options] maps each enum value to its text, icon and color. [get] reads the current value from the row and
  /// [onChanged] receives the row and the newly picked value so the caller can patch it (e.g. send a PATCH request).
  /// It returns (or completes with) true to accept the change, which updates the chip immediately; false keeps the
  /// old value. The chip is disabled while a returned future is pending. When [onChanged] is null, or [disabled]/[isDisabled] is true, the chip is read-only.
  ///
  /// ```dart
  /// TTableHeader.statusChip<Order, int, OrderStatus>(
  ///   'Status',
  ///   (o) => o.status,
  ///   [
  ///     TStatusOption(OrderStatus.pending, 'Pending', icon: HugeIcons.strokeRoundedClock01, color: Colors.orange),
  ///     TStatusOption(OrderStatus.done, 'Done', icon: HugeIcons.strokeRoundedCheckmarkCircle02, color: Colors.green),
  ///   ],
  ///   onChanged: (order, status) => api.patchStatus(order.id, status), // Future<bool>
  /// )
  /// ```
  static TTableHeader<T, K> statusChip<T, K, V>(
    String text,
    V? Function(T) get,
    List<TStatusOption<V>> options, {
    FutureOr<bool> Function(T data, V value)? onChanged,
    bool disabled = false,
    bool Function(T data)? isDisabled,
    TVariant? type,
    TSize size = TChipSize.sm,
    int? flex,
    double? minWidth,
    double? maxWidth,
    Alignment? alignment,
    String? key,
    TFilterType? filterType = TFilterType.enumFilter,
    bool filterable = true,
    List<TFilterOperator>? filterOperators,
    List<V>? filterItems,
    TFilterDef<T>? filterDef,
    double Function(T data)? widthEstimator,
    bool flattenOnMobile = false,
    bool showInDetails = true,
    String Function(String headerText, String childKey)? mobileKeyPrefixBuilder,
    List<TKeyValue> Function(T data)? keyValuesBuilder,
  }) =>
      TTableHeader<T, K>._statusChip(
        text,
        get,
        [for (final o in options) TStatusOption<dynamic>(o.value, o.text, icon: o.icon, color: o.color)],
        onChanged: onChanged == null ? null : (data, value) => onChanged(data, value as V),
        disabled: disabled,
        isDisabled: isDisabled,
        type: type,
        size: size,
        flex: flex,
        minWidth: minWidth,
        maxWidth: maxWidth,
        alignment: alignment,
        key: key,
        filterType: filterType,
        filterable: filterable,
        filterOperators: filterOperators,
        filterItems: filterItems ?? [for (final o in options) o.value],
        filterDef: filterDef,
        widthEstimator: widthEstimator,
        flattenOnMobile: flattenOnMobile,
        showInDetails: showInDetails,
        mobileKeyPrefixBuilder: mobileKeyPrefixBuilder,
        keyValuesBuilder: keyValuesBuilder,
      );

  /// Quick setup of [statusChip] for an enum: pass `MyEnum.values` and read text, icon and color from
  /// getters (usually an extension on the enum). [label] defaults to the humanized enum name.
  ///
  /// ```dart
  /// extension OrderStatusX on OrderStatus {
  ///   Color get color => switch (this) { OrderStatus.pending => Colors.orange, OrderStatus.done => Colors.green };
  ///   IconData get icon => switch (this) { OrderStatus.pending => Icons.schedule, OrderStatus.done => Icons.check };
  /// }
  ///
  /// TTableHeader.statusEnum<Order, int, OrderStatus>(
  ///   'Status', (o) => o.status, OrderStatus.values,
  ///   color: (s) => s.color, icon: (s) => s.icon,
  ///   onChanged: (o, s) => api.patchStatus(o.id, s),
  /// )
  /// ```
  static TTableHeader<T, K> statusEnum<T, K, V extends Enum>(
    String text,
    V? Function(T) get,
    List<V> values, {
    String Function(V value)? label,
    dynamic Function(V value)? icon,
    Color? Function(V value)? color,
    FutureOr<bool> Function(T data, V value)? onChanged,
    bool disabled = false,
    bool Function(T data)? isDisabled,
    TVariant? type,
    TSize size = TChipSize.sm,
    int? flex,
    double? minWidth,
    double? maxWidth,
    Alignment? alignment,
    String? key,
    bool filterable = true,
  }) =>
      statusChip<T, K, V>(
        text,
        get,
        TStatusOption.fromValues<V>(values, text: label, icon: icon, color: color),
        onChanged: onChanged,
        disabled: disabled,
        isDisabled: isDisabled,
        type: type,
        size: size,
        flex: flex,
        minWidth: minWidth,
        maxWidth: maxWidth,
        alignment: alignment,
        key: key,
        filterable: filterable,
      );

  TTableHeader._statusChip(
    this.text,
    Object? Function(T) get,
    List<TStatusOption<dynamic>> options, {
    FutureOr<bool> Function(T data, dynamic value)? onChanged,
    bool disabled = false,
    bool Function(T data)? isDisabled,
    TVariant? type,
    TSize size = TChipSize.sm,
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
    this.key,
    this.filterType = TFilterType.enumFilter,
    this.filterable = true,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        map = ((data) => TStatusOption.find(options, get(data))?.text ?? get(data)),
        widthEstimator = widthEstimator ??
            ((data) {
              final option = TStatusOption.find(options, get(data));
              final label = option?.text ?? '';
              final hasPicker = onChanged != null && !disabled && !(isDisabled?.call(data) ?? false);
              return TTableTheme.measureTextWidth(label) + 24.0 + (option?.icon != null ? 18.0 : 0.0) + (hasPicker ? 18.0 : 0.0);
            }),
        builder = _statusChipCellBuilder<T, K>(
          get: get,
          options: options,
          onChanged: onChanged,
          disabled: disabled,
          isDisabled: isDisabled,
          type: type,
          size: size,
        );

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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        map = ((data) => builder(data).map((c) => c.text).where((s) => s != null && s.isNotEmpty).join(', ')),
        widthEstimator = widthEstimator ?? _chipsWidthEstimator<T>(builder: builder, icon: icon, spacing: spacing),
        builder = _chipsCellBuilder<T, K>(
            builder: builder,
            spacing: spacing,
            runSpacing: runSpacing,
            crossAxisAlignment: crossAxisAlignment,
            wrapAlignment: wrapAlignment,
            icon: icon,
            color: color,
            typeBuilder: typeBuilder,
            type: type,
            size: size,
            onTap: onTap);

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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        map = map,
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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        map = map,
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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        map = map,
        widthEstimator = widthEstimator ??
            _defaultProgressWidthEstimator(
              map: map,
              valueText: valueText,
              showPercentage: showPercentage,
              valuePosition: valuePosition,
              progressMaxWidth: progressMaxWidth,
            ),
        builder = _progressCellBuilder<T, K>(
            map: map,
            valueText: valueText,
            showPercentage: showPercentage,
            valuePosition: valuePosition,
            progressMaxWidth: progressMaxWidth,
            widthEstimator: widthEstimator,
            height: height,
            color: color,
            colorBuilder: colorBuilder,
            backgroundColor: backgroundColor,
            flowing: flowing,
            valueStyle: valueStyle);

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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        map = null,
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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = 36,
        map = null,
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

  /// Creates a header that stacks several fixed-height sub-rows inside one table row.
  ///
  /// Use it for grouped rows (one item = one card holding several sub-rows).
  /// Columns built with the same [rowHeight] line up sub-row by sub-row, so no
  /// colspan/rowspan is needed. Use a plain column (e.g. [TTableHeader.new]) for the
  /// group label cell; it stays vertically centered across the whole stack.
  ///
  /// The cell is rendered edge to edge ([fullBleedCell]) and each sub-row pads its
  /// own content by [contentPadding], so dividers of neighboring stacked columns join
  /// into one continuous line.
  ///
  /// [builder] must return the same number of widgets for every stacked column
  /// of the table.
  factory TTableHeader.stacked(
    String text,
    List<Widget> Function(T) builder, {
    int? flex,
    double? minWidth,
    double? maxWidth,
    Alignment? alignment,
    double rowHeight = 40,
    bool showDividers = true,
    Color? dividerColor,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(horizontal: 5),
    String? key,
    double Function(T data)? widthEstimator,
    bool flattenOnMobile = false,
    bool showInDetails = true,
    String Function(String headerText, String childKey)? mobileKeyPrefixBuilder,
  }) =>
      _TStackedTableHeader<T, K>(
        text,
        builder,
        flex: flex,
        minWidth: minWidth,
        maxWidth: maxWidth,
        alignment: alignment,
        rowHeight: rowHeight,
        showDividers: showDividers,
        dividerColor: dividerColor,
        contentPadding: contentPadding,
        key: key,
        widthEstimator: widthEstimator,
        flattenOnMobile: flattenOnMobile,
        showInDetails: showInDetails,
        mobileKeyPrefixBuilder: mobileKeyPrefixBuilder,
      );

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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.key,
    this.filterType,
    this.filterable = false,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
  })  : estimatedHeight = 36,
        map = null,
        keyValuesBuilder = builder,
        widthEstimator =
            widthEstimator ?? _keyValuesWidthEstimator<T>(builder: builder, keyStyle: keyStyle, valueStyle: valueStyle, inline: inline),
        builder =
            _keyValuesCellBuilder<T, K>(builder: builder, inline: inline, spacing: spacing, keyStyle: keyStyle, valueStyle: valueStyle);

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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.key,
    this.filterType,
    this.filterable = false,
    this.filterOperators,
    this.filterItems,
    this.filterDef,
    double Function(T data)? widthEstimator,
  })  : estimatedHeight = 36,
        map = null,
        keyValuesBuilder = builder,
        widthEstimator = widthEstimator ?? _valuesWidthEstimator<T>(builder: builder),
        builder = _valuesCellBuilder<T, K>(
            builder: builder, spacing: spacing, crossAxisAlignment: crossAxisAlignment, mainAxisAlignment: mainAxisAlignment);

  /// Creates a header for displaying a title and optional subtitle with leading icon using [TTile].
  TTableHeader.tile(
    this.text,
    String? Function(T) title, {
    String? Function(T)? subtitle,
    String? Function(T)? desc,
    dynamic Function(T)? icon,
    dynamic Function(T)? leading,
    Color? Function(T)? iconColor,
    Color? Function(T)? iconBackgroundColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? descStyle,
    double? iconSize,
    EdgeInsetsGeometry? iconPadding,
    BorderRadius? iconBorderRadius,
    double spacing = 10.0,
    CrossAxisAlignment? crossAxisAlignment,
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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = 40,
        map = title,
        widthEstimator = widthEstimator ??
            _tileWidthEstimator<T>(
                title: title,
                subtitle: subtitle,
                desc: desc,
                leading: leading,
                icon: icon,
                iconSize: iconSize,
                spacing: spacing,
                trailing: trailing),
        builder = _tileCellBuilder<T, K>(
            title: title,
            subtitle: subtitle,
            desc: desc,
            leading: leading,
            icon: icon,
            iconColor: iconColor,
            iconBackgroundColor: iconBackgroundColor,
            trailing: trailing,
            iconSize: iconSize,
            iconPadding: iconPadding,
            iconBorderRadius: iconBorderRadius,
            spacing: spacing,
            crossAxisAlignment: crossAxisAlignment,
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            descStyle: descStyle);

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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        builder = ((_, item, __) {
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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        map = get,
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
    this.alignment = Alignment.centerRight,
    this.flex,
    this.minWidth,
    double? maxWidth,
    int? count,
    double Function(T data)? widthEstimator,
    this.flattenOnMobile = false,
    this.showInDetails = false,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        map = null,
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
        builder = _actionsCellBuilder<T, K>(builder: builder);

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
    this.showInDetails = true,
    this.mobileKeyPrefixBuilder,
    this.keyValuesBuilder,
  })  : estimatedHeight = null,
        map = get,
        builder = _editableCellBuilder<T, K>(
            text: text, get: get, builder: builder, displayBuilder: displayBuilder, error: error, placeholder: placeholder);

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
    TInputDecorationType decorationType = TInputDecorationType.outline,
    TInputSize size = TInputSize.sm,
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
          builder: _textFieldEditor<T>(decorationType: decorationType, size: size, placeholder: placeholder, get: get, set: set),
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
    TInputDecorationType decorationType = TInputDecorationType.outline,
    TInputSize size = TInputSize.sm,
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
          builder: _numberFieldEditor<T>(decorationType: decorationType, size: size, placeholder: placeholder, get: get, set: set),
        );

  /// Automatically generates a list of [TFilterDef]s from the given [headers]
  /// and optional [sampleItems] to infer field data types.
  static List<TFilterDef<T>> autoGenerateFilterDefs<T, K>(
    List<TTableHeader<T, K>> headers, {
    List<T>? sampleItems,
  }) =>
      autoGenerateTableFilterDefs<T, K>(headers, sampleItems: sampleItems);
}
