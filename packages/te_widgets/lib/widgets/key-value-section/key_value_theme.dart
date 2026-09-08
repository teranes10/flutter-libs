import 'package:flutter/material.dart';

/// Defines the layout presentation mode for [TKeyValueSection].
enum TKeyValueMode {
  /// Items flow dynamically into rows based on natural width, with keys stacked above values.
  stackedFlow,

  /// Items are arranged in uniform grid columns, with keys stacked above values.
  stackedColumns,

  /// Items flow dynamically into rows based on natural width, with keys and values inline (`Key: Value`).
  inlineFlow,

  /// Items are arranged in uniform grid columns with aligned keys and values inline (`Key: Value`).
  inlineColumns,

  /// Single-column layout with key on the far left and value on the far right.
  split;

  /// Whether keys and values are displayed side-by-side inline (`Key: Value`).
  bool get isInline => this == TKeyValueMode.inlineFlow || this == TKeyValueMode.inlineColumns;

  /// Whether keys are stacked vertically above values.
  bool get isStacked => this == TKeyValueMode.stackedFlow || this == TKeyValueMode.stackedColumns;

  /// Whether items are arranged in uniform multi-column grid layout.
  bool get isColumnar => this == TKeyValueMode.stackedColumns || this == TKeyValueMode.inlineColumns;

  /// Whether items wrap and flow dynamically based on natural content width.
  bool get isFlow => this == TKeyValueMode.stackedFlow || this == TKeyValueMode.inlineFlow;

  /// Whether items are in single-column split mode.
  bool get isSplit => this == TKeyValueMode.split;
}

/// Theme configuration for [TKeyValueSection].
///
/// `TKeyValueTheme` controls the appearance of key-value pairs, including:
/// - Text styles for keys, labels, and values
/// - Grid layout spacing and breakpoints
class TKeyValueTheme {
  /// Layout presentation mode for key-value items.
  final TKeyValueMode? mode;

  /// The style for keys/labels in key-value (narrow) layout.
  final TextStyle keyStyle;

  /// The style for keys/labels in grid (wide) layout.
  final TextStyle labelStyle;

  /// The style for text values.
  final TextStyle valueStyle;

  final double? _hSpacing;
  final double? _vSpacing;
  final double? _gap;

  /// The explicitly configured horizontal spacing, or null if using mode-based default.
  double? get rawHSpacing => _hSpacing;

  /// The explicitly configured vertical spacing, or null if using mode-based default.
  double? get rawVSpacing => _vSpacing;

  /// The explicitly configured gap between key and value, or null if using mode-based default.
  double? get rawGap => _gap;

  /// Horizontal spacing between cells/columns in grid layout.
  double get hSpacing =>
      _hSpacing ??
      (switch (mode) {
        TKeyValueMode.stackedFlow => 24,
        TKeyValueMode.stackedColumns => 24,
        TKeyValueMode.inlineFlow => 24,
        TKeyValueMode.inlineColumns => 24,
        TKeyValueMode.split => 12,
        null => 0,
      });

  /// Vertical spacing between rows in grid layout.
  double get vSpacing =>
      _vSpacing ??
      (switch (mode) {
        TKeyValueMode.stackedFlow => 16,
        TKeyValueMode.stackedColumns => 16,
        TKeyValueMode.inlineFlow => 16,
        TKeyValueMode.inlineColumns => 16,
        TKeyValueMode.split => 10,
        null => 8,
      });

  /// Spacing / gap between the key and value (vertical in stacked modes, horizontal in inline/split modes).
  double get gap =>
      _gap ??
      (switch (mode) {
        TKeyValueMode.stackedFlow => 0,
        TKeyValueMode.stackedColumns => 0,
        TKeyValueMode.inlineFlow => 12,
        TKeyValueMode.inlineColumns => 8,
        TKeyValueMode.split => 8,
        null => 4,
      });

  /// The minimum allowed width for columns in grid layout.
  final double minGridColWidth;

