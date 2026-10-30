import 'package:flutter/material.dart';

/// A vertical stack of fixed-height sub-rows with optional hairline dividers.
///
/// Every child gets exactly [rowHeight], so sibling [TSubRows] placed in
/// different columns of the same table row line up without any span logic.
/// Use it to build grouped, matrix-like rows (e.g. a module card whose
/// permissions are stacked inside it).
///
/// ```dart
/// TSubRows(
///   rowHeight: 40,
///   children: [for (final p in module.permissions) Text(p.name)],
/// )
/// ```
///
/// See also:
/// - `TTableHeader.stacked`, which wraps this for table columns.
class TSubRows extends StatelessWidget {
  /// The sub-row contents, one per row.
  final List<Widget> children;

  /// Fixed height of every sub-row.
  final double rowHeight;

  /// Whether a divider is drawn between consecutive sub-rows.
  final bool showDividers;

  /// Divider color. Defaults to [ThemeData.dividerColor] at 50% opacity.
  final Color? dividerColor;

  /// Horizontal/vertical padding around each child, inside the divider lines.
  ///
  /// Padding (not margin) keeps the dividers spanning the full width of the cell.
  final EdgeInsetsGeometry padding;

  /// Alignment of each child inside its sub-row.
  final AlignmentGeometry alignment;

  const TSubRows({
    super.key,
    required this.children,
    this.rowHeight = 40,
    this.showDividers = true,
    this.dividerColor,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final color = dividerColor ?? Theme.of(context).dividerColor.withValues(alpha: Theme.of(context).dividerColor.a * 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < children.length; i++)
          SizedBox(
            height: rowHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: showDividers && i > 0 ? Border(top: BorderSide(color: color, width: 0.5)) : null,
              ),
              child: Padding(padding: padding, child: Align(alignment: alignment, child: children[i])),
            ),
          ),
      ],
    );
  }
}
