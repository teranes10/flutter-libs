import 'package:flutter/material.dart';

/// Theme configuration for [TKeyValueSection].
///
/// `TKeyValueTheme` controls the appearance of key-value pairs, including:
/// - Text styles for keys, labels, and values
/// - Grid layout spacing and breakpoints
class TKeyValueTheme {
  /// The style for keys/labels in key-value (narrow) layout.
  final TextStyle keyStyle;

  /// The style for keys/labels in grid (wide) layout.
  final TextStyle labelStyle;

  /// The style for text values.
  final TextStyle valueStyle;

  /// Spacing between cells in grid layout.
  final double gridSpacing;

  /// The minimum allowed width for columns in grid layout.
  final double minGridColWidth;

  /// Whether to force the key-value (narrow) layout regardless of screen width.
  final bool forceKeyValue;

  /// The screen width threshold under which the key-value layout is used.
  final double keyValueBreakPoint;

  /// Whether to show a left vertical border/separator on grid cells.
  final bool showLeftBorder;

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

  /// Vertical spacing between the label and value within a grid cell.
  final double gridCellGap;

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

  /// Creates a key-value theme.
  const TKeyValueTheme({
    required this.keyStyle,
    required this.labelStyle,
    required this.valueStyle,
    this.gridSpacing = 0,
    this.minGridColWidth = 110,
    this.forceKeyValue = false,
    this.keyValueBreakPoint = 300,
    this.showLeftBorder = false,
    this.alignment = Alignment.centerLeft,
    this.narrowPadding = const EdgeInsets.symmetric(vertical: 6),
    this.narrowItemBottomSpacing = 10,
    this.narrowKeyFlex = 2,
    this.narrowValueFlex = 3,
    this.narrowGap = 12,
    this.gridCellPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    this.gridCellGap = 4,
    this.maxColWidthFraction = 0.7,
    this.minFractionFixed = 1.0,
    this.minFractionStructured = 0.9,
    this.minFractionCompact = 0.80,
    this.minFractionProse = 0.70,
    this.additionalNaturalWidth = 1.0,
    this.maxItemsPerRow = 12,
  });

  factory TKeyValueTheme.defaultTheme(ColorScheme colors) {
    return TKeyValueTheme(
      keyStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant),
      labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant),
      valueStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: colors.onSurface),
    );
  }
}
