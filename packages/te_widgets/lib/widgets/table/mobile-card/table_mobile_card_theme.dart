import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Theme configuration for [TTableMobileCard].
///
/// `TTableMobileCardTheme` extends [TKeyValueTheme] to style the mobile card
/// view of table rows. It adds card-specific properties like:
/// - Margins/Padding
/// - Elevation
/// - Border Radius
/// - Background and Border colors (normal/selected)
class TTableMobileCardTheme extends TKeyValueTheme {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Border? border;
  final Border? selectedBorder;

  /// Creates a mobile card theme.
  const TTableMobileCardTheme({
    this.margin = const EdgeInsets.only(bottom: 12),
    this.padding = const EdgeInsets.all(16),
    this.elevation = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.border,
    this.selectedBorder,
  });

  /// Returns the background color based on selection state.
  Color getBackgroundColor(ColorScheme colors, bool isSelected) {
    return isSelected ? (selectedBackgroundColor ?? colors.primaryContainer.withAlpha(25)) : (backgroundColor ?? colors.surface);
  }

  /// Returns the border based on selection state.
  Border getBorder(ColorScheme colors, bool isSelected) {
    return isSelected
        ? (selectedBorder ?? Border.all(color: colors.primary.withAlpha(50), width: 2))
        : (border ?? Border.all(color: colors.outline));
  }
}
