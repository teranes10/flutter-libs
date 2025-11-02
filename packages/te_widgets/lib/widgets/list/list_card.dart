import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TListCard extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String? imageUrl;
  final bool isSelected;
  final bool isExpanded;
  final bool isDisabled;
  final bool multiple;
  final int level;

  final VoidCallback? onTap;
  final TListCardTheme? theme;
  final List<TListCard>? children;

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
