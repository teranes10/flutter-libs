import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableDecoration {
  final double mobileBreakpoint;
  final double? cardWidth;
  final bool showStaggeredAnimation;
  final Duration animationDuration;
  final bool forceCardStyle;
  final TTableStyle style;
  final bool showScrollbars;
  final int paginationTotalVisible;

  const TTableDecoration({
    this.mobileBreakpoint = 768,
    this.cardWidth,
    this.showStaggeredAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.forceCardStyle = false,
    this.style = const TTableStyle(),
    this.showScrollbars = true,
    this.paginationTotalVisible = 9,
  });

  TTableDecoration copyWith({
    double? mobileBreakpoint,
    double? cardWidth,
    bool? showStaggeredAnimation,
    Duration? animationDuration,
    bool? forceCardStyle,
    TTableStyle? style,
    bool? shrinkWrap,
    double? minWidth,
    double? maxWidth,
    bool? showScrollbars,
  }) {
    return TTableDecoration(
      mobileBreakpoint: mobileBreakpoint ?? this.mobileBreakpoint,
      cardWidth: cardWidth ?? this.cardWidth,
      showStaggeredAnimation: showStaggeredAnimation ?? this.showStaggeredAnimation,
      animationDuration: animationDuration ?? this.animationDuration,
      forceCardStyle: forceCardStyle ?? this.forceCardStyle,
      style: style ?? this.style,
      showScrollbars: showScrollbars ?? this.showScrollbars,
    );
  }
}

class TTableStyle {
  final EdgeInsets headerPadding;
  final Decoration? headerDecoration;
  final TextStyle? headerTextStyle;
  final EdgeInsets contentPadding;
  final TextStyle? contentTextStyle;
  final TCardStyle cardStyle;
  final TRowStyle rowStyle;

  const TTableStyle({
    this.headerDecoration,
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    this.headerTextStyle,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.contentTextStyle,
    this.cardStyle = const TCardStyle(),
    this.rowStyle = const TRowStyle(),
  });

  TextStyle getHeaderStyle(ColorScheme colors) {
    return headerTextStyle ?? TextStyle(fontSize: 13.6, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant);
  }

  TextStyle getContentTextStyle(ColorScheme colors) {
    return contentTextStyle ?? TextStyle(fontSize: 13.6, fontWeight: FontWeight.w300, color: colors.onSurface);
  }
}

class TCardStyle extends TKeyValueTheme {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Border? border;
  final Border? selectedBorder;

  const TCardStyle({
    this.margin = const EdgeInsets.only(bottom: 12),
    this.padding = const EdgeInsets.all(16),
    this.elevation = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.border,
    this.selectedBorder,
  });

  Color getBackgroundColor(ColorScheme colors, bool isSelected) {
    return isSelected ? (selectedBackgroundColor ?? colors.primaryContainer.withAlpha(25)) : (backgroundColor ?? colors.surface);
  }

  Border getBorder(ColorScheme colors, bool isSelected) {
    return isSelected
        ? (selectedBorder ?? Border.all(color: colors.primary.withAlpha(50), width: 2))
        : (border ?? Border.all(color: colors.outline));
  }
}

class TRowStyle {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Border? border;

  const TRowStyle({
    this.margin = const EdgeInsets.only(bottom: 8),
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.elevation = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.border,
  });

  Color getBackgroundColor(ColorScheme colors, bool isSelected) {
    return isSelected ? (selectedBackgroundColor ?? colors.primaryContainer) : (backgroundColor ?? colors.surface);
  }
}
