import 'package:flutter/material.dart';

/// Minimum width (inclusive) for tablet/medium screens.
const double kMobileBreakpoint = 600;

/// Minimum width (inclusive) for desktop/large screens.
const double kDesktopBreakpoint = 1024;

/// Screen width breakpoints for responsive layouts.
enum TBreakpoint {
  sm,
  md,
  lg;

  /// Determines the breakpoint based on width.
  static TBreakpoint getBreakpoint(double width) {
    if (width >= kDesktopBreakpoint) return TBreakpoint.lg;
    if (width >= kMobileBreakpoint) return TBreakpoint.md;
    return TBreakpoint.sm;
  }
}

/// Defines the column span of a component at different breakpoints.
class TGridSize {
  /// Span at small screens
  final int? sm;

  /// Span at medium screens
  final int? md;

  /// Span at large screens
  final int? lg;

  /// Creates a responsive grid size.
  const TGridSize({this.sm, this.md, this.lg});

  /// Gets the span for a specific breakpoint, falling back to smaller sizes or 12 (full width).
  int getSpan(TBreakpoint bp) {
    switch (bp) {
      case TBreakpoint.lg:
        return lg ?? md ?? sm ?? 12;
      case TBreakpoint.md:
        return md ?? sm ?? 12;
      case TBreakpoint.sm:
        return sm ?? 12;
    }
  }
}

/// A responsive grid row that uses a 12-column system.
class TGridRow extends StatelessWidget {
  /// The columns to display in this row.
  final List<Widget> children;

  /// The horizontal spacing between columns.
  final double gapX;

  /// The vertical spacing between columns.
  final double gapY;

  /// How the children should be placed along the main axis.
  final WrapAlignment alignment;

  /// How the children should be placed along the cross axis.
  final WrapCrossAlignment crossAxisAlignment;

  const TGridRow({
    super.key,
    required this.children,
    this.gapX = 20.0,
    this.gapY = 26.0,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = TBreakpoint.getBreakpoint(constraints.maxWidth);
        final totalWidth = constraints.maxWidth;
        // 12 column system: totalWidth = 12 * unitWidth + 11 * gapX
        final unitWidth = (totalWidth - (gapX * 11)) / 12;

        return Wrap(
          spacing: gapX,
          runSpacing: gapY,
          alignment: alignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children.map((child) {
            if (child is TGridCol) {
              return child.buildWithGrid(context, breakpoint, unitWidth, gapX);
            }
            return child;
          }).toList(),
        );
      },
    );
  }
}

/// A responsive grid column to be used within a [TGridRow].
class TGridCol extends StatelessWidget {
  /// The widget to display inside the column.
  final Widget child;

  /// Span at small screens
  final int? sm;

  /// Span at medium screens
  final int? md;

  /// Span at large screens (1024px+).
  final int? lg;

  /// Optional padding for the column content.
  final EdgeInsetsGeometry? padding;

  const TGridCol({
    super.key,
    required this.child,
    this.sm,
    this.md,
    this.lg,
    this.padding,
  });

  /// Internal method used by [TGridRow] to calculate the width.
  Widget buildWithGrid(BuildContext context, TBreakpoint bp, double unitWidth, double gapX) {
    final size = TGridSize(sm: sm, md: md, lg: lg);
    final span = size.getSpan(bp);
    final width = (unitWidth * span) + ((span - 1) * gapX);

    return SizedBox(
      width: width,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
