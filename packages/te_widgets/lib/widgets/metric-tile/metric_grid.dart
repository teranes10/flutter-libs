import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A responsive grid purpose-built for laying out [TMetricTile] (or any KPI
/// tile) children with uniform sizing: every tile in the same row shares the
/// same width, and every tile across the whole grid shares the same height
/// (the tallest child's natural height), so metric rows never look shrunk,
/// lopsided, or unevenly stretched.
///
/// The column count is derived automatically from the available width and
/// [minTileWidth] — no manual `sm`/`md`/`lg` spans required. Pass [columns]
/// to pin an exact column count instead.
///
/// ## Basic Usage
///
/// ```dart
/// TMetricGrid(
///   minTileWidth: 200,
///   children: [
///     TMetricTile(label: 'Total Amount', value: 'Rs. 3,200', ...),
///     TMetricTile(label: 'Subtotal', value: 'Rs. 3,200', ...),
///     TMetricTile(label: 'Line Items', value: '4 items', ...),
///     TMetricTile(label: 'Paid Amount', value: 'Rs. 3,500', ...),
///   ],
/// )
/// ```
class TMetricGrid extends StatelessWidget {
  /// The tile widgets to lay out.
  final List<Widget> children;

  /// Preferred minimum width for each tile before wrapping to fewer columns.
  /// Ignored when [columns] is set.
  final double minTileWidth;

  /// Pins an exact number of columns, overriding the automatic calculation.
  final int? columns;

  /// Horizontal spacing between tiles.
  final double gapX;

  /// Vertical spacing between rows.
  final double gapY;

  /// Whether every tile (across all rows) shares one uniform height, equal
  /// to the tallest tile in the whole grid. When false, height is only
  /// equalized within each row.
  final bool uniformHeight;

  const TMetricGrid({
    super.key,
    required this.children,
    this.minTileWidth = 180,
    this.columns,
    this.gapX = 12,
    this.gapY = 12,
    this.uniformHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    return _MetricGrid(
      minTileWidth: minTileWidth,
      columns: columns,
      gapX: gapX,
      gapY: gapY,
      uniformHeight: uniformHeight,
      children: children,
    );
  }
}

class _ParentData extends ContainerBoxParentData<RenderBox> {}

class _MetricGrid extends MultiChildRenderObjectWidget {
  final double minTileWidth;
  final int? columns;
  final double gapX;
  final double gapY;
  final bool uniformHeight;

  const _MetricGrid({
    required super.children,
    required this.minTileWidth,
    required this.columns,
    required this.gapX,
    required this.gapY,
    required this.uniformHeight,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMetricGrid(
        minTileWidth: minTileWidth,
        columns: columns,
        gapX: gapX,
        gapY: gapY,
        uniformHeight: uniformHeight,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderMetricGrid ro) {
    ro
      ..minTileWidth = minTileWidth
      ..columns = columns
      ..gapX = gapX
      ..gapY = gapY
      ..uniformHeight = uniformHeight;
  }
}

class _RenderMetricGrid extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _ParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _ParentData> {
  double _minTileWidth;
  int? _columns;
  double _gapX;
  double _gapY;
  bool _uniformHeight;

  _RenderMetricGrid({
    required double minTileWidth,
    required int? columns,
    required double gapX,
    required double gapY,
    required bool uniformHeight,
  })  : _minTileWidth = minTileWidth,
        _columns = columns,
        _gapX = gapX,
        _gapY = gapY,
        _uniformHeight = uniformHeight;

  set minTileWidth(double v) {
    if (_minTileWidth != v) {
      _minTileWidth = v;
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

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ParentData) {
      child.parentData = _ParentData();
    }
  }

  int _computeColumns(double maxWidth, int childCount) {
    if (_columns != null && _columns! > 0) return math.min(_columns!, childCount);
    if (childCount == 0) return 1;
    final fit = ((maxWidth + _gapX) / (_minTileWidth + _gapX)).floor();
    return fit.clamp(1, childCount);
  }

  @override
  void performLayout() {
    final count = childCount;
    if (count == 0) {
      size = constraints.smallest;
      return;
    }

    final maxWidth = constraints.maxWidth;
    final cols = _computeColumns(maxWidth, count);
    final rows = (count / cols).ceil();
    final tileWidth = ((maxWidth - (_gapX * (cols - 1))) / cols).floorToDouble();

    // Pass 1: measure natural (unconstrained-height) size of every tile at
    // the resolved tile width, to determine row heights / uniform height.
    final heights = List<double>.filled(count, 0);
    RenderBox? child = firstChild;
    int i = 0;
    while (child != null) {
      child.layout(BoxConstraints(minWidth: tileWidth, maxWidth: tileWidth), parentUsesSize: true);
      heights[i] = child.size.height;
      child = (child.parentData as _ParentData).nextSibling;
      i++;
    }

    final rowHeights = List<double>.filled(rows, 0);
    if (_uniformHeight) {
      final uniformH = heights.fold<double>(0, math.max);
      for (int r = 0; r < rows; r++) {
        rowHeights[r] = uniformH;
      }
    } else {
      for (int idx = 0; idx < count; idx++) {
        final r = idx ~/ cols;
        rowHeights[r] = math.max(rowHeights[r], heights[idx]);
      }
    }

    // Pass 2: position + finalize each child at its row's height.
    double y = 0;
    child = firstChild;
    i = 0;
    for (int r = 0; r < rows; r++) {
      final rowH = rowHeights[r];
      double x = 0;
      final colsInRow = math.min(cols, count - r * cols);
      for (int c = 0; c < colsInRow; c++) {
        final box = child!;
        box.layout(
          BoxConstraints(minWidth: tileWidth, maxWidth: tileWidth, minHeight: rowH, maxHeight: rowH),
          parentUsesSize: true,
        );
        (box.parentData as _ParentData).offset = Offset(x, y);
        x += tileWidth + _gapX;
        child = (box.parentData as _ParentData).nextSibling;
        i++;
      }
      y += rowH + (r < rows - 1 ? _gapY : 0);
    }

    size = constraints.constrain(Size(maxWidth, y));
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
