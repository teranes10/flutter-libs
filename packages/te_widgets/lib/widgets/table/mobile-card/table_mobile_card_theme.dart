import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableMobileCardTheme extends TKeyValueTheme {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Border? border;
  final Border? selectedBorder;

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

  Color getBackgroundColor(ColorScheme colors, bool isSelected) {
    return isSelected ? (selectedBackgroundColor ?? colors.primaryContainer.withAlpha(25)) : (backgroundColor ?? colors.surface);
  }

  Border getBorder(ColorScheme colors, bool isSelected) {
    return isSelected
        ? (selectedBorder ?? Border.all(color: colors.primary.withAlpha(50), width: 2))
        : (border ?? Border.all(color: colors.outline));
  }
}
