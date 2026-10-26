import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Packs children into as few rows as fit, then stretches the children of each
/// row to fill it, sharing the extra width in proportion to their natural widths.
class TTabFlow extends MultiChildRenderObjectWidget {
  final double spacing;
  final double runSpacing;

  const TTabFlow({super.key, super.children, this.spacing = 2, this.runSpacing = 2});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTabFlow(spacing, runSpacing);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderTabFlow)
      ..spacing = spacing
      ..runSpacing = runSpacing;
  }
}

class _FlowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderTabFlow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _FlowParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _FlowParentData> {
  _RenderTabFlow(this._spacing, this._runSpacing);

  double _spacing;
  double _runSpacing;

  set spacing(double v) {
    if (_spacing == v) return;
    _spacing = v;
    markNeedsLayout();
  }

  set runSpacing(double v) {
    if (_runSpacing == v) return;
    _runSpacing = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FlowParentData) child.parentData = _FlowParentData();
  }

  List<RenderBox> get _children {
    final result = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      result.add(child);
      child = childAfter(child);
    }
    return result;
  }

  List<List<RenderBox>> _rows(double maxWidth, Map<RenderBox, double> natural) {
    final rows = <List<RenderBox>>[];
    var current = <RenderBox>[];
    var used = 0.0;
    for (final child in _children) {
      final w = math.min(natural[child]!, maxWidth);
      final needed = current.isEmpty ? w : used + _spacing + w;
      if (current.isNotEmpty && needed > maxWidth) {
        rows.add(current);
        current = [child];
        used = w;
      } else {
        current.add(child);
        used = needed;
      }
    }
    if (current.isNotEmpty) rows.add(current);
    return rows;
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    final natural = {for (final c in _children) c: c.getMaxIntrinsicWidth(double.infinity)};
    var y = 0.0;
    for (final row in _rows(maxWidth, natural)) {
      final widths = [for (final c in row) math.min(natural[c]!, maxWidth)];
      final total = widths.fold(0.0, (a, b) => a + b);
      final free = maxWidth - total - _spacing * (row.length - 1);
      var x = 0.0;
      var rowHeight = 0.0;
      for (var i = 0; i < row.length; i++) {
        final w = widths[i] + (total > 0 ? free * widths[i] / total : 0);
        row[i].layout(BoxConstraints.tightFor(width: w), parentUsesSize: true);
        (row[i].parentData! as _FlowParentData).offset = Offset(x, y);
        x += w + _spacing;
        rowHeight = math.max(rowHeight, row[i].size.height);
      }
      y += rowHeight + _runSpacing;
    }
    size = constraints.constrain(Size(maxWidth, math.max(0, y - _runSpacing)));
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _children.fold(0.0, (m, c) => math.max(m, c.getMinIntrinsicWidth(height)));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _children.fold(0.0, (s, c) => s + c.getMaxIntrinsicWidth(height)) + _spacing * math.max(0, childCount - 1);

  @override
  double computeMinIntrinsicHeight(double width) => getMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) {
    final natural = {for (final c in _children) c: c.getMaxIntrinsicWidth(double.infinity)};
    var y = 0.0;
    for (final row in _rows(width, natural)) {
      y += row.fold(0.0, (m, c) => math.max(m, c.getMaxIntrinsicHeight(math.min(natural[c]!, width)))) + _runSpacing;
    }
    return math.max(0, y - _runSpacing);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => Size(constraints.maxWidth, computeMaxIntrinsicHeight(constraints.maxWidth));

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
