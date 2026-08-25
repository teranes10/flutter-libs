import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:te_widgets/te_widgets.dart';

/// A responsive key-value display section.
///
/// `TKeyValueSection` provides adaptive layout for key-value pairs with:
/// - Grid layout on wide screens
/// - Key-value layout on narrow screens
/// - Custom breakpoint control
/// - Widget support for values
///
/// ## Basic Usage
///
/// ```dart
/// TKeyValueSection(
///   values: [
///     TKeyValue(key: 'Name', value: 'John Doe'),
///     TKeyValue(key: 'Email', value: 'john@example.com'),
///     TKeyValue(key: 'Phone', value: '+1234567890'),
///   ],
/// )
/// ```
///
/// ## With Custom Widgets
///
/// ```dart
/// TKeyValueSection(
///   values: [
///     TKeyValue(key: 'Status', widget: TChip(text: 'Active')),
///     TKeyValue(key: 'Actions', widget: Row(children: [...])),
///   ],
/// )
/// ```
///
/// See also:
/// - [TKeyValue] for key-value pairs
/// - [TKeyValueTheme] for styling
class TKeyValueSection extends StatelessWidget {
  final List<TKeyValue> values;
  final TKeyValueTheme? theme;
  final bool? forceKeyValue;
  final bool? valueAfterKey;
  final int? columns;
  final bool? gridInline;
  final bool? columnar;
  final double? inlineKeyWidth;
  final double? inlineKeyMaxWidth;
  final double? inlineKeyGap;
  final Alignment? inlineKeyAlignment;
  final double? gridHorizontalSpacing;
  final double? gridVerticalSpacing;
  final double? gridCellGap;

  const TKeyValueSection({
    super.key,
    required this.values,
    this.theme,
    this.forceKeyValue,
    this.valueAfterKey,
    this.columns,
    this.gridInline,
    this.columnar,
    this.inlineKeyWidth,
    this.inlineKeyMaxWidth,
    this.inlineKeyAlignment,
    double? inlineKeyGap,
    double? gridHorizontalSpacing,
    double? gridVerticalSpacing,
    double? gridCellGap,
    double? hSpacing,
    double? vSpacing,
    double? gap,
  })  : inlineKeyGap = gap ?? inlineKeyGap,
        gridHorizontalSpacing = hSpacing ?? gridHorizontalSpacing,
        gridVerticalSpacing = vSpacing ?? gridVerticalSpacing,
        gridCellGap = gap ?? gridCellGap;

  /// Factory constructor for inline dynamic flow layout where `Key: Value` items wrap naturally based on width.
  factory TKeyValueSection.flow({
    Key? key,
    required List<TKeyValue> values,
    TKeyValueTheme? theme,
    double gap = 8,
    double hSpacing = 20,
    double vSpacing = 12,
  }) {
    return TKeyValueSection(
      key: key,
      values: values,
      theme: theme,
      gridInline: true,
      columnar: false,
      inlineKeyGap: gap,
      gridHorizontalSpacing: hSpacing,
      gridVerticalSpacing: vSpacing,
    );
  }

  /// Factory constructor for stacked dynamic flow layout where keys are stacked above values and wrap naturally based on width.
  factory TKeyValueSection.flowStacked({
    Key? key,
    required List<TKeyValue> values,
    TKeyValueTheme? theme,
    double gap = 4,
    double hSpacing = 16,
    double vSpacing = 12,
  }) {
    return TKeyValueSection(
      key: key,
      values: values,
      theme: theme,
      gridInline: false,
      columnar: false,
      gridCellGap: gap,
      gridHorizontalSpacing: hSpacing,
      gridVerticalSpacing: vSpacing,
    );
  }

  /// Factory constructor for inline multi-column grid layout with vertically aligned key columns.
  factory TKeyValueSection.columnsInline({
    Key? key,
    required List<TKeyValue> values,
    TKeyValueTheme? theme,
    int? columns,
    double? keyWidth,
    double? keyMaxWidth,
    double gap = 8,
    Alignment? keyAlignment,
    double hSpacing = 24,
    double vSpacing = 12,
  }) {
    return TKeyValueSection(
      key: key,
      values: values,
      theme: theme,
      gridInline: true,
      columnar: true,
      columns: columns,
      inlineKeyWidth: keyWidth,
      inlineKeyMaxWidth: keyMaxWidth,
      inlineKeyGap: gap,
      inlineKeyAlignment: keyAlignment,
      gridHorizontalSpacing: hSpacing,
      gridVerticalSpacing: vSpacing,
    );
  }

