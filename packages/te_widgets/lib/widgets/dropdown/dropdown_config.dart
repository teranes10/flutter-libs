import 'package:flutter/material.dart';
import 'package:te_widgets/helpers/popup_position.dart';
import 'package:te_widgets/widgets/menu/menu_theme.dart';

class TDropdownTheme extends TMenuTheme {
  const TDropdownTheme({
    required super.defaultColor,
    required super.hoverColor,
    required super.activeColor,
    required super.activeBackgroundColor,
    required super.borderColor,
    super.hoverBackgroundColor,
    super.animationDuration = const Duration(milliseconds: 200),
    super.showDelay = const Duration(milliseconds: 25),
    super.hideDelay = const Duration(milliseconds: 125),
    super.alignment = TPopupAlignment.bottomLeft,
    super.offset = 8.0,
    super.secondaryAlignment = TPopupAlignment.rightTop,
    super.secondaryOffset = 8.0,
    super.boxConstraints = const BoxConstraints(minWidth: 175),
    super.iconSize = 16.0,
    super.arrowIconSize = 14.0,
    super.gap = 8.0,
    super.overlayElevation = 8.0,
    super.overlayBorderRadius = const BorderRadius.all(Radius.circular(14.0)),
    super.overlayPadding = const EdgeInsets.all(6),
    super.itemPadding = const EdgeInsets.all(6),
    super.itemBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
    super.fontSize = 14.0,
    super.fontWeight = FontWeight.w300,
    super.arrowIcon,
    super.dropdownIcon,
    super.expandIcon,
  });

  factory TDropdownTheme.defaultTheme(ColorScheme? colors) {
    final colorScheme = colors ?? const ColorScheme.light();

    return TDropdownTheme(
      defaultColor: colorScheme.onSurfaceVariant,
      hoverColor: colorScheme.onSurface,
      activeColor: colorScheme.onPrimaryContainer,
      activeBackgroundColor: colorScheme.primaryContainer,
      borderColor: colorScheme.outline,
      hoverBackgroundColor: colorScheme.surfaceDim,
    );
  }

  @override
  TDropdownTheme copyWith({
    Color? defaultColor,
    Color? hoverColor,
    Color? activeColor,
    Color? activeBackgroundColor,
    Color? borderColor,
    Color? hoverBackgroundColor,
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
    return TDropdownTheme(
      defaultColor: defaultColor ?? this.defaultColor,
      hoverColor: hoverColor ?? this.hoverColor,
      activeColor: activeColor ?? this.activeColor,
      activeBackgroundColor: activeBackgroundColor ?? this.activeBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      hoverBackgroundColor: hoverBackgroundColor ?? this.hoverBackgroundColor,
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
