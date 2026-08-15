import 'package:flutter/material.dart';
import 'package:te_widgets/helpers/popup_position.dart';

/// Shared visual + timing + positioning configuration for the overlay-menu
/// engine. `TDropdownTheme` and `TSidebarTheme` both extend this so the
/// same overlay widgets (`TMenuOverlayPanel`, `TMenuOverlayItem`,
/// `TMenuRootTrigger`, `TMenuTooltip`) can render either one — previously
/// the sidebar hardcoded these as static `TSidebarConstants` values instead
/// of an instantiable theme, which is the main reason it couldn't share
/// code with the dropdown.
class TMenuTheme {
  final Color defaultColor;
  final Color hoverColor;
  final Color activeColor;
  final Color activeBackgroundColor;
  final Color borderColor;

  final Duration animationDuration;
  final Duration showDelay;
  final Duration hideDelay;

  final TPopupAlignment alignment;
  final double offset;
  final TPopupAlignment secondaryAlignment;
  final double secondaryOffset;
  final BoxConstraints boxConstraints;

  final double iconSize;
  final double arrowIconSize;
  final double gap;

  final double overlayElevation;
  final BorderRadius overlayBorderRadius;
  final EdgeInsets overlayPadding;

  final EdgeInsets itemPadding;
  final BorderRadius itemBorderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  const TMenuTheme({
    required this.defaultColor,
    required this.hoverColor,
    required this.activeColor,
    required this.activeBackgroundColor,
    required this.borderColor,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showDelay = const Duration(milliseconds: 25),
    this.hideDelay = const Duration(milliseconds: 125),
    this.alignment = TPopupAlignment.bottomLeft,
    this.offset = 8.0,
    this.secondaryAlignment = TPopupAlignment.rightTop,
    this.secondaryOffset = 8.0,
    this.boxConstraints = const BoxConstraints(minWidth: 175),
    this.iconSize = 20.0,
    this.arrowIconSize = 11.0,
    this.gap = 10.0,
    this.overlayElevation = 8.0,
    this.overlayBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.overlayPadding = const EdgeInsets.symmetric(vertical: 8),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.itemBorderRadius = const BorderRadius.all(Radius.circular(6.0)),
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w300,
  });

  Color getItemColor({required bool isActive, required bool containsActive, required bool isHovered}) {
    if (isActive || containsActive) return activeColor;
    if (isHovered) return hoverColor;
    return defaultColor;
  }
}
