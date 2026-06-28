import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TAlignedRow
// ─────────────────────────────────────────────────────────────────────────────
//
// A custom layout widget that places "left" and "right" children on the same
// row when space allows, and wraps gracefully when it doesn't.
//
// New behaviour (on top of the original):
//
//  moveAllToSecondRow (default true)
//    When the right group doesn't fit beside the last left row:
//    • If ALL right items fit on one row → honour moveAllToSecondRow.
//        true  → put all right items on a new row (right-aligned).
//        false → move only the last right item down (keep as many on the
//                first row as possible).
//    • This logic only applies when the total row-count would be ≤ 2.
//      If rows > wrapperModeThreshold the widget enters wrapper mode instead.
//
//  wrapperModeThreshold (default 2)
//    When the number of rows required exceeds this value the widget switches
//    to "wrapper mode": left/right metadata is ignored and all items flow
//    together as a flat list, identical to a Wrap.
//
//  wrapperExpanded (default false)
//    In wrapper mode: stretch each item to fill its slot width.
//
//  wrapperExpandedRatioBased (default true)
//    In wrapper mode + expanded: distribute slot widths proportionally to
//    each item's intrinsic width (ratio-based).  When false every item gets
//    an equal share of the row width (the original expanded behaviour).
//
//  wrapperAlignment (default MainAxisAlignment.center)
//    In wrapper mode (non-expanded): how to align items within each row.
//
//  Text-widget width measurement
//    When a child is a Text widget the render object detects this via
//    _TextMeasureParentData and measures the text with TextPainter so the
//    greedy row-builder uses an accurate intrinsic width instead of the
//    unconstrained layout width.

class TAlignedRow extends MultiChildRenderObjectWidget {
  final double spacing;
  final double rowSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final double? expandBelowWidth;

  // ── new props ──────────────────────────────────────────────────────────────
  final bool moveAllToSecondRow;
  final int wrapperModeThreshold;
  final bool wrapperExpanded;
  final bool wrapperExpandedRatioBased;
  final MainAxisAlignment wrapperAlignment;

