import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'nav_bar_item.dart';

/// A bottom navigation bar with animated items.
///
/// `TNavbar` displays a row of [TNavItem]s with customizable alignment
/// and styling. It is typically used for mobile bottom navigation.
///
/// ## Basic Usage
///
/// ```dart
/// TNavbar(
///   items: [
///     TNavItem(
///       icon: Icons.home,
///       label: 'Home',
///       isActive: currentIndex == 0,
///       onTap: () => setIndex(0),
///     ),
///     TNavItem(
///       icon: Icons.person,
///       label: 'Profile',
///       isActive: currentIndex == 1,
///       onTap: () => setIndex(1),
///     ),
///   ],
/// )
/// ```
///
/// See also:
/// - [TNavItem] for navigation items
/// - [Scaffold.bottomNavigationBar] for typical placement
class TNavbar extends StatelessWidget {
  /// The list of navigation items to display.
  final List<TNavItem> items;

  /// The alignment of items within the bar.
  final MainAxisAlignment alignment;

  /// The background color of the navbar.
  final Color? background;

  /// Spacing between items.
  final double spacing;

  /// Padding around the navbar content.
  final EdgeInsets? padding;

  /// Creates a navigation bar.
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