  /// Factory constructor for stacked multi-column grid layout with uniform/proportional columns.
  factory TKeyValueSection.columnsStacked({
    Key? key,
    required List<TKeyValue> values,
    TKeyValueTheme? theme,
    int? columns,
    double gap = 4,
    double hSpacing = 20,
    double vSpacing = 14,
  }) {
    return TKeyValueSection(
      key: key,
      values: values,
      theme: theme,
      gridInline: false,
      columnar: true,
      columns: columns,
      gridCellGap: gap,
      gridHorizontalSpacing: hSpacing,
      gridVerticalSpacing: vSpacing,
    );
  }

  /// Factory constructor for split single-column layout (Key on far left, Value on far right).
  factory TKeyValueSection.split({
    Key? key,
    required List<TKeyValue> values,
    TKeyValueTheme? theme,
    bool valueAfterKey = false,
    double gap = 8,
    double vSpacing = 10,
  }) {
    return TKeyValueSection(
      key: key,
      values: values,
      theme: theme,
      forceKeyValue: true,
      valueAfterKey: valueAfterKey,
      gridCellGap: gap,
      gridVerticalSpacing: vSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseTheme = theme ?? context.theme.keyValueTheme;
    final wTheme = baseTheme.copyWith(
      forceKeyValue: forceKeyValue,
      gridInline: gridInline,
      columnar: columnar,
      columns: columns,
      inlineKeyWidth: inlineKeyWidth,
      inlineKeyMaxWidth: inlineKeyMaxWidth,
      inlineKeyGap: inlineKeyGap,
      inlineKeyAlignment: inlineKeyAlignment,
      gridHorizontalSpacing: gridHorizontalSpacing,
      gridVerticalSpacing: gridVerticalSpacing,
      gridCellGap: gridCellGap,
    );
    final isForceKeyValue = wTheme.forceKeyValue;

    if (isForceKeyValue) {
      return _KeyValueLayout(
        values: values,
        theme: wTheme,
        colors: colors,
        valueAfterKey: valueAfterKey ?? false,
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > wTheme.keyValueBreakPoint) {
        return _GridLayout(
          values: values,
          theme: wTheme,
          colors: colors,
          maxWidth: constraints.maxWidth,
        );
      }
      return _KeyValueLayout(
        values: values,
        theme: wTheme,
        colors: colors,
        valueAfterKey: valueAfterKey ?? false,
      );
    });
  }
}

// ─── Shared measurement helpers ─────────────────────────────────────────────
//
// A single place that measures text width, used everywhere we need a
// pre-layout estimate (i.e. before the real widget tree exists). Keeping
// this in one function means every estimate stays consistent with every
// other estimate instead of silently drifting apart, which is what caused
// the inline key width to under-measure and overflow.

/// Reserved width for a leading icon in key/value cells when the actual
/// icon widget's size can't be measured ahead of time.
const double _kIconReservedWidth = 24.0;

/// Horizontal gap rendered between an icon and the text next to it.
const double _kIconGap = 6.0;

/// Small safety margin added on top of text-measurement estimates to
/// absorb rounding and font-metric differences between [TextPainter] and
/// the actual rendered [Text] widget.
const double _kMeasurementBuffer = 12.0;

/// Fallback width used to estimate the space a custom [TKeyValue.widget]
/// value will need, when no [TKeyValue.minWidth] is provided.
const double _kDefaultWidgetValueWidth = 100.0;

double _measureTextWidth(
  String text,
  TextStyle style,
  TextDirection direction,
  TextScaler textScaler, {
  int maxLines = 1,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: direction,
    textScaler: textScaler,
    maxLines: maxLines,
  )..layout();
  return painter.size.width;
}

// ─── Key-value (narrow) layout ──────────────────────────────────────────────

class _KeyValueLayout extends StatelessWidget {
  final List<TKeyValue> values;
  final TKeyValueTheme theme;
  final ColorScheme colors;
  final bool valueAfterKey;

