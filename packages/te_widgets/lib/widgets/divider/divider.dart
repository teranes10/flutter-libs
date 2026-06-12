import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A customizable divider widget that supports horizontal and vertical orientations.
///
/// `TDivider` uses the project's theme colors by default and provides
/// simple controls for thickness, indentation, and spacing.
class TDivider extends StatelessWidget {
  /// The color of the divider. Defaults to [ColorScheme.outlineVariant].
  final Color? color;

  /// The thickness of the divider line. Defaults to 1.0.
  final double? thickness;

  /// The amount of empty space before the divider.
  final double? indent;

  /// The amount of empty space after the divider.
  final double? endIndent;

  /// The total height (for horizontal) or width (for vertical) including padding.
  final double? space;

  /// Whether the divider should be vertical. Defaults to false (horizontal).
  final bool isVertical;

  const TDivider({
    super.key,
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
    this.space,
    this.isVertical = false,
  });

  /// Creates a vertical divider.
  const TDivider.vertical({
    super.key,
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
    this.space,
  }) : isVertical = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dividerColor = color ?? colors.outlineVariant;

    if (isVertical) {
      return VerticalDivider(
        width: space ?? 20,
        thickness: thickness ?? 1,
        indent: indent,
        endIndent: endIndent,
        color: dividerColor,
      );
    }

    return Divider(
      height: space ?? 20,
      thickness: thickness ?? 1,
      indent: indent,
      endIndent: endIndent,
      color: dividerColor,
    );
  }
}
