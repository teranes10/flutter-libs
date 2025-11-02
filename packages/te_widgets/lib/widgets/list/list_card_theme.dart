import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TListCardTheme {
  final Color backgroundColor;
  final Color selectedBackgroundColor;
  final Color disabledBackgroundColor;
  final EdgeInsets padding;
  final double levelIndentation;
  final bool showSelectionIndicator;

  final Widget Function(bool isExpanded, bool isDisabled) expansionIndicatorBuilder;
  final Widget Function(bool multiple, bool isSelected, bool isDisabled) selectionIndicatorBuilder;
  final Widget Function(String title, String? subTitle, String? imageUrl, bool isSelected, bool isDisabled) contentBuilder;

  const TListCardTheme({
    required this.backgroundColor,
    required this.selectedBackgroundColor,
    required this.disabledBackgroundColor,
    required this.expansionIndicatorBuilder,
    required this.selectionIndicatorBuilder,
    required this.contentBuilder,
    this.showSelectionIndicator = true,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    this.levelIndentation = 18.0,
  });

  TListCardTheme copyWith({
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    Color? disabledBackgroundColor,
    EdgeInsets? padding,
    double? levelIndentation,
    bool? showSelectionIndicator,
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
      expansionIndicatorBuilder: expansionIndicatorBuilder ?? this.expansionIndicatorBuilder,
      selectionIndicatorBuilder: selectionIndicatorBuilder ?? this.selectionIndicatorBuilder,
      contentBuilder: contentBuilder ?? this.contentBuilder,
    );
  }

  factory TListCardTheme.defaultTheme(ColorScheme colors) {
    return TListCardTheme(
      backgroundColor: colors.surface,
      selectedBackgroundColor: colors.primaryContainer,
      disabledBackgroundColor: colors.surfaceContainerHighest.o(0.5),
      expansionIndicatorBuilder: defaultExpansionIndicatorBuilder(colors),
      selectionIndicatorBuilder: defaultSelectionIndicatorBuilder(colors),
      contentBuilder: defaultContentBuilder(colors),
    );
  }

  static Widget Function(bool isExpanded, bool isDisabled) defaultExpansionIndicatorBuilder(ColorScheme colors) {
    return (isExpanded, isDisabled) => AnimatedRotation(
          turns: isExpanded ? 0.25 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.keyboard_arrow_right,
            size: 18.0,
            color: isDisabled ? colors.onSurface.o(0.38) : colors.onSurfaceVariant,
          ),
        );
  }

  static Widget Function(bool multiple, bool isSelected, bool isDisabled) defaultSelectionIndicatorBuilder(ColorScheme colors) {
    return (multiple, isSelected, isDisabled) {
      final color = isDisabled
          ? colors.onSurface.o(0.38)
          : isSelected
              ? colors.primary
              : colors.onSurfaceVariant;

      if (multiple) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: color),
        );
      }

      if (isSelected) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(Icons.check, size: 18, color: color),
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
  ) defaultContentBuilder(ColorScheme colors) {
    return (title, subTitle, imageUrl, isSelected, isDisabled) {
      final titleColor = isDisabled
          ? colors.onSurface.o(0.38)
          : isSelected
              ? colors.primary
              : colors.onSurface;

      final textContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: titleColor, fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (subTitle != null) const SizedBox(height: 2.5),
          if (subTitle != null)
            Text(
              subTitle,
              style: TextStyle(fontSize: 12.0, color: isDisabled ? colors.onSurface.o(0.38) : colors.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      );

      if (!imageUrl.isNullOrBlank) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            TImage(
              url: imageUrl,
              size: 45,
              backgroundColor: colors.surfaceDim,
              disabled: true,
            ),
            textContent,
          ],
        );
      }

      return textContent;
    };
  }
}
