import 'package:flutter/material.dart';

/// Theme configuration for [TFilterField].
@immutable
class TFilterFieldTheme {
  /// Background color of the filter container card.
  final Color? backgroundColor;

  /// Border color of the filter container card.
  final Color? borderColor;

  /// Border radius of the filter container card.
  final double borderRadius;

  /// Padding of the filter container card.
  final EdgeInsets padding;

  /// Background color of each filter rule row.
  final Color? ruleBackgroundColor;

  /// Border color of each filter rule row.
  final Color? ruleBorderColor;

  /// Border radius of each filter rule row.
  final double ruleBorderRadius;

  /// Padding inside each filter rule row.
  final EdgeInsets rulePadding;

  /// Gap between fields within a rule row.
  final double fieldGap;

  /// Gap between different rule rows.
  final double rowGap;

  /// Creates a [TFilterFieldTheme].
  const TFilterFieldTheme({
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.padding = EdgeInsets.zero,
    this.ruleBackgroundColor,
    this.ruleBorderColor,
    this.ruleBorderRadius = 8.0,
    this.rulePadding = EdgeInsets.zero,
    this.fieldGap = 8.0,
    this.rowGap = 10.0,
  });

  /// Creates a copy of this theme with given properties replaced.
  TFilterFieldTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    EdgeInsets? padding,
    Color? ruleBackgroundColor,
    Color? ruleBorderColor,
    double? ruleBorderRadius,
    EdgeInsets? rulePadding,
    double? fieldGap,
    double? rowGap,
  }) =>
      TFilterFieldTheme(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        borderColor: borderColor ?? this.borderColor,
        borderRadius: borderRadius ?? this.borderRadius,
        padding: padding ?? this.padding,
        ruleBackgroundColor: ruleBackgroundColor ?? this.ruleBackgroundColor,
        ruleBorderColor: ruleBorderColor ?? this.ruleBorderColor,
        ruleBorderRadius: ruleBorderRadius ?? this.ruleBorderRadius,
        rulePadding: rulePadding ?? this.rulePadding,
        fieldGap: fieldGap ?? this.fieldGap,
        rowGap: rowGap ?? this.rowGap,
      );
}
