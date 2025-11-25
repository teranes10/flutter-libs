import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'nav_bar_item.dart';

class TNavbar extends StatelessWidget {
  final List<TNavItem> items;
  final MainAxisAlignment alignment;
  final Color? background;
  final double spacing;
  final EdgeInsets? padding;

  const TNavbar({
    super.key,
    required this.items,
    this.background,
    this.alignment = MainAxisAlignment.spaceAround,
    this.spacing = 0.0,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: padding,
      color: background ?? colors.surface,
      child: Row(
        spacing: spacing,
        mainAxisAlignment: alignment,
        children: List.generate(items.length, (index) => items[index]),
      ),
    );
  }
}
