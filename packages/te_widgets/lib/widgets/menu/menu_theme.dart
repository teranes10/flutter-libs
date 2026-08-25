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

  final IconData? arrowIcon;
  final IconData? dropdownIcon;
  final IconData? expandIcon;

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
    this.arrowIconSize = 14.0,
    this.gap = 10.0,
    this.overlayElevation = 8.0,
    this.overlayBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.overlayPadding = const EdgeInsets.symmetric(vertical: 8),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.itemBorderRadius = const BorderRadius.all(Radius.circular(6.0)),
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w300,
    this.arrowIcon,
    this.dropdownIcon,
    this.expandIcon,
  });

  Color getItemColor({required bool isActive, required bool containsActive, required bool isHovered}) {
    if (isActive || containsActive) return activeColor;
    if (isHovered) return hoverColor;
    return defaultColor;
  }

  TMenuTheme copyWith({
    Color? defaultColor,
    Color? hoverColor,
    Color? activeColor,
    Color? activeBackgroundColor,
    Color? borderColor,
    Duration? animationDuration,
    Duration? showDelay,
    Duration? hideDelay,
    TPopupAlignment? alignment,
    double? offset,
    TPopupAlignment? secondaryAlignment,
    double? secondaryOffset,
    BoxConstraints? boxConstraints,
    double? iconSize,
    double? arrowIconSize,
    double? gap,
    double? overlayElevation,
    BorderRadius? overlayBorderRadius,
    EdgeInsets? overlayPadding,
    EdgeInsets? itemPadding,
    BorderRadius? itemBorderRadius,
    double? fontSize,
    FontWeight? fontWeight,
    IconData? arrowIcon,
    IconData? dropdownIcon,
    IconData? expandIcon,
  }) {
    return TMenuTheme(
      defaultColor: defaultColor ?? this.defaultColor,
      hoverColor: hoverColor ?? this.hoverColor,
      activeColor: activeColor ?? this.activeColor,
      activeBackgroundColor: activeBackgroundColor ?? this.activeBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      animationDuration: animationDuration ?? this.animationDuration,
      showDelay: showDelay ?? this.showDelay,
      hideDelay: hideDelay ?? this.hideDelay,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      secondaryAlignment: secondaryAlignment ?? this.secondaryAlignment,
      secondaryOffset: secondaryOffset ?? this.secondaryOffset,
      boxConstraints: boxConstraints ?? this.boxConstraints,
      iconSize: iconSize ?? this.iconSize,
      arrowIconSize: arrowIconSize ?? this.arrowIconSize,
      gap: gap ?? this.gap,
      overlayElevation: overlayElevation ?? this.overlayElevation,
      overlayBorderRadius: overlayBorderRadius ?? this.overlayBorderRadius,
      overlayPadding: overlayPadding ?? this.overlayPadding,
      itemPadding: itemPadding ?? this.itemPadding,
      itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      arrowIcon: arrowIcon ?? this.arrowIcon,
      dropdownIcon: dropdownIcon ?? this.dropdownIcon,
      expandIcon: expandIcon ?? this.expandIcon,
    );
  }
}
