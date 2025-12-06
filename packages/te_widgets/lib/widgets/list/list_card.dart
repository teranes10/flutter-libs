import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A standard card widget for list items.
///
/// `TListCard` displays item content with support for:
/// - Selection state
/// - Expansion state
/// - Hierarchy levels (indentation)
/// - Disabled state
/// - Images and subtitles
///
/// ## Usage Example
///
/// ```dart
/// TListCard(
///   title: 'Item Title',
///   subTitle: 'Item description',
///   isSelected: true,
///   onTap: () => print('Tapped'),
/// )
/// ```
///
/// ## Hierarchical Usage
///
/// ```dart
/// TListCard(
///   title: 'Parent',
///   isExpanded: true,
///   level: 0,
///   children: [
///     TListCard(title: 'Child', level: 1),
///   ],
/// )
/// ```
class TListCard extends StatelessWidget {
  /// The main title text.
  final String title;

  /// Optional subtitle text.
  final String? subTitle;

  /// Optional image URL.
  final String? imageUrl;

  /// Whether the card is selected.
  final bool isSelected;

  /// Whether the card is expanded (shows children).
  final bool isExpanded;

  /// Whether the card is disabled.
  final bool isDisabled;

  /// Whether in multiple selection mode.
  final bool multiple;

  /// The indentation level (0 for root).
  final int level;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Custom theme for the card.
  final TListCardTheme? theme;

  /// Child cards to display when expanded.
  final List<TListCard>? children;

  /// Creates a list card.
  const TListCard({
    super.key,
    required this.title,
    this.subTitle,
    this.imageUrl,
    this.isSelected = false,
    this.isExpanded = false,
    this.isDisabled = false,
    this.multiple = false,
    this.level = 0,
    this.onTap,
    this.theme,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final wTheme = theme ?? TListCardTheme.defaultTheme(colors);

    final backgroundColor = isDisabled
        ? wTheme.disabledBackgroundColor
        : isSelected
            ? wTheme.selectedBackgroundColor
            : wTheme.backgroundColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            child: Container(
              constraints: BoxConstraints(minHeight: 40),
              padding: EdgeInsets.only(
                left: wTheme.padding.left + (level * wTheme.levelIndentation),
                right: wTheme.padding.right,
                top: wTheme.padding.top,
                bottom: wTheme.padding.bottom,
              ),
              child: Row(
                children: [
                  if (wTheme.showSelectionIndicator) wTheme.selectionIndicatorBuilder(multiple, isSelected, isDisabled),
                  Expanded(child: wTheme.contentBuilder(title, subTitle, imageUrl, isSelected, isDisabled)),
                  if (children?.isNotEmpty ?? false) wTheme.expansionIndicatorBuilder(isExpanded, isDisabled),
                ],
              ),
            ),
          ),
        ),

        // Recursive children (if expanded)
        if ((children?.isNotEmpty ?? false) && isExpanded) ...children!.map((child) => child.copyWith(level: level + 1, theme: wTheme)),
      ],
    );
  }

  /// Creates a copy of the card with updated properties.
  TListCard copyWith({int? level, TListCardTheme? theme}) {
    return TListCard(
      title: title,
      subTitle: subTitle,
      isSelected: isSelected,
      isExpanded: isExpanded,
      isDisabled: isDisabled,
      multiple: multiple,
      level: level ?? this.level,
      onTap: onTap,
      theme: theme ?? this.theme,
      children: children,
    );
  }
}
