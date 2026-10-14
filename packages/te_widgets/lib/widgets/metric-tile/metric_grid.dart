import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:te_widgets/te_widgets.dart';

/// How a [TGrid] sizes itself along its main (horizontal) axis.
enum TGridMainAxisSize {
  /// Shrink-wrap: tiles keep their content-based width and the grid is only as
  /// wide as its widest row.
  min,

  /// Fill the available width: tiles grow to use all the space in their row.
  max,

  /// [max] on mobile, [min] on larger screens.
  auto,
}

/// A responsive grid purpose-built for laying out [TMetricTile], [TTile] (or any
/// KPI tile) children. Tiles are sized from their content — the label / title
/// (and value) text is measured with its resolved style — clamped between
/// [minTileWidth] and [maxTileWidth], then wrapped into rows. Every tile across
/// the whole grid shares the same height (the tallest child's natural height)
/// unless [uniformHeight] is false.
///
/// - [uniformWidth] makes every tile as wide as the widest child (capped by
///   [maxTileWidth]).
/// - [mainAxisSize] decides whether tiles grow to fill each row
///   ([TGridMainAxisSize.max]), shrink-wrap ([TGridMainAxisSize.min]) or pick
///   based on screen size ([TGridMainAxisSize.auto], the default).
/// - Pass [columns] to pin an exact column count; tiles then share equal
///   widths when growing.
///
/// ## Basic Usage
///
/// ```dart
/// TGrid(
///   children: [
///     TMetricTile(label: 'Total Amount', value: 'Rs. 3,200', ...),
///     TMetricTile(label: 'Subtotal', value: 'Rs. 3,200', ...),
///     TMetricTile(label: 'Line Items', value: '4 items', ...),
///   ],
/// )
/// ```
///
/// Also available as [TMetricGrid] for backward compatibility.
class TGrid extends StatelessWidget {
  /// The tile widgets to lay out.
  final List<Widget> children;

  /// Minimum width for each tile.
  final double minTileWidth;

  /// Maximum content-based width for each tile. Tiles that grow to fill their
  /// row ([mainAxisSize] max) are not limited by it.
  final double maxTileWidth;

  /// Pins an exact number of columns, overriding the automatic wrapping.
  final int? columns;

  /// Horizontal spacing between tiles.
  final double gapX;

  /// Vertical spacing between rows.
  final double gapY;

  /// Whether every tile (across all rows) shares one uniform height, equal
  /// to the tallest tile in the whole grid. When false, height is only
  /// equalized within each row.
  final bool uniformHeight;

  /// Whether every tile shares one width: the widest child's content width,
  /// capped by [maxTileWidth]. When false each tile uses its own content width.
  final bool uniformWidth;

  /// Main-axis sizing. Defaults to [TGridMainAxisSize.auto].
  final TGridMainAxisSize mainAxisSize;

  const TGrid({
    super.key,
    required this.children,
    this.minTileWidth = 50,
    this.maxTileWidth = 400,
    this.columns,
    this.gapX = 12,
    this.gapY = 12,
    this.uniformHeight = true,
    this.uniformWidth = false,
    this.mainAxisSize = TGridMainAxisSize.auto,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final grow = switch (mainAxisSize) {
          TGridMainAxisSize.min => false,
          TGridMainAxisSize.max => true,
          TGridMainAxisSize.auto => constraints.isMobile,
        };

        final preferredWidths = [
          for (final child in children)
            math.min(math.max(WidthHelper.resolveWidth(context, child) ?? maxTileWidth, minTileWidth), maxTileWidth),
        ];

        return _TGrid(
          preferredWidths: preferredWidths,
          columns: columns,
          gapX: gapX,
          gapY: gapY,
          uniformHeight: uniformHeight,
          uniformWidth: uniformWidth,
          grow: grow,
          children: children,
        );
      },
    );
  }
}

/// Backward-compatible alias for [TGrid].
typedef TMetricGrid = TGrid;

class _ParentData extends ContainerBoxParentData<RenderBox> {}

class _TGrid extends MultiChildRenderObjectWidget {
  final List<double> preferredWidths;
  final int? columns;
  final double gapX;
  final double gapY;
  final bool uniformHeight;
  final bool uniformWidth;
  final bool grow;

