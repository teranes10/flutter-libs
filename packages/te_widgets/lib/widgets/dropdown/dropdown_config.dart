import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/menu/menu_theme.dart';

class TDropdownTheme extends TMenuTheme {
  const TDropdownTheme({
    required super.defaultColor,
    required super.hoverColor,
    required super.activeColor,
    required super.activeBackgroundColor,
    required super.borderColor,
    super.animationDuration,
    super.showDelay,
    super.hideDelay,
    super.alignment,
    super.offset,
    super.secondaryAlignment,
    super.secondaryOffset,
    super.boxConstraints,
    super.iconSize,
    super.arrowIconSize,
    super.gap,
    super.overlayElevation,
    super.overlayBorderRadius,
    super.overlayPadding,
    super.itemPadding,
    super.itemBorderRadius,
    super.fontSize,
    super.fontWeight,
  });

  factory TDropdownTheme.defaultTheme(ColorScheme? colors) {
    final colorScheme = colors ?? const ColorScheme.light();

    return TDropdownTheme(
      defaultColor: colorScheme.onSurfaceVariant,
      hoverColor: colorScheme.onSurface,
      activeColor: colorScheme.onPrimaryContainer,
      activeBackgroundColor: colorScheme.primaryContainer,
      borderColor: colorScheme.outline,
    );
  }
}