  /// Whether to force the key-value (narrow) layout regardless of screen width.
  final bool forceKeyValue;

  /// The screen width threshold under which the key-value layout is used.
  final double keyValueBreakPoint;

  /// Whether to show a left vertical border/separator on grid cells.
  final bool showLeftBorder;

  final Color borderColor;

  // ─── Alignment Configuration ───────────────────────────────────────────────

  /// Default alignment for key-value content.
  final Alignment alignment;

  // ─── Layout Padding & Gaps Configuration ───────────────────────────────────

  /// Overall padding surrounding the narrow key-value layout container.
  final EdgeInsets narrowPadding;

  /// Vertical spacing between items in narrow key-value layout.
  final double narrowItemBottomSpacing;

  /// Flex factor for the key column in narrow key-value layout.
  final int narrowKeyFlex;

  /// Flex factor for the value column in narrow key-value layout.
  final int narrowValueFlex;

  /// Horizontal gap between the key and value columns in narrow key-value layout.
  final double narrowGap;

  /// Padding surrounding each individual cell in grid layout.
  final EdgeInsets gridCellPadding;

  // ─── Calculation Parameters ────────────────────────────────────────────────

  /// The maximum fraction of total layout width a single column can consume.
  final double maxColWidthFraction;

  /// Minimum fraction of natural width tolerated by [fixed] content priority.
  final double minFractionFixed;

  /// Minimum fraction of natural width tolerated by [structured] content priority.
  final double minFractionStructured;

  /// Minimum fraction of natural width tolerated by [compact] content priority.
  final double minFractionCompact;

  /// Minimum fraction of natural width tolerated by [prose] content priority.
  final double minFractionProse;

  /// Extra width added to the calculated natural width of each child.
  final double additionalNaturalWidth;

  /// The maximum number of items allowed per row in grid layout.
  final int maxItemsPerRow;

  /// Whether to display key and value inline in grid layout (Key: Value).
  final bool gridInline;

  /// Fixed number of columns for grid layout.
  /// When specified, items are distributed into a columnar grid of this width.
  final int? columns;

  /// Fixed width for key columns in inline grid layout.
  final double? inlineKeyWidth;

  /// Maximum width allowed for key columns in inline grid layout.
  final double? inlineKeyMaxWidth;

  /// Alignment of the key within its column in inline grid layout.
  final Alignment? inlineKeyAlignment;

  /// Whether to arrange items in a columnar grid.
  /// When true (or when [columns] is set), items are arranged in uniform columns with aligned keys.
  /// When false (default), items flow dynamically into rows based on natural widths.
  final bool columnar;

  /// Whether to remove optional/empty values (null, empty strings, 0, '-') by default.
  final bool removeEmpty;

  /// Whether text values should be selectable with text selection gestures.
  /// Defaults to false so parent card/container tap events work smoothly.
  final bool selectable;

  /// Creates a key-value theme.
  const TKeyValueTheme({
    this.mode,
    required this.keyStyle,
    required this.labelStyle,
    required this.valueStyle,
    this.minGridColWidth = 110,
    this.forceKeyValue = false,
    this.keyValueBreakPoint = 300,
    required this.borderColor,
    this.showLeftBorder = false,
    this.alignment = Alignment.topLeft,
    this.narrowPadding = EdgeInsets.zero,
    this.narrowItemBottomSpacing = 10,
    this.narrowKeyFlex = 2,
    this.narrowValueFlex = 3,
    this.narrowGap = 12,
    this.gridCellPadding = EdgeInsets.zero,
    this.maxColWidthFraction = 0.7,
    this.minFractionFixed = 1.0,
    this.minFractionStructured = 0.9,
    this.minFractionCompact = 0.80,
    this.minFractionProse = 0.70,
    this.additionalNaturalWidth = 15,
    this.maxItemsPerRow = 12,
    this.gridInline = false,
    this.columnar = false,
    this.columns,
    this.inlineKeyWidth,
    this.inlineKeyMaxWidth,
    this.inlineKeyAlignment = Alignment.topLeft,
    this.removeEmpty = true,
    this.selectable = false,
    double? hSpacing,
    double? vSpacing,
    double? gap,
  })  : _hSpacing = hSpacing,
        _vSpacing = vSpacing,
        _gap = gap;

