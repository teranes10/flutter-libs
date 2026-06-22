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

  const TKeyValueSection({super.key, required this.values, this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final wTheme = theme ?? context.theme.keyValueTheme;

    if (wTheme.forceKeyValue) {
      return _KeyValueLayout(values: values, theme: wTheme, colors: colors);
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > wTheme.keyValueBreakPoint) {
        return _GridLayout(values: values, theme: wTheme, colors: colors);
      }
      return _KeyValueLayout(values: values, theme: wTheme, colors: colors);
    });
  }
}

// ─── Key-value (narrow) layout — unchanged, it was fine ──────────────────────

class _KeyValueLayout extends StatelessWidget {
  final List<TKeyValue> values;
  final TKeyValueTheme theme;
  final ColorScheme colors;

  const _KeyValueLayout({
    required this.values,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: theme.narrowPadding,
      child: Column(
        children: [
          for (int i = 0; i < values.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i < (values.length - 1) ? theme.narrowItemBottomSpacing : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: theme.narrowKeyFlex,
                    child: Text(values[i].key, style: theme.keyStyle),
                  ).when(!values[i].key.isNullOrBlank),
                  SizedBox(width: theme.narrowGap).when(!values[i].key.isNullOrBlank),
                  Expanded(
                    flex: theme.narrowValueFlex,
                    child: Align(
                      alignment: values[i].alignment ?? Alignment.centerRight,
                      child: _CellContent(kv: values[i], theme: theme),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Grid (wide) layout — RenderObject-based, no width guessing ──────────────

class _GridLayout extends StatelessWidget {
  final List<TKeyValue> values;
  final TKeyValueTheme theme;
  final ColorScheme colors;

  const _GridLayout({
    required this.values,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // Build one Cell widget per value. The RenderObject measures each one
    // at its natural size, then flows them into rows.
    final cells = [
      for (int i = 0; i < values.length; i++)
        _GridCell(
          kv: values[i],
          theme: theme,
          colors: colors,
          isFirstInRow: false, // RenderObject will tell us — handled via paint
        ),
    ];

    return _KeyValueGrid(
      theme: theme,
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
  final bool isFirstInRow;

  const _GridCell({
    required this.kv,
    required this.theme,
    required this.colors,
    required this.isFirstInRow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: theme.gridCellPadding,
      child: Column(
        crossAxisAlignment: (kv.alignment ?? theme.alignment).colCrossAxis,
        mainAxisAlignment: (kv.alignment ?? theme.alignment).colMainAxis,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(kv.key, style: theme.labelStyle).when(!kv.key.isNullOrBlank),
          SizedBox(height: theme.gridCellGap).when(!kv.key.isNullOrBlank),
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
  // Slot width assigned by the render object so the cell can fill it.
  double slotWidth = 0;
}

class _SlotData extends ParentDataWidget<_GridParentData> {
  const _SlotData({required super.child});

  @override
  void applyParentData(RenderObject renderObject) {
    // No static data to apply — render object writes slotWidth/isFirstInRow
    // directly during layout.
  }

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
  }) : super(
          children: children.map((c) => _SlotData(child: c)).toList(),
        );

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

  double get _spacing => _theme.gridSpacing;
  double get _maxColWidthFraction => _theme.maxColWidthFraction;
  double get _additionalNaturalWidth => _theme.additionalNaturalWidth;

  set kvItems(List<TKeyValue> v) {
    if (_kvItems != v) {
      _kvItems = v;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridParentData) {
      child.parentData = _GridParentData();
    }
  }

  // ── Pass 1: measure every child at its natural (unconstrained) width ───────

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

      double naturalW = child.size.width + _additionalNaturalWidth;
      if (kv.minWidth != null) {
        naturalW = math.max(naturalW, kv.minWidth!);
      }
      if (kv.maxWidth != null) {
        naturalW = math.min(naturalW, kv.maxWidth!);
      }

      out.add((
        box: child,
        natural: Size(naturalW, child.size.height),
      ));
      child = (child.parentData as _GridParentData).nextSibling;
      index++;
    }
    return out;
  }

  // ── Row builder: greedy, using natural widths ─────────────────────────────

  List<int> _buildRows(
    List<({RenderBox box, Size natural})> children,
    double maxWidth,
  ) {
    final rowStarts = <int>[];
    if (children.isEmpty) return rowStarts;

    rowStarts.add(0);
    var rowW = 0.0;
    var currentCount = 0;

    for (int i = 0; i < children.length; i++) {
      final w = children[i].natural.width;
      final needed = currentCount == 0 ? w : rowW + _spacing + w;
      if (needed > maxWidth && currentCount > 0) {
        rowStarts.add(i);
        rowW = w;
        currentCount = 1;
      } else {
        rowW = needed;
        currentCount++;
      }
    }
    return rowStarts;
  }

  // ── Pass 2: re-layout each child at its slot width ────────────────────────
  //
  // Slot width = row width divided among items in that row based on flex (natural width).
  // Each child gets re-laid-out with tight width so it fills the slot.
  // Row height is measured AFTER re-layout so wrapping text is accounted for.

  double _layoutRows(
    List<({RenderBox box, Size natural})> children,
    List<int> rowStarts,
    double maxWidth,
    bool dry,
  ) {
    double y = 0;

    for (int r = 0; r < rowStarts.length; r++) {
      final start = rowStarts[r];
      final end = r < rowStarts.length - 1 ? rowStarts[r + 1] : children.length;
      final count = end - start;
      final totalSpacing = _spacing * (count - 1);
      final available = maxWidth - totalSpacing;

      // Calculate total natural width of the row for flex factor sizing
      double totalFlex = 0;
      for (int i = start; i < end; i++) {
        totalFlex += children[i].natural.width;
      }

      // Re-layout at slot width.
      double allocated = 0;
      for (int i = start; i < end; i++) {
        final isLast = i == end - 1;
        final natural = children[i].natural.width;
        final kv = _kvItems[i];

        double slotW = isLast ? (available - allocated) : ((natural / totalFlex) * available).floorToDouble();

        if (kv.minWidth != null) {
          slotW = math.max(slotW, kv.minWidth!);
        }
        if (kv.maxWidth != null) {
          slotW = math.min(slotW, kv.maxWidth!);
        }
        allocated += slotW;

        children[i].box.layout(
              BoxConstraints(minWidth: slotW, maxWidth: slotW),
              parentUsesSize: true,
            );
        (children[i].box.parentData as _GridParentData)
          ..isFirstInRow = i == start
          ..slotWidth = slotW;
      }

      // Row height AFTER re-layout (text may have wrapped → taller).
      double rowH = 0;
      for (int i = start; i < end; i++) {
        rowH = math.max(rowH, children[i].box.size.height);
      }

      // Place children.
      if (!dry) {
        double x = 0;
        for (int i = start; i < end; i++) {
          final child = children[i].box;
          final slotW = (child.parentData as _GridParentData).slotWidth;
          // Force height to rowH so the internal Column with MainAxisSize.max fills the full row height.
          child.layout(
            BoxConstraints(minWidth: slotW, maxWidth: slotW, minHeight: rowH, maxHeight: rowH),
            parentUsesSize: true,
          );
          (child.parentData as _GridParentData).offset = Offset(x, y);
          x += slotW + _spacing;
        }
      }

      y += rowH + (r < rowStarts.length - 1 ? _spacing : 0);
    }

    return y;
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }

    final maxWidth = constraints.maxWidth;

    // Pass 1: measure at natural width (up to maxColWidthFraction).
    final children = _measureNatural(maxWidth);

    // Classify each item for shrink resistance.
    final scored = children
        .asMap()
        .entries
        .map((e) => (
              natural: e.value.natural,
              priority: _classifyContent(_kvItems[e.key], e.key), // see note below
              box: e.value.box,
            ))
        .toList();

    // Balanced row assignment.
    final rowStarts = _balancedRows(
      scored.map((s) => (natural: s.natural, priority: s.priority)).toList(),
      maxWidth,
      _theme.maxItemsPerRow,
    );

    // Pass 2 + 3: slot-width layout and placement (same as before).
    final totalH = _layoutRows(children, rowStarts, maxWidth, true);
    size = constraints.constrain(Size(maxWidth, totalH));
    _layoutRows(children, rowStarts, maxWidth, false);
  }

  // ── Paint: draw left-border separator between cells in the same row ────────

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as _GridParentData;
      context.paintChild(child, offset + pd.offset);
      child = pd.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => defaultHitTestChildren(result, position: position);

  @override
  double computeMinIntrinsicHeight(double width) {
    final children = _measureNatural(width);
    final rowStarts = _buildRows(children, width);
    return _layoutRows(children, rowStarts, width, true);
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
    final totalSpacing = _spacing * (items.length - 1);

    if (items.length <= maxPerRow && (maxWidth - (totalNaturalWidth + totalSpacing)) > 0) return [0];

    final estimatedRows = (totalNaturalWidth / maxWidth).ceil().clamp(1, n);
    final idealPerRow = n / estimatedRows;

    final dp = List.filled(n + 1, double.infinity);
    final split = List.filled(n + 1, 0);
    dp[0] = 0;

    for (int end = 1; end <= n; end++) {
      for (int start = math.max(0, end - maxPerRow); start < end; start++) {
        final count = end - start;
        final totalSpacing = _spacing * (count - 1);
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