  TAlignedRow({
    super.key,
    List<Widget> left = const [],
    List<Widget> right = const [],
    this.spacing = 8.0,
    this.rowSpacing = 8.0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.expandBelowWidth,
    // new
    this.moveAllToSecondRow = false,
    this.wrapperModeThreshold = 1,
    this.wrapperExpanded = false,
    this.wrapperExpandedRatioBased = true,
    this.wrapperAlignment = MainAxisAlignment.center,
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
        moveAllToSecondRow: moveAllToSecondRow,
        wrapperModeThreshold: wrapperModeThreshold,
        wrapperExpanded: wrapperExpanded,
        wrapperExpandedRatioBased: wrapperExpandedRatioBased,
        wrapperAlignment: wrapperAlignment,
      );

  @override
  void updateRenderObject(BuildContext context, RenderAlignedRow renderObject) {
    renderObject
      ..spacing = spacing
      ..rowSpacing = rowSpacing
      ..crossAxisAlignment = crossAxisAlignment
      ..mainAxisAlignment = mainAxisAlignment
      ..expandBelowWidth = expandBelowWidth
      ..moveAllToSecondRow = moveAllToSecondRow
      ..wrapperModeThreshold = wrapperModeThreshold
      ..wrapperExpanded = wrapperExpanded
      ..wrapperExpandedRatioBased = wrapperExpandedRatioBased
      ..wrapperAlignment = wrapperAlignment;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal parent-data
// ─────────────────────────────────────────────────────────────────────────────

class _AlignedRowParentData extends ContainerBoxParentData<RenderBox> {
  bool isRight = false;

  // Populated during _measure() when the child is a Text widget.
  double? measuredTextWidth;
}

// ─────────────────────────────────────────────────────────────────────────────
// _Side — carries isRight metadata to the render object
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Child record
// ─────────────────────────────────────────────────────────────────────────────

typedef _Child = ({
  RenderBox box,
  Size size,
  bool isRight,
  // intrinsic width used for row-building decisions (may differ from size.width
  // when the child is a Text that has been laid out with tight constraints).
  double intrinsicWidth,
});

// ─────────────────────────────────────────────────────────────────────────────
// RenderAlignedRow
// ─────────────────────────────────────────────────────────────────────────────

class RenderAlignedRow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _AlignedRowParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _AlignedRowParentData> {
  // ── stored props ───────────────────────────────────────────────────────────

  double _spacing;
  double _rowSpacing;
  CrossAxisAlignment _crossAxisAlignment;
  MainAxisAlignment _mainAxisAlignment;
  double? _expandBelowWidth;
  bool _moveAllToSecondRow;
  int _wrapperModeThreshold;
  bool _wrapperExpanded;
  bool _wrapperExpandedRatioBased;
  MainAxisAlignment _wrapperAlignment;

  RenderAlignedRow({
    required double spacing,
    required double rowSpacing,
    required CrossAxisAlignment crossAxisAlignment,
    required MainAxisAlignment mainAxisAlignment,
    double? expandBelowWidth,
    required bool moveAllToSecondRow,
    required int wrapperModeThreshold,
    required bool wrapperExpanded,
    required bool wrapperExpandedRatioBased,
    required MainAxisAlignment wrapperAlignment,
  })  : _spacing = spacing,
        _rowSpacing = rowSpacing,
        _crossAxisAlignment = crossAxisAlignment,
        _mainAxisAlignment = mainAxisAlignment,
        _expandBelowWidth = expandBelowWidth,
        _moveAllToSecondRow = moveAllToSecondRow,
        _wrapperModeThreshold = wrapperModeThreshold,
        _wrapperExpanded = wrapperExpanded,
        _wrapperExpandedRatioBased = wrapperExpandedRatioBased,
        _wrapperAlignment = wrapperAlignment;

  // ── setters ────────────────────────────────────────────────────────────────

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

  set moveAllToSecondRow(bool v) {
    if (_moveAllToSecondRow != v) {
      _moveAllToSecondRow = v;
      markNeedsLayout();
    }
  }

  set wrapperModeThreshold(int v) {
    if (_wrapperModeThreshold != v) {
      _wrapperModeThreshold = v;
      markNeedsLayout();
    }
  }

  set wrapperExpanded(bool v) {
    if (_wrapperExpanded != v) {
      _wrapperExpanded = v;
      markNeedsLayout();
    }
  }

  set wrapperExpandedRatioBased(bool v) {
    if (_wrapperExpandedRatioBased != v) {
      _wrapperExpandedRatioBased = v;
      markNeedsLayout();
    }
  }

  set wrapperAlignment(MainAxisAlignment v) {
    if (_wrapperAlignment != v) {
      _wrapperAlignment = v;
      markNeedsLayout();
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  bool get _isLegacyExpanded => _expandBelowWidth != null && constraints.maxWidth < _expandBelowWidth!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _AlignedRowParentData) {
      child.parentData = _AlignedRowParentData();
    }
  }

  // ── Text-width measurement via TextPainter ─────────────────────────────────
  //
  // Walk the element tree to find the first Text widget that corresponds to
  // this RenderBox.  This is done by looking at the RenderObject's owner
  // BuildContext (available as the Element attached to the RenderObject).

  /// Returns the intrinsic text width for [box] if it renders a Text widget,
  /// otherwise returns null.
  double? _measureTextWidth(RenderBox box) {
    // Access the element associated with this render object.
    final element = box.debugCreator;
    if (element is! Element) return null;

    // Walk up/into the element subtree to find a Text widget.
    Text? textWidget;
    void visitor(Element el) {
      if (textWidget != null) return;
      if (el.widget is Text) {
        textWidget = el.widget as Text;
        return;
      }
      el.visitChildren(visitor);
    }

    element.visitChildren(visitor);

    if (textWidget == null) return null;

    final tw = textWidget!;
    final String text = tw.data ?? tw.textSpan?.toPlainText() ?? '';
    if (text.isEmpty) return null;

    // Resolve style: merge widget style with the ambient DefaultTextStyle.
    // We need a BuildContext for that — use the element itself.
    TextStyle resolvedStyle = const TextStyle();
    if (element is StatelessElement || element is StatefulElement) {
      final defaultStyle = DefaultTextStyle.of(element).style;
      resolvedStyle = defaultStyle.merge(tw.style);
    } else {
      resolvedStyle = tw.style ?? const TextStyle();
    }

    final span = TextSpan(
      text: text,
      style: resolvedStyle,
      children: tw.textSpan is TextSpan ? (tw.textSpan as TextSpan).children : null,
    );

    final painter = TextPainter(
      text: span,
      textDirection: tw.textDirection ?? TextDirection.ltr,
      textScaler: tw.textScaler ?? TextScaler.noScaling,
      maxLines: tw.maxLines,
      locale: tw.locale,
      strutStyle: tw.strutStyle,
      textWidthBasis: tw.textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior: tw.textHeightBehavior,
    )..layout();

    return painter.width;
  }

  // ── Pass 1: measure every child ───────────────────────────────────────────

  List<_Child> _measure(double maxWidth) {
    final out = <_Child>[];
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as _AlignedRowParentData;
      child.layout(BoxConstraints(maxWidth: maxWidth), parentUsesSize: true);

      // Try to get a more accurate intrinsic width for Text children.
      final textW = _measureTextWidth(child);
      final intrinsicWidth = textW ?? child.size.width;

      out.add((
        box: child,
        size: child.size,
        isRight: pd.isRight,
        intrinsicWidth: intrinsicWidth,
      ));
      child = pd.nextSibling;
    }
    return out;
  }

  // ── Row metric helpers ────────────────────────────────────────────────────

  double _rowWidth(List<_Child> items) {
    if (items.isEmpty) return 0;
    return items.fold(0.0, (s, c) => s + c.intrinsicWidth) + _spacing * (items.length - 1);
  }

  double _rowHeight(List<_Child> items) => items.fold(0.0, (m, c) => c.box.size.height > m ? c.box.size.height : m);

  double _childY(double rowY, double rowH, double childH) => switch (_crossAxisAlignment) {
        CrossAxisAlignment.center => rowY + (rowH - childH) / 2,
        CrossAxisAlignment.end => rowY + rowH - childH,
        _ => rowY,
      };

  // ── Placement helpers ─────────────────────────────────────────────────────

  void _placeRow(
    List<_Child> items,
    double y,
    double rowH,
    double maxWidth,
    MainAxisAlignment align,
    bool dry,
  ) {
    if (dry || items.isEmpty) return;

    if (_isLegacyExpanded) {
      final slotW = (maxWidth - _spacing * (items.length - 1)) / items.length;
      double x = 0;
      for (final c in items) {
        c.box.layout(BoxConstraints.tightFor(width: slotW), parentUsesSize: true);
        final cy = _childY(y, rowH, c.box.size.height);
        (c.box.parentData as _AlignedRowParentData).offset = Offset(x, cy);
        x += slotW + _spacing;
      }
      return;
    }

    final usedW = _rowWidth(items);

    if (align == MainAxisAlignment.spaceBetween && items.length > 1) {
      final gap = (maxWidth - items.fold(0.0, (s, c) => s + c.intrinsicWidth)) / (items.length - 1);
      double cx = 0;
      for (final c in items) {
        final cy = _childY(y, rowH, c.size.height);
        (c.box.parentData as _AlignedRowParentData).offset = Offset(cx, cy);
        cx += c.intrinsicWidth + gap;
      }
      return;
    }

    double x = switch (align) {
      MainAxisAlignment.end => maxWidth - usedW,
      MainAxisAlignment.center => (maxWidth - usedW) / 2,
      _ => 0,
    };

    for (final c in items) {
      final cy = _childY(y, rowH, c.size.height);
      (c.box.parentData as _AlignedRowParentData).offset = Offset(x, cy);
      x += c.intrinsicWidth + _spacing;
    }
  }

  // ── Greedy row-builder ────────────────────────────────────────────────────

  List<List<_Child>> _buildRows(List<_Child> items, double maxWidth) {
    final rows = <List<_Child>>[];
    var current = <_Child>[];
    var currentW = 0.0;

    for (final item in items) {
      final needed = current.isEmpty ? item.intrinsicWidth : currentW + _spacing + item.intrinsicWidth;

      if (needed > maxWidth && current.isNotEmpty) {
        rows.add(current);
        current = [item];
        currentW = item.intrinsicWidth;
      } else {
        current.add(item);
        currentW = needed;
      }
    }
    if (current.isNotEmpty) rows.add(current);
    return rows;
  }

  // ── Row count estimate (dry, no placement) ────────────────────────────────

  int _estimateRows(List<_Child> children, double maxWidth) {
    if (_isLegacyExpanded) {
      // In legacy-expanded mode every child gets its own slot on the same row.
      return _buildRows(children, maxWidth).length;
    }
    final left = children.where((c) => !c.isRight).toList();
    final right = children.where((c) => c.isRight).toList();
    if (left.isEmpty && right.isEmpty) return 0;
    if (right.isEmpty) return _buildRows(left, maxWidth).length;
    if (left.isEmpty) return _buildRows(right, maxWidth).length;

    final leftRows = _buildRows(left, maxWidth);
    final rw = _rowWidth(right);
    final lw = _rowWidth(leftRows.last);
    if (lw + _spacing + rw <= maxWidth) return leftRows.length;

    // Right doesn't fit beside last left row.
    final rightRows = _buildRows(right, maxWidth);
    return leftRows.length + rightRows.length;
  }

  // ── Main flow ─────────────────────────────────────────────────────────────

  double _flow(List<_Child> children, double maxWidth, bool dry) {
    if (children.isEmpty) return 0;

    // ── Legacy "expandBelowWidth" mode (unchanged from original) ─────────────
    if (_isLegacyExpanded) {
      return _flowLegacyExpanded(children, maxWidth, dry);
    }

    final left = children.where((c) => !c.isRight).toList();
    final right = children.where((c) => c.isRight).toList();

    if (left.isEmpty && right.isEmpty) return 0;

    // ── Estimate total rows to decide whether to enter wrapper mode ──────────
    final estimatedRows = _estimateRows(children, maxWidth);
    if (estimatedRows > _wrapperModeThreshold) {
      return _flowWrapper(children, maxWidth, dry);
    }

    // ── Normal two-sided flow ─────────────────────────────────────────────────
    if (right.isEmpty) return _flowLeft(left, maxWidth, 0, dry);
    if (left.isEmpty) return _flowRight(right, maxWidth, 0, dry);

    final leftRows = _buildRows(left, maxWidth);
    final rw = _rowWidth(right);
    final lw = _rowWidth(leftRows.last);
    final combinedFits = lw + _spacing + rw <= maxWidth;

    double y = 0;

    if (combinedFits) {
      // All left rows except the last.
      for (int i = 0; i < leftRows.length - 1; i++) {
        final row = leftRows[i];
        final rh = _rowHeight(row);
        _placeRow(row, y, rh, maxWidth, MainAxisAlignment.start, dry);
        y += rh + _rowSpacing;
      }
      // Last left row + right items on the same line.
      final allOnRow = [...leftRows.last, ...right];
      final rh = _rowHeight(allOnRow);
      if (!dry) {
        _placeRow(leftRows.last, y, rh, maxWidth, MainAxisAlignment.start, dry);
        _placeRow(right, y, rh, maxWidth, MainAxisAlignment.end, dry);
      }
      y += rh;
    } else {
      // Right doesn't fit beside the last left row.
      // Decide whether to apply moveAllToSecondRow logic.
      final rightRows = _buildRows(right, maxWidth);
      final allRightFitOneRow = rightRows.length == 1;

      // Place all left rows first.
      for (int i = 0; i < leftRows.length; i++) {
        final row = leftRows[i];
        final rh = _rowHeight(row);
        _placeRow(row, y, rh, maxWidth, MainAxisAlignment.start, dry);
        y += rh + _rowSpacing;
      }

      if (allRightFitOneRow) {
        if (_moveAllToSecondRow) {
          // Put all right items on a single new row, right-aligned.
          final rh = _rowHeight(right);
          _placeRow(right, y, rh, maxWidth, MainAxisAlignment.end, dry);
          y += rh;
        } else {
          // Keep as many right items on the "last left row" line as possible,
          // move only the overflow item(s) to the next row.
          // Strategy: find the largest prefix of right that fits after lw.
          final available = maxWidth - lw - _spacing;
          final fits = <_Child>[];
          final overflow = <_Child>[];
          var usedW = 0.0;
          for (final c in right) {
            final needed = fits.isEmpty ? c.intrinsicWidth : usedW + _spacing + c.intrinsicWidth;
            if (needed <= available) {
              fits.add(c);
              usedW = needed;
            } else {
              overflow.add(c);
            }
          }
          if (fits.isNotEmpty) {
            // Re-place last left row with the fitting right items beside it.
            // We need to subtract the last rowSpacing we added above.
            y -= _rowSpacing;
            final combinedRow = [...leftRows.last, ...fits];
            final rh = _rowHeight(combinedRow);
            if (!dry) {
              // Re-place the last left row (y is now pointing at its start).
              _placeRow(leftRows.last, y, rh, maxWidth, MainAxisAlignment.start, dry);
              _placeRow(fits, y, rh, maxWidth, MainAxisAlignment.end, dry);
            }
            y += rh;
            if (overflow.isNotEmpty) {
              y += _rowSpacing;
              final rh2 = _rowHeight(overflow);
              _placeRow(overflow, y, rh2, maxWidth, MainAxisAlignment.end, dry);
              y += rh2;
            }
          } else {
            // Nothing fits alongside left — fall back to all-on-second-row.
            final rh = _rowHeight(right);
            _placeRow(right, y, rh, maxWidth, MainAxisAlignment.end, dry);
            y += rh;
          }
        }
      } else {
        // Right items themselves need more than one row → flow them wrapped.
        for (int i = 0; i < rightRows.length; i++) {
          final row = rightRows[i];
          final rh = _rowHeight(row);
          _placeRow(row, y, rh, maxWidth, MainAxisAlignment.end, dry);
          y += rh + (i < rightRows.length - 1 ? _rowSpacing : 0);
        }
      }
    }

    return y;
  }

  // ── Legacy expanded flow (original logic, kept intact) ────────────────────

  double _flowLegacyExpanded(List<_Child> children, double maxWidth, bool dry) {
    final rows = _buildRows(children, maxWidth);
    double y = 0;
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final count = row.length;
      final totalSpacing = _spacing * (count - 1);
      final availableForItems = maxWidth - totalSpacing;
      final baseSlot = (availableForItems / count).floorToDouble();
      final remainder = availableForItems - baseSlot * count;

      for (int j = 0; j < row.length; j++) {
        final isLast = j == row.length - 1;
        final slotW = isLast ? baseSlot + remainder : baseSlot;
        row[j].box.layout(
              BoxConstraints(minWidth: slotW, maxWidth: slotW, minHeight: 0, maxHeight: double.infinity),
              parentUsesSize: true,
            );
      }

      final rh = _rowHeight(row);
      if (!dry) {
        double x = 0;
        for (int j = 0; j < row.length; j++) {
          final isLast = j == row.length - 1;
          final slotW = isLast ? baseSlot + remainder : baseSlot;
          final cy = _childY(y, rh, row[j].box.size.height);
          (row[j].box.parentData as _AlignedRowParentData).offset = Offset(x, cy);
          x += slotW + _spacing;
        }
      }
      y += rh + (i < rows.length - 1 ? _rowSpacing : 0);
    }
    return y;
  }

  // ── Wrapper mode flow ─────────────────────────────────────────────────────
  //
  // Left/right metadata is ignored.  All children flow as a flat list.

  double _flowWrapper(List<_Child> children, double maxWidth, bool dry) {
    final rows = _buildRows(children, maxWidth);
    double y = 0;

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];

      if (_wrapperExpanded) {
        // ── Expanded wrapper: stretch items to fill the row ──────────────────
        final count = row.length;
        final totalSpacing = _spacing * (count - 1);
        final available = maxWidth - totalSpacing;

        List<double> slotWidths;
        if (_wrapperExpandedRatioBased) {
          // Distribute proportionally to each item's intrinsic width.
          final totalIntrinsic = row.fold(0.0, (s, c) => s + c.intrinsicWidth);
          if (totalIntrinsic > 0) {
            slotWidths = row.map((c) => (c.intrinsicWidth / totalIntrinsic) * available).toList();
          } else {
            slotWidths = List.filled(count, available / count);
          }
        } else {
          // Equal slots.
          final equalSlot = (available / count).floorToDouble();
          final remainder = available - equalSlot * count;
          slotWidths = [
            for (int j = 0; j < count; j++) j == count - 1 ? equalSlot + remainder : equalSlot,
          ];
        }

        // Re-layout each child with its assigned slot width.
        for (int j = 0; j < row.length; j++) {
          row[j].box.layout(
                BoxConstraints(
                  minWidth: slotWidths[j],
                  maxWidth: slotWidths[j],
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
            final cy = _childY(y, rh, row[j].box.size.height);
            (row[j].box.parentData as _AlignedRowParentData).offset = Offset(x, cy);
            x += slotWidths[j] + _spacing;
          }
        }
        y += rh + (i < rows.length - 1 ? _rowSpacing : 0);
      } else {
        // ── Non-expanded wrapper: align using wrapperAlignment ────────────────
        final rh = _rowHeight(row);
        _placeRowWithAlignment(row, y, rh, maxWidth, _wrapperAlignment, dry);
        y += rh + (i < rows.length - 1 ? _rowSpacing : 0);
      }
    }
    return y;
  }