  factory TKeyValueTheme.defaultTheme(ColorScheme colors) {
    return TKeyValueTheme(
      keyStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant),
      labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant),
      valueStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurface),
      borderColor: colors.outlineVariant,
    );
  }

  TKeyValueTheme copyWith({
    TKeyValueMode? mode,
    TextStyle? keyStyle,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    double? minGridColWidth,
    bool? forceKeyValue,
    double? keyValueBreakPoint,
    Color? borderColor,
    bool? showLeftBorder,
    Alignment? alignment,
    EdgeInsets? narrowPadding,
    double? narrowItemBottomSpacing,
    int? narrowKeyFlex,
    int? narrowValueFlex,
    double? narrowGap,
    EdgeInsets? gridCellPadding,
    double? maxColWidthFraction,
    double? minFractionFixed,
    double? minFractionStructured,
    double? minFractionCompact,
    double? minFractionProse,
    double? additionalNaturalWidth,
    int? maxItemsPerRow,
    bool? gridInline,
    bool? columnar,
    int? columns,
    double? inlineKeyWidth,
    double? inlineKeyMaxWidth,
    Alignment? inlineKeyAlignment,
    bool? removeEmpty,
    bool? selectable,
    double? hSpacing,
    double? vSpacing,
    double? gap,
  }) {
    return TKeyValueTheme(
      mode: mode ?? this.mode,
      keyStyle: keyStyle ?? this.keyStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
      minGridColWidth: minGridColWidth ?? this.minGridColWidth,
      forceKeyValue: forceKeyValue ?? this.forceKeyValue,
      keyValueBreakPoint: keyValueBreakPoint ?? this.keyValueBreakPoint,
      borderColor: borderColor ?? this.borderColor,
      showLeftBorder: showLeftBorder ?? this.showLeftBorder,
      alignment: alignment ?? this.alignment,
      narrowPadding: narrowPadding ?? this.narrowPadding,
      narrowItemBottomSpacing: narrowItemBottomSpacing ?? this.narrowItemBottomSpacing,
      narrowKeyFlex: narrowKeyFlex ?? this.narrowKeyFlex,
      narrowValueFlex: narrowValueFlex ?? this.narrowValueFlex,
      narrowGap: narrowGap ?? this.narrowGap,
      gridCellPadding: gridCellPadding ?? this.gridCellPadding,
      maxColWidthFraction: maxColWidthFraction ?? this.maxColWidthFraction,
      minFractionFixed: minFractionFixed ?? this.minFractionFixed,
      minFractionStructured: minFractionStructured ?? this.minFractionStructured,
      minFractionCompact: minFractionCompact ?? this.minFractionCompact,
      minFractionProse: minFractionProse ?? this.minFractionProse,
      additionalNaturalWidth: additionalNaturalWidth ?? this.additionalNaturalWidth,
      maxItemsPerRow: maxItemsPerRow ?? this.maxItemsPerRow,
      gridInline: gridInline ?? this.gridInline,
      columnar: columnar ?? this.columnar,
      columns: columns ?? this.columns,
      inlineKeyWidth: inlineKeyWidth ?? this.inlineKeyWidth,
      inlineKeyMaxWidth: inlineKeyMaxWidth ?? this.inlineKeyMaxWidth,
      inlineKeyAlignment: inlineKeyAlignment ?? this.inlineKeyAlignment,
      removeEmpty: removeEmpty ?? this.removeEmpty,
      selectable: selectable ?? this.selectable,
      hSpacing: hSpacing ?? _hSpacing,
      vSpacing: vSpacing ?? _vSpacing,
      gap: gap ?? _gap,
    );
  }
}
