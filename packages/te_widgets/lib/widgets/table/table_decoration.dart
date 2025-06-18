import 'package:flutter/material.dart';

class TTableDecoration {
  final double mobileBreakpoint;
  final double? cardWidth;
  final bool showStaggeredAnimation;
  final Duration animationDuration;
  final bool forceCardStyle;
  final TTableStyling? styling;
  final bool shrinkWrap;
  final double? minWidth;
  final double? maxWidth;
  final bool showScrollbars;

  const TTableDecoration({
    this.mobileBreakpoint = 768,
    this.cardWidth,
    this.showStaggeredAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.forceCardStyle = false,
    this.styling,
    this.shrinkWrap = true,
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
    TTableStyling? styling,
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
      styling: styling ?? this.styling,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      showScrollbars: showScrollbars ?? this.showScrollbars,
    );
  }
}

class TTableStyling {
  final TextStyle? headerTextStyle;
  final EdgeInsets? headerPadding;
  final Decoration? headerDecoration;
  final EdgeInsets? contentPadding;
  final TCardStyle? cardStyle;
  final TRowStyle? rowStyle;
  final TextStyle? cardLabelStyle;
  final TextStyle? cardValueStyle;
  final TextStyle? rowTextStyle;

  const TTableStyling({
    this.headerTextStyle,
    this.headerPadding,
    this.headerDecoration,
    this.contentPadding,
    this.cardStyle,
    this.rowStyle,
    this.cardLabelStyle,
    this.cardValueStyle,
    this.rowTextStyle,
  });
}

class TCardStyle {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const TCardStyle({
    this.margin,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });
}

class TRowStyle {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const TRowStyle({
    this.margin,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });
}