  const _KeyValueLayout({
    required this.values,
    required this.theme,
    required this.colors,
    required this.valueAfterKey,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBottomSpacing = theme.gridInline ? (theme.narrowItemBottomSpacing / 2) : theme.narrowItemBottomSpacing;
    return Padding(
      padding: theme.narrowPadding,
      child: Column(
        children: [
          for (int i = 0; i < values.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i < (values.length - 1) ? effectiveBottomSpacing : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (values[i].icon != null) ...[
                    values[i].icon!,
                    const SizedBox(width: 8),
                  ],
                  if (valueAfterKey) ...[
                    Text(values[i].key, style: theme.keyStyle).when(!values[i].key.isNullOrBlank),
                    const SizedBox(width: 8).when(!values[i].key.isNullOrBlank),
                    Flexible(
                      child: _CellContent(kv: values[i], theme: theme),
                    ),
                  ] else ...[
                    Expanded(
                      flex: theme.narrowKeyFlex,
                      child: Text(values[i].key, style: theme.keyStyle),
                    ).when(!values[i].key.isNullOrBlank),
                    SizedBox(width: theme.narrowGap).when(!values[i].key.isNullOrBlank),
                    Expanded(
                      flex: theme.narrowValueFlex,
                      child: Align(
                        alignment: values[i].alignment ?? Alignment.topRight,
                        child: _CellContent(kv: values[i], theme: theme),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Grid (wide) layout — RenderObject-based with auto-calculated columns ────

class _GridLayout extends StatelessWidget {
  final List<TKeyValue> values;
  final TKeyValueTheme theme;
  final ColorScheme colors;
  final double maxWidth;

  const _GridLayout({
    required this.values,
    required this.theme,
    required this.colors,
    required this.maxWidth,
  });

  /// Estimates how many fixed columns fit in [maxWidth]. This runs before
  /// the real cell widgets exist, so it necessarily works off a
  /// [TextPainter] estimate rather than real layout — the RenderObject
  /// still shrinks columns further at actual-layout time if this guess
  /// turns out to be optimistic, so imprecision here is a soft/aesthetic
  /// concern rather than a correctness one.
  int _calculateEffectiveColumns(BuildContext context) {
    if (theme.columns != null && theme.columns! > 0) {
      return theme.columns!;
    }
    if (values.isEmpty) return 1;

    final dir = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final scaler = MediaQuery.textScalerOf(context);
    final paddingHorizontal = theme.gridCellPadding.horizontal;
    final spacing = theme.gridHorizontalSpacing;
    final maxAllowed = math.min(values.length, theme.maxItemsPerRow);

    final measuredKeys = <double>[];
    final measuredVals = <double>[];

    for (final kv in values) {
      double kW = 0;
      if (!kv.key.isNullOrBlank) {
        final labelStyle = theme.gridInline ? theme.keyStyle : theme.labelStyle;
        final text = theme.gridInline ? '${kv.key}:' : kv.key;
        kW = _measureTextWidth(text, labelStyle, dir, scaler).ceilToDouble() +
            (kv.icon != null ? (_kIconReservedWidth + _kIconGap) : 0.0) +
            _kMeasurementBuffer;
      }
      measuredKeys.add(kW);

      double vW = 0;
      if (kv.value != null && kv.value!.isNotEmpty) {
        vW = _measureTextWidth(kv.value!, theme.valueStyle, dir, scaler).ceilToDouble() + _kMeasurementBuffer;
      } else if (kv.widget != null) {
        vW = _kDefaultWidgetValueWidth;
      }
      if (kv.minWidth != null) vW = math.max(vW, kv.minWidth!);
      measuredVals.add(vW);
    }

    // Try column counts from maxAllowed down to 1
    for (int cols = maxAllowed; cols >= 1; cols--) {
      final neededWidths = <double>[];

      for (int c = 0; c < cols; c++) {
        double colKeyW = 0;
        for (int i = c; i < values.length; i += cols) {
          colKeyW = math.max(colKeyW, measuredKeys[i]);
        }
        if (theme.inlineKeyWidth != null) {
          colKeyW = theme.inlineKeyWidth!;
        } else if (theme.inlineKeyMaxWidth != null) {
          colKeyW = math.min(colKeyW, theme.inlineKeyMaxWidth!);
        }

        double colMaxItemW = 0;
        for (int i = c; i < values.length; i += cols) {
          double itemW;
          if (theme.gridInline) {
            final gap = colKeyW > 0 ? theme.inlineKeyGap : 0.0;
            itemW = colKeyW + gap + measuredVals[i] + paddingHorizontal;
          } else {
            itemW = math.max(measuredKeys[i], measuredVals[i]) + paddingHorizontal;
          }
          final kv = values[i];
          if (kv.minWidth != null) itemW = math.max(itemW, kv.minWidth!);
          if (kv.maxWidth != null) itemW = math.min(itemW, kv.maxWidth!);

          colMaxItemW = math.max(colMaxItemW, itemW);
        }

        colMaxItemW = math.max(colMaxItemW, theme.minGridColWidth);
        neededWidths.add(colMaxItemW);
      }

      final totalRequired = neededWidths.fold<double>(0, (s, w) => s + w) + (spacing * (cols - 1));
      if (totalRequired <= maxWidth || cols == 1) {
        return cols;
      }
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isColumnar = theme.columnar || (theme.columns != null && theme.columns! > 0);
    final effectiveColumns = isColumnar ? _calculateEffectiveColumns(context) : null;
    final Map<int, double> colKeyWidths = {};

    if (theme.gridInline && effectiveColumns != null && effectiveColumns > 0) {
      final dir = Directionality.maybeOf(context) ?? TextDirection.ltr;
      final scaler = MediaQuery.textScalerOf(context);
      for (int col = 0; col < effectiveColumns; col++) {
        double maxW = 0;
        for (int i = col; i < values.length; i += effectiveColumns) {
          final kv = values[i];
          if (!kv.key.isNullOrBlank) {
            final w = _measureTextWidth('${kv.key}:', theme.keyStyle, dir, scaler).ceilToDouble() +
                (kv.icon != null ? (_kIconReservedWidth + _kIconGap) : 0.0) +
                _kMeasurementBuffer;
            maxW = math.max(maxW, w);
          }
        }
        if (theme.inlineKeyWidth != null) {
          colKeyWidths[col] = theme.inlineKeyWidth!;
        } else if (theme.inlineKeyMaxWidth != null) {
          colKeyWidths[col] = math.min(maxW, theme.inlineKeyMaxWidth!);
        } else {
          colKeyWidths[col] = maxW;
        }
      }
    }

    final resolvedTheme = theme.copyWith(
      columns: effectiveColumns,
      // Resolve a concrete border color once, up front, so the RenderObject
      // (which has no BuildContext / ColorScheme of its own) always has
      // something sensible to paint with when showLeftBorder is enabled.
      borderColor: theme.borderColor,
    );

    final cells = [
      for (int i = 0; i < values.length; i++)
        _GridCell(
          kv: values[i],
          theme: resolvedTheme,
          colors: colors,
          keyWidth: (theme.gridInline && effectiveColumns != null && effectiveColumns > 0) ? colKeyWidths[i % effectiveColumns] : null,
        ),
    ];

    return _KeyValueGrid(
      theme: resolvedTheme,
      kvItems: values,
      children: cells,
    );
  }
}

// ─── Cell widgets ─────────────────────────────────────────────────────────────

class _GridCell extends StatelessWidget {
  final TKeyValue kv;
  final TKeyValueTheme theme;
  final ColorScheme colors;
  final double? keyWidth;

  const _GridCell({
    required this.kv,
    required this.theme,
    required this.colors,
    this.keyWidth,
  });

  @override
  Widget build(BuildContext context) {
    return theme.gridInline ? _buildInlineCell() : _buildStackedCell();
  }

  Widget _buildInlineCell() {
    final inlinePadding = EdgeInsets.only(
      left: theme.gridCellPadding.left,
      right: theme.gridCellPadding.right,
      top: theme.gridCellPadding.top / 2,
      bottom: theme.gridCellPadding.bottom / 2,
    );

    final effectiveKeyWidth = keyWidth ?? theme.inlineKeyWidth;
    final effectiveKeyMaxWidth = theme.inlineKeyMaxWidth;
    final keyAlignment = theme.inlineKeyAlignment ?? Alignment.topLeft;
    final hasFixedKeyWidth = effectiveKeyWidth != null && effectiveKeyWidth > 0;
    final hasKeyMaxWidth = effectiveKeyMaxWidth != null && effectiveKeyMaxWidth > 0;

    Widget? keyWidget;
    if (!kv.key.isNullOrBlank) {
      final keyText = hasKeyMaxWidth
          ? Flexible(
              child: Text(
                '${kv.key}:',
                style: theme.keyStyle,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : Text(
              '${kv.key}:',
              style: theme.keyStyle,
              maxLines: 1,
              softWrap: false,
            );

      final keyContent = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kv.icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: kv.icon!,
            ),
            const SizedBox(width: _kIconGap),
          ],
          keyText,
        ],
      );

      if (hasFixedKeyWidth) {
        keyWidget = SizedBox(
          width: effectiveKeyWidth,
          child: Align(
            alignment: keyAlignment,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: keyContent,
            ),
          ),
        );
      } else if (hasKeyMaxWidth) {
        keyWidget = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveKeyMaxWidth),
          child: Align(alignment: keyAlignment, child: keyContent),
        );
      } else {
        keyWidget = keyContent;
      }
    }

    return Container(
      padding: inlinePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (keyWidget != null) ...[
            keyWidget,
            SizedBox(width: theme.inlineKeyGap),
          ],
          Expanded(
            child: Align(
              alignment: kv.alignment ?? Alignment.topLeft,
              child: _CellContent(kv: kv, theme: theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedCell() {
    return Container(
      padding: theme.gridCellPadding,
      child: Column(
        crossAxisAlignment: (kv.alignment ?? theme.alignment).colCrossAxis,
        mainAxisAlignment: (kv.alignment ?? theme.alignment).colMainAxis,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!kv.key.isNullOrBlank)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kv.icon != null) ...[kv.icon!, const SizedBox(width: _kIconGap)],
                Text(kv.key, style: theme.labelStyle),
              ],
            ),
          if (!kv.key.isNullOrBlank) SizedBox(height: theme.gridCellGap + (kv.widget != null ? 2 : 0)),
          _CellContent(kv: kv, theme: theme),
        ],
      ),
    );
  }
}

class _CellContent extends StatelessWidget {
  final TKeyValue kv;
  final TKeyValueTheme theme;

  const _CellContent({required this.kv, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (kv.widget != null) return kv.widget!;
    return SelectableText(kv.value ?? '', style: theme.valueStyle);
  }
}

// ─── ParentData ───────────────────────────────────────────────────────────────

class _GridParentData extends ContainerBoxParentData<RenderBox> {
  bool isFirstInRow = false;
  double slotWidth = 0;
}

class _SlotData extends ParentDataWidget<_GridParentData> {
  const _SlotData({required super.child});

  @override
  void applyParentData(RenderObject renderObject) {}

  @override
  Type get debugTypicalAncestorWidgetClass => _KeyValueGrid;
}

// ─── MultiChildRenderObjectWidget ────────────────────────────────────────────

class _KeyValueGrid extends MultiChildRenderObjectWidget {
  final TKeyValueTheme theme;
  final List<TKeyValue> kvItems;

  _KeyValueGrid({
    required List<Widget> children,
    required this.theme,
    required this.kvItems,
  }) : super(children: children.map((c) => _SlotData(child: c)).toList());

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderKeyValueGrid(
        theme: theme,
        kvItems: kvItems,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderKeyValueGrid ro) {
    ro
      ..theme = theme
      ..kvItems = kvItems;
  }
}

// ─── The render object ────────────────────────────────────────────────────────

class _RenderKeyValueGrid extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _GridParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _GridParentData> {
  TKeyValueTheme _theme;
  List<TKeyValue> _kvItems;

  _RenderKeyValueGrid({
    required TKeyValueTheme theme,
    required List<TKeyValue> kvItems,
  })  : _theme = theme,
        _kvItems = kvItems;

  set theme(TKeyValueTheme v) {
    if (_theme != v) {
      _theme = v;
      markNeedsLayout();
    }
  }

  set kvItems(List<TKeyValue> v) {
    if (_kvItems != v) {
      _kvItems = v;
      markNeedsLayout();
    }
  }

  double get _horizontalSpacing => _theme.gridHorizontalSpacing;
  double get _verticalSpacing => _theme.gridVerticalSpacing;
  double get _maxColWidthFraction => _theme.maxColWidthFraction;
  double get _additionalNaturalWidth => _theme.additionalNaturalWidth;
  int? get _fixedColumns => (_theme.columns != null && _theme.columns! > 0) ? _theme.columns : null;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridParentData) {
      child.parentData = _GridParentData();
    }
  }

  // ── Pass 1: measure every child's intrinsic content width ─────────────────

  List<({RenderBox box, Size natural})> _measureNatural(double maxWidth) {
    final out = <({RenderBox box, Size natural})>[];
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final kv = _kvItems[index];
      final baseMaxWidth = maxWidth * _maxColWidthFraction;
      final constrainedMaxWidth = kv.maxWidth != null ? math.min(baseMaxWidth, kv.maxWidth!) : baseMaxWidth;
      final constrainedMinWidth = kv.minWidth ?? 0.0;

      child.layout(
        BoxConstraints(
          minWidth: constrainedMinWidth,
          maxWidth: constrainedMaxWidth,
        ),
        parentUsesSize: true,
      );

      final intrinsicWidth = child.getMaxIntrinsicWidth(double.infinity);
      double naturalW = math.min(intrinsicWidth, constrainedMaxWidth) + _additionalNaturalWidth;

      if (kv.minWidth != null) naturalW = math.max(naturalW, kv.minWidth!);
      if (kv.maxWidth != null) naturalW = math.min(naturalW, kv.maxWidth!);

      out.add((box: child, natural: Size(naturalW, child.size.height)));
      child = (child.parentData as _GridParentData).nextSibling;
      index++;
    }
    return out;
  }

  // ── Row grouping ────────────────────────────────────────────────────────

  List<int> _computeRowStarts(List<({RenderBox box, Size natural})> children, double maxWidth) {
    final cols = _fixedColumns;
    if (cols != null) {
      return [for (int i = 0; i < children.length; i += cols) i];
    }
    if (children.isEmpty) return [];

    final items = <({Size natural, _ContentPriority priority})>[
      for (int i = 0; i < children.length; i++) (natural: children[i].natural, priority: _classifyContent(_kvItems[i], i)),
    ];
    return _balancedRows(items, maxWidth, _theme.maxItemsPerRow);
  }

  // ── Column widths for fixed-column ("columnar") mode ───────────────────
  //
  // Sized to the content needs of each column and expanded with width-based
  // proportional flex to utilize 100% of the available width, just like
  // the row manner layout, while keeping all columns perfectly aligned.

  List<double> _computeColumnWidths(
    List<({RenderBox box, Size natural})> children,
    int cols,
    double maxWidth,
  ) {
    final widths = List<double>.filled(cols, _theme.minGridColWidth);
    for (int i = 0; i < children.length; i++) {
      final col = i % cols;
      widths[col] = math.max(widths[col], children[i].natural.width);
    }

    final totalSpacing = _horizontalSpacing * (cols - 1);
    final available = maxWidth - totalSpacing;
    final totalFlex = widths.fold<double>(0, (s, w) => s + w);

    if (totalFlex > 0 && available > 0) {
      double allocated = 0;
      for (int c = 0; c < cols; c++) {
        final isLast = c == cols - 1;
        final slotW =
            isLast ? math.max(_theme.minGridColWidth, available - allocated) : ((widths[c] / totalFlex) * available).floorToDouble();
        widths[c] = slotW;
        allocated += slotW;
      }
    }

    return widths;
  }

  // ── Pass 2: lay out each row and position its children ─────────────────

  double _layoutRows(
    List<({RenderBox box, Size natural})> children,
    List<int> rowStarts,
    double maxWidth,
    List<double>? columnWidths,
    bool dry,
  ) {
    double y = 0;

    for (int r = 0; r < rowStarts.length; r++) {
      final start = rowStarts[r];
      final end = r < rowStarts.length - 1 ? rowStarts[r + 1] : children.length;

      final rowH = columnWidths != null
          ? _layoutColumnarRow(children, start, end, columnWidths, y, dry)
          : _layoutFlowRow(children, start, end, maxWidth, y, dry);

      y += rowH + (r < rowStarts.length - 1 ? _verticalSpacing : 0);
    }

    return y;
  }

  /// Fixed-column layout: every item in column `c` gets `columnWidths[c]`.
  double _layoutColumnarRow(
    List<({RenderBox box, Size natural})> children,
    int start,
    int end,
    List<double> columnWidths,
    double y,
    bool dry,
  ) {
    for (int i = start; i < end; i++) {
      final colIndex = i - start;
      final kv = _kvItems[i];
      double slotW = columnWidths[colIndex];
      if (kv.minWidth != null) slotW = math.max(slotW, kv.minWidth!);
      if (kv.maxWidth != null) slotW = math.min(slotW, kv.maxWidth!);

      children[i].box.layout(
            BoxConstraints(minWidth: slotW, maxWidth: slotW),
            parentUsesSize: true,
          );
      (children[i].box.parentData as _GridParentData)
        ..isFirstInRow = i == start
        ..slotWidth = slotW;
    }

    double rowH = 0;
    for (int i = start; i < end; i++) {
      rowH = math.max(rowH, children[i].box.size.height);
    }

    if (!dry) {
      double x = 0;
      for (int i = start; i < end; i++) {
        final child = children[i].box;
        final slotW = (child.parentData as _GridParentData).slotWidth;
        child.layout(
          BoxConstraints(minWidth: slotW, maxWidth: slotW, minHeight: rowH, maxHeight: rowH),
          parentUsesSize: true,
        );
        (child.parentData as _GridParentData).offset = Offset(x, y);
        x += slotW + _horizontalSpacing;
      }
    }

    return rowH;
  }

  /// Auto-flow layout: items in a row share space proportionally to their
  /// natural width. Unchanged from before — this is the "row manner" path
  /// that was already working well.
  double _layoutFlowRow(
    List<({RenderBox box, Size natural})> children,
    int start,
    int end,
    double maxWidth,
    double y,
    bool dry,
  ) {
    final count = end - start;
    final totalSpacing = _horizontalSpacing * (count - 1);
    final available = maxWidth - totalSpacing;

    double totalFlex = 0;
    for (int i = start; i < end; i++) {
      totalFlex += children[i].natural.width;
    }

    double allocated = 0;
    for (int i = start; i < end; i++) {
      final isLast = i == end - 1;
      final natural = children[i].natural.width;
      final kv = _kvItems[i];

      double slotW = isLast ? (available - allocated) : ((natural / totalFlex) * available).floorToDouble();

      if (kv.minWidth != null) slotW = math.max(slotW, kv.minWidth!);
      if (kv.maxWidth != null) slotW = math.min(slotW, kv.maxWidth!);
      allocated += slotW;

      children[i].box.layout(
            BoxConstraints(minWidth: slotW, maxWidth: slotW),
            parentUsesSize: true,
          );
      (children[i].box.parentData as _GridParentData)
        ..isFirstInRow = i == start
        ..slotWidth = slotW;
    }

    double rowH = 0;
    for (int i = start; i < end; i++) {
      rowH = math.max(rowH, children[i].box.size.height);
    }

    if (!dry) {
      double x = 0;
      for (int i = start; i < end; i++) {
        final child = children[i].box;
        final slotW = (child.parentData as _GridParentData).slotWidth;
        child.layout(
          BoxConstraints(minWidth: slotW, maxWidth: slotW, minHeight: rowH, maxHeight: rowH),
          parentUsesSize: true,
        );
        (child.parentData as _GridParentData).offset = Offset(x, y);
        x += slotW + _horizontalSpacing;
      }
    }

    return rowH;
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }

    final maxWidth = constraints.maxWidth;
    final children = _measureNatural(maxWidth);
    final rowStarts = _computeRowStarts(children, maxWidth);
    final cols = _fixedColumns;
    final columnWidths = cols != null ? _computeColumnWidths(children, cols, maxWidth) : null;

    final totalH = _layoutRows(children, rowStarts, maxWidth, columnWidths, true);
    size = constraints.constrain(Size(maxWidth, totalH));
    _layoutRows(children, rowStarts, maxWidth, columnWidths, false);
  }

  // ── Paint: children, plus an optional separator between row items ──────

  @override
  void paint(PaintingContext context, Offset offset) {
    final drawBorders = _theme.showLeftBorder;
    final borderPaint = drawBorders
        ? (Paint()
          ..color = _theme.borderColor
          ..strokeWidth = 1.0)
        : null;

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as _GridParentData;
      if (borderPaint != null && !pd.isFirstInRow) {
        final x = offset.dx + pd.offset.dx - (_horizontalSpacing / 2);
        context.canvas.drawLine(
          Offset(x, offset.dy + pd.offset.dy),
          Offset(x, offset.dy + pd.offset.dy + child.size.height),
          borderPaint,
        );
      }
      context.paintChild(child, offset + pd.offset);
      child = pd.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => defaultHitTestChildren(result, position: position);

  @override
  double computeMinIntrinsicHeight(double width) {
    final children = _measureNatural(width);
    final rowStarts = _computeRowStarts(children, width);
    final cols = _fixedColumns;
    final columnWidths = cols != null ? _computeColumnWidths(children, cols, width) : null;
    return _layoutRows(children, rowStarts, width, columnWidths, true);
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  // Minimum fraction of natural width each priority will tolerate.
  double _minFraction(_ContentPriority p) => switch (p) {
        _ContentPriority.fixed => _theme.minFractionFixed,
        _ContentPriority.structured => _theme.minFractionStructured,
        _ContentPriority.compact => _theme.minFractionCompact,
        _ContentPriority.prose => _theme.minFractionProse,
      };

  // ─── Balanced row assignment via DP ──────────────────────────────────────────
  //
  // Instead of greedy left-to-right packing, we find the assignment of N items
  // into rows that minimises the worst-case compression ratio.
  //
  // State: dp[i] = minimum "badness" for items 0..i-1 optimally assigned.
  // Badness for a row = max compression ratio among items in that row.
  // Compression ratio for item j in a row with k items:
  //   slotWidth = (maxWidth - spacing*(k-1)) / k
  //   ratio = max(0, naturalWidth[j] - slotWidth) / naturalWidth[j]
  //   penalised by priority so structured items add more badness when compressed.

  List<int> _balancedRows(
    List<({Size natural, _ContentPriority priority})> items,
    double maxWidth,
    int maxPerRow,
  ) {
    final n = items.length;
    if (n == 0) return [];

    // Ideal items-per-row: aim for equal distribution across estimated row count.
    // This seeds the DP toward balanced splits rather than greedy packing.
    final totalNaturalWidth = items.fold(0.0, (s, i) => s + i.natural.width);
    final totalSpacing = _horizontalSpacing * (items.length - 1);

    if (items.length <= maxPerRow && (maxWidth - (totalNaturalWidth + totalSpacing)) > 0) return [0];

    final estimatedRows = (totalNaturalWidth / maxWidth).ceil().clamp(1, n);
    final idealPerRow = n / estimatedRows;

    final dp = List.filled(n + 1, double.infinity);
    final split = List.filled(n + 1, 0);
    dp[0] = 0;

    for (int end = 1; end <= n; end++) {
      for (int start = math.max(0, end - maxPerRow); start < end; start++) {
        final count = end - start;
        final totalSpacing = _horizontalSpacing * (count - 1);
        final available = maxWidth - totalSpacing;

        double totalNatural = 0;
        for (int j = start; j < end; j++) {
          totalNatural += items[j].natural.width;
        }

        bool feasible = true;
        double rowBadness = 0;

        for (int j = start; j < end; j++) {
          final natural = items[j].natural.width;
          final slotWidth = (natural / totalNatural) * available;
          final priority = items[j].priority;
          final minW = natural * _minFraction(priority);

          if (slotWidth < minW) {
            feasible = false;
            break;
          }

          final compressionRatio = natural > slotWidth ? (natural - slotWidth) / natural : 0.0;

          final priorityWeight = switch (priority) {
            _ContentPriority.fixed => 10.0,
            _ContentPriority.structured => 4.0,
            _ContentPriority.compact => 2.0,
            _ContentPriority.prose => 1.0,
          };

          rowBadness = math.max(rowBadness, compressionRatio * priorityWeight);
        }

        if (!feasible) continue;

        // Imbalance penalty: punish rows that deviate from idealPerRow.
        // This prevents [2] [12] splits when [7] [7] is possible.
        final deviation = (count - idealPerRow).abs() / idealPerRow;
        final imbalancePenalty = deviation * 0.8;

        // Unused space penalty: punish rows that leave lots of empty space
        // when items could have been spread more evenly.
        final usedWidth = totalNatural + totalSpacing;
        final unusedFraction = (maxWidth - usedWidth) / maxWidth;
        // Only penalise if there are more items coming (not the last row).
        final unusedPenalty = end < n ? unusedFraction * 0.5 : 0.0;

        final totalBadness = dp[start] + rowBadness + imbalancePenalty + unusedPenalty;
        if (totalBadness < dp[end]) {
          dp[end] = totalBadness;
          split[end] = start;
        }
      }
    }

    // Backtrack starting indices.
    final rowStarts = <int>[];
    var end = n;
    while (end > 0) {
      final start = split[end];
      rowStarts.add(start);
      end = start;
    }
    return rowStarts.reversed.toList();
  }
}

// ─── Content classification ───────────────────────────────────────────────────
//
// Determines how hard an item resists shrinking below its natural width.
// Higher priority = harder to shrink = earlier candidate to move to next row.

enum _ContentPriority {
  /// Icons, status indicators, tiny widgets — already minimal, never compress.
  fixed,

  /// IDs, codes, short keys, hashes — must stay single-line.
  structured,

  /// Short labels, names, titles — prefer single-line but can wrap if needed.
  compact,

  /// Prose values, descriptions — can wrap, low resistance.
  prose,
}

_ContentPriority _classifyContent(TKeyValue kv, int indexInList) {
  // Explicit width = caller knows what they want, treat as fixed.
  if (kv.width != null) return _ContentPriority.fixed;

  // Widget children: first 3 positions get structured priority (icons, badges,
  // action buttons — the "header-like" cells mentioned in the spec).
  if (kv.widget != null) {
    return indexInList < 3 ? _ContentPriority.fixed : _ContentPriority.structured;
  }

  final v = (kv.value ?? '').trim();

  // Empty or very short → fixed (don't waste space shrinking nothing).
  if (v.isEmpty || v.length <= 10) return _ContentPriority.fixed;

  // Heuristics for structured/code content:
  // - All caps with optional underscores/dashes (IDs, enums, codes)
  // - Hex-looking strings
  // - UUID pattern
  // - No spaces (slugs, hashes, tokens)
  // - Numeric / decimal
  final noSpaces = !v.contains(' ');
  final looksLikeCode = noSpaces ||
      RegExp(r'^[A-Z0-9_\-]+$').hasMatch(v) ||
      RegExp(r'^[0-9a-fA-F\-]{8,}$').hasMatch(v) ||
      RegExp(r'^\d+(\.\d+)*$').hasMatch(v);

  if (looksLikeCode || indexInList < 3) return _ContentPriority.structured;

  // Short values prefer compact.
  if (v.length <= 30) return _ContentPriority.compact;

  return _ContentPriority.prose;
}
