import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'dart:math' as math;

/// Theme configuration for [TTable].
///
/// `TTableTheme` extends [TListTheme] and aggregates sub-themes for:
/// - Header row ([TTableRowHeaderTheme])
/// - Desktop rows ([TTableRowCardTheme])
/// - Mobile cards ([TTableMobileCardTheme])
///
/// It also defines layout properties like column width calculation logic
/// and breakpoints for switching between card/table views.
class TTableTheme extends TListTheme {
  final double? cardWidth;
  final bool? forceCardStyle;
  final bool? dense;
  final TTableRowHeaderTheme headerTheme;
  final TTableMobileCardTheme mobileCardTheme;
  final TTableRowCardTheme rowCardTheme;

  /// Width of the left side list when using [TTableExpansionMode.side].
  final double? expandSideListWidth;

  /// Minimum width required to show the side list alongside the detail panel in [TTableExpansionMode.side].
  ///
  /// If available width is less than this threshold (defaults to 700.0), the side list is hidden.
  final double? minSideExpandWidth;

  /// Creates a table theme.
  const TTableTheme({
    super.animationBuilder = TListAnimationBuilders.staggered,
    super.animationDuration = const Duration(milliseconds: 800),
    super.shrinkWrap = false,
    super.physics,
    super.padding,
    required super.emptyStateBuilder,
    required super.errorStateBuilder,
    super.loadingBuilder,
    super.headerBuilder,
    super.headerSticky,
    super.footerBuilder,
    super.footerSticky,
    super.infiniteScroll,
    required super.infiniteScrollFooterBuilder,
    super.listSeparatorBuilder,
    super.dragProxyDecorator,
    super.grid,
    super.gridDelegate,
    this.cardWidth,
    this.forceCardStyle,
    this.dense = false,
    this.expandSideListWidth,
    this.minSideExpandWidth,
    required this.headerTheme,
    required this.mobileCardTheme,
    required this.rowCardTheme,
  });

  @override
  TTableTheme copyWith({
    TListAnimationBuilder? animationBuilder,
    Duration? animationDuration,
    bool? shrinkWrap,
    ScrollPhysics? physics,
    EdgeInsets? padding,
    TListEmptyBuilder? emptyStateBuilder,
    TListErrorBuilder? errorStateBuilder,
    TListLoadingBuilder? loadingBuilder,
    TListHeaderBuilder? headerBuilder,
    TListFooterBuilder? footerBuilder,
    bool? headerSticky,
    bool? footerSticky,
    bool? infiniteScroll,
    TListFooterBuilder? infiniteScrollFooterBuilder,
    TListSeparatorBuilder? listSeparatorBuilder,
    TListDragProxyDecorator? dragProxyDecorator,
    TGridMode? grid,
    TGridDelegateBuilder? gridDelegate,
    double? cardWidth,
    bool? forceCardStyle,
    bool? dense,
    double? expandSideListWidth,
    double? minSideExpandWidth,
    TTableRowHeaderTheme? headerTheme,
    TTableMobileCardTheme? mobileCardTheme,
    TTableRowCardTheme? rowCardTheme,
  }) {
    final resolvedShrinkWrap = shrinkWrap ?? this.shrinkWrap;
    return TTableTheme(
      animationBuilder: animationBuilder ?? this.animationBuilder,
      animationDuration: animationDuration ?? this.animationDuration,
      shrinkWrap: resolvedShrinkWrap,
      physics: physics ?? this.physics,
      padding: padding ?? this.padding,
      emptyStateBuilder: emptyStateBuilder ?? this.emptyStateBuilder,
      errorStateBuilder: errorStateBuilder ?? this.errorStateBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      headerSticky: resolvedShrinkWrap == true ? false : (headerSticky ?? this.headerSticky),
      footerSticky: resolvedShrinkWrap == true ? false : (footerSticky ?? this.footerSticky),
      infiniteScroll: resolvedShrinkWrap == true ? false : (infiniteScroll ?? this.infiniteScroll),
      infiniteScrollFooterBuilder: infiniteScrollFooterBuilder ?? this.infiniteScrollFooterBuilder,
      listSeparatorBuilder: listSeparatorBuilder ?? this.listSeparatorBuilder,
      dragProxyDecorator: dragProxyDecorator ?? this.dragProxyDecorator,
      grid: grid ?? this.grid,
      gridDelegate: gridDelegate ?? this.gridDelegate,
      cardWidth: cardWidth ?? this.cardWidth,
      forceCardStyle: forceCardStyle ?? this.forceCardStyle,
      dense: dense ?? this.dense,
      expandSideListWidth: expandSideListWidth ?? this.expandSideListWidth,
      minSideExpandWidth: minSideExpandWidth ?? this.minSideExpandWidth,
      headerTheme: headerTheme ?? this.headerTheme,
      mobileCardTheme: mobileCardTheme ?? this.mobileCardTheme,
      rowCardTheme: rowCardTheme ?? this.rowCardTheme,
    );
  }

