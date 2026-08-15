import 'package:flutter/material.dart';
import 'package:te_widgets/helpers/popup_position.dart';
import 'package:te_widgets/widgets/menu/menu_theme.dart';

/// Dropdown-flavored [TMenuTheme]. All the fields now live on the shared
/// base class — this just supplies dropdown's defaults.
class TDropdownTheme extends TMenuTheme {
  const TDropdownTheme({
    required super.defaultColor,
    required super.hoverColor,
    required super.activeColor,
    required super.activeBackgroundColor,
    required super.borderColor,
    super.animationDuration = const Duration(milliseconds: 200),
    super.showDelay = const Duration(milliseconds: 25),
    super.hideDelay = const Duration(milliseconds: 125),
    super.alignment = TPopupAlignment.bottomLeft,
    super.offset = 8.0,
    super.secondaryAlignment = TPopupAlignment.rightTop,
    super.secondaryOffset = 8.0,
    super.boxConstraints = const BoxConstraints(minWidth: 175),
    super.iconSize = 20.0,
    super.arrowIconSize = 11.0,
    super.gap = 10.0,
    super.overlayElevation = 8.0,
    super.overlayBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
    super.overlayPadding = const EdgeInsets.symmetric(vertical: 8),
    super.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    super.itemBorderRadius = const BorderRadius.all(Radius.circular(6.0)),
    super.fontSize = 14.0,
    super.fontWeight = FontWeight.w300,
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
