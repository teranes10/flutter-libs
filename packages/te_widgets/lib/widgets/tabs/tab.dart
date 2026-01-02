import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A tab item for use with TTabs.
///
/// Type parameter:
/// - [T]: The type of the tab value
class TTab<T> {
  /// The value associated with this tab.
  final T value;

  /// The text label for the tab.
  final String? text;

  /// The icon for the tab.
  final IconData? icon;

  /// Whether the tab is enabled.
  final bool isEnabled;

  /// Whether to show an active indicator dot.
  final bool isActive;

  /// Optional content builder for this tab.
  ///
  /// When provided, this content will be displayed when the tab is selected.
  /// Used with [TTabContent] or [TTabView] widgets.
  final Widget Function(BuildContext context)? content;

  /// Creates a tab item.
  const TTab({
    required this.value,
    this.text,
    this.icon,
    this.isEnabled = true,
    this.isActive = false,
    this.content,
  }) : assert(icon != null || text != null, 'Either icon or text must be provided');

  /// Calculates the approximate width of this tab.
  double calculateWidth() {
    return (text?.length.let((x) => x * 16 * 0.75) ?? 0) + (icon != null ? 17 : 0);
  }

  /// Calculates the total width of a list of tabs.
  static double calculateTabsWidth(List<TTab> tabs) {
    return tabs.fold<double>(0.0, (a, b) => a + b.calculateWidth()) + ((tabs.length - 1) * 16);
  }
}