  /// Builds a default simplified expanded content widget.
  Widget buildDefaultExpandedContent<T>(ColorScheme colors, T item, int index) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Expanded content for item $index\nProvide expandedBuilder for custom content',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Creates a default theme derived from the context colors.
  factory TTableTheme.defaultTheme(ColorScheme colors) {
    final listTheme = TListTheme.defaultTheme(colors);

    return TTableTheme(
        loadingBuilder: listTheme.loadingBuilder,
        infiniteScrollFooterBuilder: listTheme.infiniteScrollFooterBuilder,
        emptyStateBuilder: listTheme.emptyStateBuilder,
        errorStateBuilder: listTheme.errorStateBuilder,
        dragProxyDecorator: listTheme.dragProxyDecorator,
        headerTheme: TTableRowHeaderTheme.defaultTheme(colors),
        rowCardTheme: TTableRowCardTheme.defaultTheme(colors),
        mobileCardTheme: TTableMobileCardTheme.defaultTheme(colors));
  }

  /// Padding/margin overhead outside the [Table] itself (row card padding,
  /// margins, etc.) subtracted from the widget's available width before
  /// it's divided between columns. A single named constant so this always
  /// agrees with [TTableColumnMeasurements.requiredWidth] — if the two
  /// disagreed, the table-vs-card breakpoint could pass while columns
  /// still didn't actually fit.
  static const double horizontalChrome = 32.0;

  static const TextStyle fallbackTextStyle = TextStyle(fontSize: 13.6);

  /// Measures how wide a column actually wants to be: the header label
  /// plus the widest sampled row value, laid out with [TextPainter] at
  /// unlimited width so it reflects the real, unwrapped text.
  static double _naturalColumnWidth<T, K>(
    TTableHeader<T, K> header,
    List<T> sampleItems,
    TextStyle headerStyle,
    TextStyle contentStyle,
  ) {
    double width = measureTextWidth(header.text, headerStyle);

    if (header.widthEstimator != null) {
      for (final item in sampleItems) {
        final w = header.widthEstimator!(item);
        if (w > width) width = w;
      }
    } else if (header.map != null) {
      for (final item in sampleItems) {
        final value = header.getValue(item);
        if (value.isEmpty) continue;
        final w = measureTextWidth(value, contentStyle);
        if (w > width) width = w;
      }
    } else {
      // Custom-rendered cell (image/chip/actions/etc.) can't be measured
      // ahead of layout — give it a sane, distinct default rather than
      // silently collapsing to a single flat fallback for every such column.
      width = math.max(width, 80.0);
    }

    return width + 24.0; // cell padding + a little breathing room
  }

