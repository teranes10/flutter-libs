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
    );
  }

  @override
  TDropdownTheme copyWith({
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
    return TDropdownTheme(
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