  const _TGrid({
    required super.children,
    required this.preferredWidths,
    required this.columns,
    required this.gapX,
    required this.gapY,
    required this.uniformHeight,
    required this.uniformWidth,
    required this.grow,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTGrid(
        preferredWidths: preferredWidths,
        columns: columns,
        gapX: gapX,
        gapY: gapY,
        uniformHeight: uniformHeight,
        uniformWidth: uniformWidth,
        grow: grow,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderTGrid ro) {
    ro
      ..preferredWidths = preferredWidths
      ..columns = columns
      ..gapX = gapX
      ..gapY = gapY
      ..uniformHeight = uniformHeight
      ..uniformWidth = uniformWidth
      ..grow = grow;
  }
}

class _RenderTGrid extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _ParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _ParentData> {
  List<double> _preferredWidths;
  int? _columns;
  double _gapX;
  double _gapY;
  bool _uniformHeight;
  bool _uniformWidth;
  bool _grow;

  _RenderTGrid({
    required List<double> preferredWidths,
    required int? columns,
    required double gapX,
    required double gapY,
    required bool uniformHeight,
    required bool uniformWidth,
    required bool grow,
  })  : _preferredWidths = preferredWidths,
        _columns = columns,
        _gapX = gapX,
        _gapY = gapY,
        _uniformHeight = uniformHeight,
        _uniformWidth = uniformWidth,
        _grow = grow;

  set preferredWidths(List<double> v) {
    if (!listEquals(_preferredWidths, v)) {
      _preferredWidths = v;
      markNeedsLayout();
    }
  }

  set columns(int? v) {
    if (_columns != v) {
      _columns = v;
      markNeedsLayout();
    }
  }

  set gapX(double v) {
    if (_gapX != v) {
      _gapX = v;
      markNeedsLayout();
    }
  }

  set gapY(double v) {
    if (_gapY != v) {
      _gapY = v;
      markNeedsLayout();
    }
  }

  set uniformHeight(bool v) {
    if (_uniformHeight != v) {
      _uniformHeight = v;
      markNeedsLayout();
    }
  }

  set uniformWidth(bool v) {
    if (_uniformWidth != v) {
      _uniformWidth = v;
      markNeedsLayout();
    }
  }

  set grow(bool v) {
    if (_grow != v) {
      _grow = v;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ParentData) {
      child.parentData = _ParentData();
    }
  }

  /// Splits the tile indices into rows: [_columns] per row when pinned,
  /// otherwise greedily wrapped by content width.
  List<List<int>> _buildRows(List<double> widths, double available) {
    final rows = <List<int>>[];
    final pinned = _columns != null && _columns! > 0 ? _columns! : null;
    var rowWidth = 0.0;
    for (int i = 0; i < widths.length; i++) {
      final startNew = rows.isEmpty || (pinned != null ? rows.last.length >= pinned : rowWidth + _gapX + widths[i] > available);
      if (startNew) {
        rows.add([i]);
        rowWidth = widths[i];
      } else {
        rows.last.add(i);
        rowWidth += _gapX + widths[i];
      }
    }
    return rows;
  }

  double _rowWidth(List<int> row, List<double> widths) => row.fold<double>(0, (sum, i) => sum + widths[i]) + _gapX * (row.length - 1);

  @override
  void performLayout() {
    final count = childCount;
    if (count == 0) {
      size = constraints.smallest;
      return;
    }

    final available = constraints.maxWidth;
    final bounded = available.isFinite;

    final prefs = List<double>.generate(count, (i) => i < _preferredWidths.length ? _preferredWidths[i] : 0.0);
    final sharedWidth = prefs.fold<double>(0, math.max);
    final widths = [
      for (final p in prefs) math.min(_uniformWidth ? sharedWidth : p, bounded ? available : double.infinity),
    ];

    final rows = _buildRows(widths, available);
    final grow = _grow && bounded;

    if (grow) {
      if (_uniformWidth || (_columns != null && _columns! > 0)) {
        // Equal columns filling the whole width; every row (incl. a partial
        // last one) keeps the same tile width so columns stay aligned.
        final cols = rows.first.length;
        final w = ((available - _gapX * (cols - 1)) / cols).floorToDouble();
        widths.fillRange(0, count, w);
      } else {
        // Share each row's leftover space equally between its tiles.
        for (final row in rows) {
          final extra = (available - _rowWidth(row, widths)) / row.length;
          for (final i in row) {
            widths[i] = (widths[i] + extra).floorToDouble();
          }
        }
      }
    }

    // Pass 1: measure natural height of every tile at its resolved width.
    final heights = List<double>.filled(count, 0);
    RenderBox? child = firstChild;
    int i = 0;
    while (child != null) {
      child.layout(BoxConstraints(minWidth: widths[i], maxWidth: widths[i]), parentUsesSize: true);
      heights[i] = child.size.height;
      child = (child.parentData as _ParentData).nextSibling;
      i++;
    }

    final rowHeights = List<double>.filled(rows.length, 0);
    final uniformH = _uniformHeight ? heights.fold<double>(0, math.max) : 0.0;
    for (int r = 0; r < rows.length; r++) {
      rowHeights[r] = _uniformHeight ? uniformH : rows[r].map((idx) => heights[idx]).fold<double>(0, math.max);
    }

    // Pass 2: position + finalize each child at its row's height.
    double y = 0;
    double maxRowWidth = 0;
    child = firstChild;
    for (int r = 0; r < rows.length; r++) {
      final rowH = rowHeights[r];
      double x = 0;
      for (final idx in rows[r]) {
        final box = child!;
        box.layout(
          BoxConstraints(minWidth: widths[idx], maxWidth: widths[idx], minHeight: rowH, maxHeight: rowH),
          parentUsesSize: true,
        );
        (box.parentData as _ParentData).offset = Offset(x, y);
        x += widths[idx] + _gapX;
        child = (box.parentData as _ParentData).nextSibling;
      }
      maxRowWidth = math.max(maxRowWidth, x - _gapX);
      y += rowH + (r < rows.length - 1 ? _gapY : 0);
    }

    size = constraints.constrain(Size(grow ? available : maxRowWidth, y));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as _ParentData;
      context.paintChild(child, offset + pd.offset);
      child = pd.nextSibling;
    }
  }
}
