import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Theme configuration for [TListCard].
///
/// `TListCardTheme` defines the visual style of list items/cards, including:
/// - Background colors (normal, selected, disabled)
/// - Padding and indentation
/// - Builders for indicators (selection, expansion) and content
class TListCardTheme {
  final Color backgroundColor;
  final Color selectedBackgroundColor;
  final Color disabledBackgroundColor;
  final EdgeInsets padding;
  final double levelIndentation;
  final bool showSelectionIndicator;
  final BorderRadius borderRadius;

  /// Outer space around the item's hoverable/selectable surface (the Material it's drawn on),
  /// as opposed to [padding] which is inner content padding within that surface. Non-zero
  /// together with [borderRadius] is what makes the hover/selection highlight read as an
  /// inset rounded rect instead of a full-bleed flush row — e.g. to match a dropdown menu's
  /// item style in a compact popup.
  final EdgeInsets margin;

  final Widget Function(bool isExpanded, bool isDisabled) expansionIndicatorBuilder;
  final Widget Function(bool multiple, bool isSelected, bool isDisabled) selectionIndicatorBuilder;
  final Widget Function(String title, String? subTitle, String? imageUrl, bool isSelected, bool isDisabled) contentBuilder;

  /// Creates a list card theme.
  const TListCardTheme({
    required this.backgroundColor,
    required this.selectedBackgroundColor,
    required this.disabledBackgroundColor,
    required this.expansionIndicatorBuilder,
    required this.selectionIndicatorBuilder,
    required this.contentBuilder,
    this.showSelectionIndicator = true,
    this.padding = const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
    this.levelIndentation = 18.0,
    this.borderRadius = BorderRadius.zero,
    this.margin = EdgeInsets.zero,
  });

  /// Creates a copy of the theme with updated properties.
  TListCardTheme copyWith({
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    Color? disabledBackgroundColor,
    EdgeInsets? padding,
    double? levelIndentation,
    bool? showSelectionIndicator,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
    Widget Function(bool isExpanded, bool isDisabled)? expansionIndicatorBuilder,
    Widget Function(bool multiple, bool isSelected, bool isDisabled)? selectionIndicatorBuilder,
    Widget Function(String title, String? subTitle, String? imageUrl, bool isSelected, bool isDisabled)? contentBuilder,
  }) {
    return TListCardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedBackgroundColor: selectedBackgroundColor ?? this.selectedBackgroundColor,
      disabledBackgroundColor: disabledBackgroundColor ?? this.disabledBackgroundColor,
      padding: padding ?? this.padding,
      levelIndentation: levelIndentation ?? this.levelIndentation,
      showSelectionIndicator: showSelectionIndicator ?? this.showSelectionIndicator,
      borderRadius: borderRadius ?? this.borderRadius,
      margin: margin ?? this.margin,
      expansionIndicatorBuilder: expansionIndicatorBuilder ?? this.expansionIndicatorBuilder,
      selectionIndicatorBuilder: selectionIndicatorBuilder ?? this.selectionIndicatorBuilder,
      contentBuilder: contentBuilder ?? this.contentBuilder,
    );
  }

  /// Creates a default theme derived from the context colors.
  ///
  /// [iconSize] sizes the expansion/selection indicator icons, [fontSize] the title and
  /// [subtitleFontSize] the subtitle — override these together with [padding] when a tighter
  /// item fits the context better (e.g. a compact select popup) without touching the shared
  /// defaults every other [TListCard] consumer relies on.
  factory TListCardTheme.defaultTheme(
    ColorScheme colors, {
    bool forceCache = true,
    double iconSize = 18.0,
    double fontSize = 15.0,
    double subtitleFontSize = 11.5,
  }) {
    return TListCardTheme(
      backgroundColor: Colors.transparent,
      selectedBackgroundColor: colors.primaryContainer,
      disabledBackgroundColor: colors.surfaceContainerHighest,
      expansionIndicatorBuilder: defaultExpansionIndicatorBuilder(colors, iconSize: iconSize),
      selectionIndicatorBuilder: defaultSelectionIndicatorBuilder(colors, iconSize: iconSize),
      contentBuilder: defaultContentBuilder(colors, forceCache: forceCache, fontSize: fontSize, subtitleFontSize: subtitleFontSize),
    );
  }

  static Widget Function(bool isExpanded, bool isDisabled) defaultExpansionIndicatorBuilder(ColorScheme colors, {double iconSize = 18.0}) {
    return (isExpanded, isDisabled) => AnimatedRotation(
          turns: isExpanded ? 0.25 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: TIcon.raw(
            HugeIcons.strokeRoundedArrowRight01,
            size: iconSize,
            color: isDisabled ? colors.onSurface.o(0.38) : colors.onSurfaceVariant,
          ),
        );
  }

  static Widget Function(bool multiple, bool isSelected, bool isDisabled) defaultSelectionIndicatorBuilder(
    ColorScheme colors, {
    double iconSize = 18.0,
  }) {
    return (multiple, isSelected, isDisabled) {
      final color = isDisabled
          ? colors.onSurface.o(0.38)
          : isSelected
              ? colors.onPrimaryContainer
              : colors.onSurfaceVariant;

      if (multiple) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TIcon.raw(isSelected ? HugeIcons.strokeRoundedCheckmarkSquare03 : HugeIcons.strokeRoundedSquare,
              size: iconSize, color: color),
        );
      }

      if (isSelected) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TIcon.raw(HugeIcons.strokeRoundedTick01, size: iconSize, color: color),
        );
      }

      return const SizedBox.shrink();
    };
  }

  static Widget Function(
    String title,
    String? subTitle,
    String? imageUrl,
    bool isSelected,
    bool isDisabled,
  ) defaultContentBuilder(
    ColorScheme colors, {
    bool forceCache = true,
    double fontSize = 15.0,
    double subtitleFontSize = 11.5,
  }) {
    return (title, subTitle, imageUrl, isSelected, isDisabled) {
      final titleColor = isDisabled
          ? colors.onSurface.o(0.38)
          : isSelected
              ? colors.onPrimaryContainer
              : colors.onSurface;

      final textContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(fontSize: fontSize, color: titleColor, fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400)),
          if (subTitle != null) const SizedBox(),
          if (subTitle != null)
            Text(subTitle,
                style: TextStyle(fontSize: subtitleFontSize, color: isDisabled ? colors.onSurface.o(0.38) : colors.onSurfaceVariant)),
        ],
      );

      Widget child;
      if (!imageUrl.isNullOrBlank) {
        child = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TImage(
              url: imageUrl,
              size: 45,
              color: colors.surfaceContainerHighest,
              disabled: true,
              forceCache: forceCache,
              border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 15),
            Expanded(child: textContent),
          ],
        );
      } else {
        child = textContent;
      }

      return child;
    };
  }
}