  /// Measures the width of a text string using [TextPainter].
  static double measureTextWidth(String text, [TextStyle style = fallbackTextStyle]) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  /// Measures every column once (the expensive, text-layout part) and
  /// splits the result into fixed columns (selectable/expandable slots,
  /// and any header with an explicit [TTableHeader.minWidth]/[maxWidth] —
  /// those are honored exactly as given, no auto-sizing applied) versus
  /// auto columns that still need their natural width turned into a final
  /// pixel width once the available table width is known.
  ///
  /// Callers should cache the returned [TTableColumnMeasurements] and only
  /// call [TTableColumnMeasurements.resolve] on layout/resize — that part
  /// is pure arithmetic and re-runs no text measurement.
  static TTableColumnMeasurements measureColumns<T, K>(
    List<TTableHeader<T, K>> headers,
    bool selectable,
    bool expandable, {
    int maxTreeLevel = 0,
    bool isHierarchical = false,
    List<T> sampleItems = const [],
    TextStyle? headerTextStyle,
    TextStyle? contentTextStyle,
  }) {
    final fixedWidths = <int, TableColumnWidth>{};
    int columnIndex = 0;
    double fixedTotal = 0;

    if (selectable) {
      fixedWidths[columnIndex] = const FixedColumnWidth(50);
      fixedTotal += 50;
      columnIndex++;
    }
    if (expandable) {
      fixedWidths[columnIndex] = const FixedColumnWidth(50);
      fixedTotal += 50;
      columnIndex++;
    }

    final effectiveTreeLevel = isHierarchical && maxTreeLevel == 0 ? 1 : maxTreeLevel;
    final treeIndentBonus = (isHierarchical || maxTreeLevel > 0) ? (effectiveTreeLevel * 16.0 + 36.0) : 0.0;

    final autoIndices = <int>[];
    final autoBasisWidths = <double>[]; // weighting basis, already clamped into [min, max]
    final autoMinWidths = <double?>[];
    final autoMaxWidths = <double?>[];

    for (int i = 0; i < headers.length; i++) {
      final header = headers[i];
      final extraWidth = (i == 0) ? treeIndentBonus : 0.0;
      final index = columnIndex + i;

      final hasMin = header.minWidth != null && header.minWidth! > 0;
      final hasMax = header.maxWidth != null && header.maxWidth! != double.infinity;

      // Only skip measurement entirely when min and max pin the SAME value —
      // that's a genuinely fixed column with no range to size within, so
      // there's no point paying for a TextPainter layout.
      if (hasMin && hasMax && header.minWidth == header.maxWidth) {
        final width = header.minWidth! + extraWidth;
        fixedWidths[index] = FixedColumnWidth(width);
        fixedTotal += width;
        continue;
      }

      final natural = _naturalColumnWidth<T, K>(
            header,
            sampleItems,
            headerTextStyle ?? fallbackTextStyle,
            contentTextStyle ?? fallbackTextStyle,
          ) +
          extraWidth;

      final min = hasMin ? header.minWidth! + extraWidth : null;
      final max = hasMax ? header.maxWidth! + extraWidth : null;

      // Weighting basis = natural width clamped into this column's own
      // [min, max] — so a maxWidth cap doesn't inflate what other columns
      // compete for, and a minWidth-only column still measures/grows like
      // any other auto column instead of freezing at exactly minWidth.
      var basis = natural;
      if (min != null && basis < min) basis = min;
      if (max != null && basis > max) basis = max;

      autoIndices.add(index);
      autoBasisWidths.add(basis);
      autoMinWidths.add(min);
      autoMaxWidths.add(max);
    }

    return TTableColumnMeasurements(
      fixedWidths: fixedWidths,
      fixedTotal: fixedTotal,
      autoIndices: autoIndices,
      autoNaturalWidths: autoBasisWidths,
      autoMinWidths: autoMinWidths,
      autoMaxWidths: autoMaxWidths,
    );
  }

