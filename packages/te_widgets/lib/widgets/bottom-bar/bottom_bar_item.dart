import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// An item in the [TBottomBar].
class TBottomBarItem {
  /// The icon to display.
  final IconData icon;

  /// The icon to display when the item is active.
  /// If null, [icon] will be used.
  final IconData? activeIcon;

  /// The label text to display.
  final String label;

  /// Optional tooltip for the item.
  final String? tooltip;

  // Optional items to show in popup
  final List<TDropdownItem>? items;

  /// Creates a bottom bar item.
  const TBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.tooltip,
    this.items,
  });
}
