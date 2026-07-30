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
    this.margin = const EdgeInsets.only(bottom: 4),
    this.padding = const EdgeInsets.all(6),
    this.elevation = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    required this.backgroundColor,
    required this.border,
    required super.keyStyle,
    required super.labelStyle,
    required super.valueStyle,
    super.gridSpacing,
    super.minGridColWidth,
    super.forceKeyValue,
    super.keyValueBreakPoint,
    super.showLeftBorder,
    super.alignment,
    super.narrowPadding,
    super.narrowItemBottomSpacing,
    super.narrowKeyFlex,
    super.narrowValueFlex,
    super.narrowGap,
    super.gridCellPadding,
    super.gridCellGap,
    super.maxColWidthFraction,
    super.minFractionFixed,
    super.minFractionStructured,
    super.minFractionCompact,
    super.minFractionProse,
    super.additionalNaturalWidth,
    super.maxItemsPerRow,
    super.gridInline,
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

  @override
  TTableMobileCardTheme copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? elevation,
    BorderRadius? borderRadius,
    WidgetStateProperty<Color>? backgroundColor,
    WidgetStateProperty<Border>? border,
    TextStyle? keyStyle,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    double? gridSpacing,
    double? minGridColWidth,
    bool? forceKeyValue,
    double? keyValueBreakPoint,
    bool? showLeftBorder,
    Alignment? alignment,
    EdgeInsets? narrowPadding,
    double? narrowItemBottomSpacing,
    int? narrowKeyFlex,
    int? narrowValueFlex,
    double? narrowGap,
    EdgeInsets? gridCellPadding,
    double? gridCellGap,
    double? maxColWidthFraction,
    double? minFractionFixed,
    double? minFractionStructured,
    double? minFractionCompact,
    double? minFractionProse,
    double? additionalNaturalWidth,
    int? maxItemsPerRow,
    bool? gridInline,
  }) {
    return TTableMobileCardTheme(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      keyStyle: keyStyle ?? this.keyStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      minGridColWidth: minGridColWidth ?? this.minGridColWidth,
      forceKeyValue: forceKeyValue ?? this.forceKeyValue,
      keyValueBreakPoint: keyValueBreakPoint ?? this.keyValueBreakPoint,
      showLeftBorder: showLeftBorder ?? this.showLeftBorder,
      alignment: alignment ?? this.alignment,
      narrowPadding: narrowPadding ?? this.narrowPadding,
      narrowItemBottomSpacing: narrowItemBottomSpacing ?? this.narrowItemBottomSpacing,
      narrowKeyFlex: narrowKeyFlex ?? this.narrowKeyFlex,
      narrowValueFlex: narrowValueFlex ?? this.narrowValueFlex,
      narrowGap: narrowGap ?? this.narrowGap,
      gridCellPadding: gridCellPadding ?? this.gridCellPadding,
      gridCellGap: gridCellGap ?? this.gridCellGap,
      maxColWidthFraction: maxColWidthFraction ?? this.maxColWidthFraction,
      minFractionFixed: minFractionFixed ?? this.minFractionFixed,
      minFractionStructured: minFractionStructured ?? this.minFractionStructured,
      minFractionCompact: minFractionCompact ?? this.minFractionCompact,
      minFractionProse: minFractionProse ?? this.minFractionProse,
      additionalNaturalWidth: additionalNaturalWidth ?? this.additionalNaturalWidth,
      maxItemsPerRow: maxItemsPerRow ?? this.maxItemsPerRow,
      gridInline: gridInline ?? this.gridInline,
    );
  }
}
