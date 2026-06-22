import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:te_widgets/te_widgets.dart';

class TAlignedRow extends MultiChildRenderObjectWidget {
  final double spacing;
  final double rowSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final double? expandBelowWidth;

  TAlignedRow({
    super.key,
    List<Widget> left = const [],
    List<Widget> right = const [],
    this.spacing = 8.0,
    this.rowSpacing = 12.0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.expandBelowWidth = kMobileBreakpoint,
  }) : super(children: [
          ...left.map((w) => _Side(isRight: false, child: w)),
          ...right.map((w) => _Side(isRight: true, child: w)),
        ]);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderAlignedRow(
        spacing: spacing,
        rowSpacing: rowSpacing,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        expandBelowWidth: expandBelowWidth,
      );

  @override
  void updateRenderObject(BuildContext context, RenderAlignedRow renderObject) {
    renderObject
      ..spacing = spacing
      ..rowSpacing = rowSpacing
      ..crossAxisAlignment = crossAxisAlignment
      ..mainAxisAlignment = mainAxisAlignment
      ..expandBelowWidth = expandBelowWidth;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

typedef _Child = ({RenderBox box, Size size, bool isRight});

class RenderAlignedRow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _AlignedRowParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _AlignedRowParentData> {
  double _spacing;
  double _rowSpacing;
  CrossAxisAlignment _crossAxisAlignment;
  MainAxisAlignment _mainAxisAlignment;
  double? _expandBelowWidth;

  RenderAlignedRow({
    required double spacing,
    required double rowSpacing,
    required CrossAxisAlignment crossAxisAlignment,
    required MainAxisAlignment mainAxisAlignment,
    double? expandBelowWidth,
  })  : _spacing = spacing,
        _rowSpacing = rowSpacing,
        _crossAxisAlignment = crossAxisAlignment,
        _mainAxisAlignment = mainAxisAlignment,
        _expandBelowWidth = expandBelowWidth;

  set spacing(double v) {
    if (_spacing != v) {
      _spacing = v;
      markNeedsLayout();
    }
  }

  set rowSpacing(double v) {
    if (_rowSpacing != v) {
      _rowSpacing = v;
      markNeedsLayout();
    }
  }

  set crossAxisAlignment(CrossAxisAlignment v) {
    if (_crossAxisAlignment != v) {
      _crossAxisAlignment = v;
      markNeedsLayout();
    }
  }

  set mainAxisAlignment(MainAxisAlignment v) {
    if (_mainAxisAlignment != v) {
      _mainAxisAlignment = v;
      markNeedsLayout();
    }
  }

  set expandBelowWidth(double? v) {
    if (_expandBelowWidth != v) {
      _expandBelowWidth = v;
      markNeedsLayout();
    }
  }

  bool get _isExpanded => _expandBelowWidth != null && constraints.maxWidth < _expandBelowWidth!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _AlignedRowParentData) {
      child.parentData = _AlignedRowParentData();
    }
  }

  // ── Pass 1: measure every child ──────────────────────────────────────────

