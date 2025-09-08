import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/key-value-section/key_value_section_config.dart';

class TTableDecoration {
  final double mobileBreakpoint;
  final double? cardWidth;
  final bool showStaggeredAnimation;
  final Duration animationDuration;
  final bool forceCardStyle;
  final TTableStyle style;
  final double? minWidth;
  final double? maxWidth;
  final bool showScrollbars;

  const TTableDecoration({
    this.mobileBreakpoint = 768,
    this.cardWidth,
    this.showStaggeredAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.forceCardStyle = false,
    this.style = const TTableStyle(),
    this.minWidth,
    this.maxWidth,
    this.showScrollbars = true,
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
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
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

  TextStyle getHeaderStyle(ColorScheme theme) {
    return headerTextStyle ?? TextStyle(fontSize: 13.6, fontWeight: FontWeight.w400, color: theme.onSurfaceVariant);
  }

  TextStyle getContentTextStyle(ColorScheme theme) {
    return contentTextStyle ?? TextStyle(fontSize: 13.6, fontWeight: FontWeight.w300, color: theme.onSurface);
  }
}

class TCardStyle extends TKeyValueStyle {
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

  Color getBackgroundColor(ColorScheme theme, bool isSelected) {
    return isSelected ? (selectedBackgroundColor ?? theme.primaryContainer.withAlpha(25)) : (backgroundColor ?? theme.surface);
  }

  Border getBorder(ColorScheme theme, bool isSelected) {
    return isSelected
        ? (selectedBorder ?? Border.all(color: theme.primary.withAlpha(50), width: 2))
        : (border ?? Border.all(color: theme.outline));
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

  Color getBackgroundColor(ColorScheme theme, bool isSelected) {
    return isSelected ? (selectedBackgroundColor ?? theme.primaryContainer) : (backgroundColor ?? theme.surface);
  }
}
