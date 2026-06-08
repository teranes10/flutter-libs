import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/popup_mixin.dart';

class TDropdownItem {
  final IconData? icon;
  final String? text;
  final List<TDropdownItem>? children;
  final VoidCallback? onTap;
  final bool initiallyExpanded;
  final Object? extra;
  final bool hidden;

  const TDropdownItem({
    this.icon,
    this.text,
    this.children,
    this.onTap,
    this.initiallyExpanded = false,
    this.extra,
    this.hidden = false,
  });

  bool get hasChildren => children?.isNotEmpty ?? false;
  bool get isClickable => onTap != null;
}

class TDropdownTheme {
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

  const TDropdownTheme({
    required this.defaultColor,
    required this.hoverColor,
    required this.activeColor,
    required this.activeBackgroundColor,
    required this.borderColor,
    this.animationDuration = const Duration(milliseconds: 250),
    this.showDelay = const Duration(milliseconds: 100),
    this.hideDelay = const Duration(milliseconds: 250),
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
  Color getItemColor({
    required bool isActive,
    required bool containsActive,
    required bool isHovered,
  }) {
    if (isActive || containsActive) return activeColor;
    if (isHovered) return hoverColor;
    return defaultColor;
  }
}