  List<_Child> _measure(double maxWidth) {
    final out = <_Child>[];
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as _AlignedRowParentData;
      child.layout(BoxConstraints(maxWidth: maxWidth), parentUsesSize: true);
      out.add((box: child, size: child.size, isRight: pd.isRight));
      child = pd.nextSibling;
    }
    return out;
  }

  // ── Row helpers ───────────────────────────────────────────────────────────

  double _rowWidth(List<_Child> items) {
    if (items.isEmpty) return 0;
    return items.fold(0.0, (s, c) => s + c.size.width) + _spacing * (items.length - 1);
  }

  double _rowHeight(List<_Child> items) => items.fold(0.0, (m, c) => c.box.size.height > m ? c.box.size.height : m);

  double _childY(double rowY, double rowHeight, double childHeight) => switch (_crossAxisAlignment) {
        CrossAxisAlignment.center => rowY + (rowHeight - childHeight) / 2,
        CrossAxisAlignment.end => rowY + rowHeight - childHeight,
        _ => rowY,
      };

  // ── Placement ─────────────────────────────────────────────────────────────

  void _placeRow(
    List<_Child> items,
    double y,
    double rowHeight,
    double maxWidth,
    MainAxisAlignment align,
    bool dry,
  ) {
    if (dry || items.isEmpty) return;

    if (_isExpanded) {
      // Each item gets an equal share of the full width.
      // Re-layout each child with tight width so it actually fills the slot.
      final slotWidth = (maxWidth - _spacing * (items.length - 1)) / items.length;
      double x = 0;
      for (final c in items) {
        // Re-layout with tight constraints so the child fills its slot.
        c.box.layout(
          BoxConstraints.tightFor(width: slotWidth),
          parentUsesSize: true,
        );
        final childY = _childY(y, rowHeight, c.box.size.height);
        (c.box.parentData as _AlignedRowParentData).offset = Offset(x, childY);
        x += slotWidth + _spacing;
      }
      return;
    }

    // Normal (non-expanded) placement with MainAxisAlignment.
    final usedWidth = _rowWidth(items);
    double x = switch (align) {
      MainAxisAlignment.end => maxWidth - usedWidth,
      MainAxisAlignment.center => (maxWidth - usedWidth) / 2,
      MainAxisAlignment.spaceBetween when items.length > 1 => 0,
      _ => 0,
    };

    if (align == MainAxisAlignment.spaceBetween && items.length > 1) {
      final gap = (maxWidth - items.fold(0.0, (s, c) => s + c.size.width)) / (items.length - 1);
      double cx = 0;
      for (final c in items) {
        final childY = _childY(y, rowHeight, c.size.height);
        (c.box.parentData as _AlignedRowParentData).offset = Offset(cx, childY);
        cx += c.size.width + gap;
      }
      return;
    }

    for (final c in items) {
      final childY = _childY(y, rowHeight, c.size.height);
      (c.box.parentData as _AlignedRowParentData).offset = Offset(x, childY);
      x += c.size.width + _spacing;
    }
  }

  // ── Pass 2: flow into rows ────────────────────────────────────────────────
  //
  // Strategy:
  //   • Flow left items into wrapped rows exactly like a left-aligned Wrap.
  //   • After all left rows are committed, see if the last left row has room
  //     for the entire right group on the SAME row (left ++ [spacer] ++ right).
  //   • If yes  → combine into one row with a Spacer between them.
  //   • If no   → right items flow into their own wrapped rows, right-aligned.
  //
  // This means right items wrap independently and never clip over left items.

  double _flow(List<_Child> children, double maxWidth, bool dry) {
    if (children.isEmpty) return 0;

    if (_isExpanded) {
      final rows = _buildRows(children, maxWidth);
      double y = 0;
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        final count = row.length;
        final totalSpacing = _spacing * (count - 1);
        final availableForItems = maxWidth - totalSpacing;

        // Distribute width without floating-point drift:
        // floor each slot, give remainder pixels to the last item.
        final baseSlot = (availableForItems / count).floorToDouble();
        final remainder = availableForItems - baseSlot * count;

        for (int j = 0; j < row.length; j++) {
          final isLast = j == row.length - 1;
          final slotWidth = isLast ? baseSlot + remainder : baseSlot;
          row[j].box.layout(
                BoxConstraints(
                  minWidth: slotWidth, // force the slot to be filled
                  maxWidth: slotWidth, // but no wider
                  minHeight: 0,
                  maxHeight: double.infinity,
                ),
                parentUsesSize: true,
              );
        }

        final rh = _rowHeight(row);

        if (!dry) {
          double x = 0;
          for (int j = 0; j < row.length; j++) {
            final slotWidth = j == row.length - 1 ? baseSlot + remainder : baseSlot;
            final childY = _childY(y, rh, row[j].box.size.height);
            (row[j].box.parentData as _AlignedRowParentData).offset = Offset(x, childY);
            x += slotWidth + _spacing;
          }
        }

        y += rh + (i < rows.length - 1 ? _rowSpacing : 0);
      }
      return y;
    }

    final left = children.where((c) => !c.isRight).toList();
    final right = children.where((c) => c.isRight).toList();

    if (left.isEmpty && right.isEmpty) return 0;
    if (right.isEmpty) return _flowLeft(left, maxWidth, 0, dry);
    if (left.isEmpty) return _flowRight(right, maxWidth, 0, dry);

    final leftRows = _buildRows(left, maxWidth);
    final rightRows = _buildRows(right, maxWidth);
    final lw = _rowWidth(leftRows.last);
    final rw = _rowWidth(right);
    final combinedFits = lw + _spacing + rw <= maxWidth;

    double y = 0;

    if (combinedFits) {
      for (int i = 0; i < leftRows.length - 1; i++) {
        final row = leftRows[i];
        final rh = _rowHeight(row);
        _placeRow(row, y, rh, maxWidth, MainAxisAlignment.start, dry);
        y += rh + _rowSpacing;
      }
      final allOnRow = [...leftRows.last, ...right];
      final rh = _rowHeight(allOnRow);
      if (!dry) {
        _placeRow(leftRows.last, y, rh, maxWidth, MainAxisAlignment.start, dry);
        _placeRow(right, y, rh, maxWidth, MainAxisAlignment.end, dry);
      }
      y += rh;
    } else {
      for (final row in leftRows) {
        final rh = _rowHeight(row);
        _placeRow(row, y, rh, maxWidth, MainAxisAlignment.start, dry);
        y += rh + _rowSpacing;
      }
      for (int i = 0; i < rightRows.length; i++) {
        final row = rightRows[i];
        final rh = _rowHeight(row);
        _placeRow(row, y, rh, maxWidth, MainAxisAlignment.end, dry);
        y += rh + (i < rightRows.length - 1 ? _rowSpacing : 0);
      }
    }

    return y;
  }

  double _flowLeft(List<_Child> items, double maxWidth, double startY, bool dry) {
    final rows = _buildRows(items, maxWidth);
    double y = startY;
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final rh = _rowHeight(row);
      _placeRow(row, y, rh, maxWidth, _mainAxisAlignment, dry);
      y += rh + (i < rows.length - 1 ? _rowSpacing : 0);
    }
    return y - startY;
  }

  double _flowRight(List<_Child> items, double maxWidth, double startY, bool dry) {
    final rows = _buildRows(items, maxWidth);
    double y = startY;
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final rh = _rowHeight(row);
      _placeRow(row, y, rh, maxWidth, MainAxisAlignment.end, dry);
      y += rh + (i < rows.length - 1 ? _rowSpacing : 0);
    }
    return y - startY;
  }

  // ── Greedy row-builder (no placement, just groups items into rows) ─────────

  List<List<_Child>> _buildRows(List<_Child> items, double maxWidth) {
    final rows = <List<_Child>>[];
    var current = <_Child>[];
    var currentW = 0.0;

    for (final item in items) {
      final needed = current.isEmpty ? item.size.width : currentW + _spacing + item.size.width;

      if (needed > maxWidth && current.isNotEmpty) {
        rows.add(current);
        current = [item];
        currentW = item.size.width;
      } else {
        current.add(item);
        currentW = needed;
      }
    }
    if (current.isNotEmpty) rows.add(current);
    return rows;
  }

  // ── performLayout ─────────────────────────────────────────────────────────

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }
    final maxWidth = constraints.maxWidth;
    final children = _measure(maxWidth);

    // Dry run to get height (expand mode re-layouts happen in real pass only).
    final totalHeight = _flow(children, maxWidth, true);
    size = constraints.constrain(Size(maxWidth, totalHeight));
    _flow(children, maxWidth, false);
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => defaultHitTestChildren(result, position: position);

  @override
  double computeMinIntrinsicHeight(double width) {
    final children = _measure(width);
    return _flow(children, width, true);
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);
}

class _AlignedRowParentData extends ContainerBoxParentData<RenderBox> {
  bool isRight = false;
}

class _Side extends ParentDataWidget<_AlignedRowParentData> {
  final bool isRight;
  const _Side({required this.isRight, required super.child});

  @override
  void applyParentData(RenderObject renderObject) {
    final pd = renderObject.parentData as _AlignedRowParentData;
    if (pd.isRight != isRight) {
      pd.isRight = isRight;
      (renderObject.parent as RenderObject).markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TAlignedRow;
}