  // Like _placeRow but always uses intrinsicWidth (no legacy-expanded path).
  void _placeRowWithAlignment(
    List<_Child> items,
    double y,
    double rowH,
    double maxWidth,
    MainAxisAlignment align,
    bool dry,
  ) {
    if (dry || items.isEmpty) return;

    final usedW = _rowWidth(items);

    if (align == MainAxisAlignment.spaceBetween && items.length > 1) {
      final gap = (maxWidth - items.fold(0.0, (s, c) => s + c.intrinsicWidth)) / (items.length - 1);
      double cx = 0;
      for (final c in items) {
        final cy = _childY(y, rowH, c.size.height);
        (c.box.parentData as _AlignedRowParentData).offset = Offset(cx, cy);
        cx += c.intrinsicWidth + gap;
      }
      return;
    }

    double x = switch (align) {
      MainAxisAlignment.end => maxWidth - usedW,
      MainAxisAlignment.center => (maxWidth - usedW) / 2,
      _ => 0,
    };

    for (final c in items) {
      final cy = _childY(y, rowH, c.size.height);
      (c.box.parentData as _AlignedRowParentData).offset = Offset(x, cy);
      x += c.intrinsicWidth + _spacing;
    }
  }

  // ── Left / right flow helpers (unchanged logic) ────────────────────────────

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

  // ── performLayout ──────────────────────────────────────────────────────────

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }
    final maxWidth = constraints.maxWidth;
    final children = _measure(maxWidth);

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
