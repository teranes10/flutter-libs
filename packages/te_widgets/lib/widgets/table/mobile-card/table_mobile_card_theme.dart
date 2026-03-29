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
  final WidgetStateProperty<Color> backgroundColor;
  final WidgetStateProperty<Border> border;

  /// Creates a mobile card theme.
  const TTableMobileCardTheme({
    this.margin = const EdgeInsets.only(bottom: 12),
    this.padding = const EdgeInsets.all(16),
    this.elevation = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    required this.backgroundColor,
    required this.border,
    required super.keyStyle,
    required super.labelStyle,
    required super.valueStyle,
    super.gridSpacing = 0,
    super.minGridColWidth = 110,
    super.forceKeyValue = false,
    super.keyValueBreakPoint = 350,
  });

  factory TTableMobileCardTheme.defaultTheme(ColorScheme colors) {
    final baseTheme = TKeyValueTheme.defaultTheme(colors);
    return TTableMobileCardTheme(
      keyStyle: baseTheme.keyStyle,
      labelStyle: baseTheme.labelStyle,
      valueStyle: baseTheme.valueStyle,
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? colors.primaryContainer.withAlpha(25) : colors.surface,
      ),
      border: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Border.all(color: colors.primary.withAlpha(50), width: 2)
            : Border.all(color: colors.outline),
      ),
    );
  }
}