  /// One-shot convenience wrapper around [measureColumns] + [TTableColumnMeasurements.resolve]
  /// for callers that don't need to cache the measurement step themselves.
  static Map<int, TableColumnWidth> calculateColumnWidths<T, K>(
    List<TTableHeader<T, K>> headers,
    bool selectable,
    bool expandable, {
    int maxTreeLevel = 0,
    bool isHierarchical = false,
    List<T> sampleItems = const [],
    TextStyle? headerTextStyle,
    TextStyle? contentTextStyle,
    double availableWidth = double.infinity,
  }) {
    return measureColumns<T, K>(
      headers,
      selectable,
      expandable,
      maxTreeLevel: maxTreeLevel,
      isHierarchical: isHierarchical,
      sampleItems: sampleItems,
      headerTextStyle: headerTextStyle,
      contentTextStyle: contentTextStyle,
    ).resolve(availableWidth);
  }

  /// Calculates the minimum total width required for the table view
  /// (used to decide table-vs-card layout). Shares the exact same
  /// measurement as [calculateColumnWidths] so the two can never disagree.
  static double calculateTotalRequiredWidth<T, K>(
    List<TTableHeader<T, K>> headers,
    bool selectable,
    bool expandable, {
    int maxTreeLevel = 0,
    bool isHierarchical = false,
    List<T> sampleItems = const [],
    TextStyle? headerTextStyle,
    TextStyle? contentTextStyle,
  }) {
    return measureColumns<T, K>(
      headers,
      selectable,
      expandable,
      maxTreeLevel: maxTreeLevel,
      isHierarchical: isHierarchical,
      sampleItems: sampleItems,
      headerTextStyle: headerTextStyle,
      contentTextStyle: contentTextStyle,
    ).requiredWidth;
  }
}

/// Result of measuring a table's columns once. Deliberately separates the
/// expensive part (text measurement, done in [TTableTheme.measureColumns])
/// from the cheap part ([resolve], pure arithmetic) so a resize/relayout
/// doesn't re-run `TextPainter` for every column on every frame.
class TTableColumnMeasurements {
  final Map<int, TableColumnWidth> fixedWidths;
  final double fixedTotal;
  final List<int> autoIndices;

  /// Weighting basis per auto column — natural measured width, already
  /// clamped into that column's own [autoMinWidths]/[autoMaxWidths] range
  /// if it declared one.
  final List<double> autoNaturalWidths;
  final List<double?> autoMinWidths;
  final List<double?> autoMaxWidths;

  const TTableColumnMeasurements({
    required this.fixedWidths,
    required this.fixedTotal,
    required this.autoIndices,
    required this.autoNaturalWidths,
    required this.autoMinWidths,
    required this.autoMaxWidths,
  });

  double get autoNaturalTotal => autoNaturalWidths.fold(0.0, (a, b) => a + b);

  double get requiredWidth => fixedTotal + autoNaturalTotal + TTableTheme.horizontalChrome;

  Map<int, TableColumnWidth> resolve(double availableWidth) {
    final result = Map<int, TableColumnWidth>.from(fixedWidths);
    if (autoIndices.isEmpty) return result;

    final total = autoNaturalTotal;
    final availableForAuto = availableWidth.isFinite ? (availableWidth - TTableTheme.horizontalChrome - fixedTotal) : double.infinity;
    final scale = (total > 0 && availableForAuto.isFinite) ? math.max(1.0, availableForAuto / total) : 1.0;

    for (int j = 0; j < autoIndices.length; j++) {
      var width = autoNaturalWidths[j] * scale;
      // Re-clamp AFTER scaling: scale can push a max-capped basis back
      // over the ceiling (e.g. basis=100, scale=1.7 → 170), and this is
      // the only place that's caught. Min is defensive — scale is
      // currently always >= 1.0, so basis already satisfies min on its
      // own, but this keeps the guarantee explicit if that ever changes.
      final max = autoMaxWidths[j];
      final min = autoMinWidths[j];
      if (max != null && width > max) width = max;
      if (min != null && width < min) width = min;
      result[autoIndices[j]] = FixedColumnWidth(width);
    }
    return result;
  }
}
