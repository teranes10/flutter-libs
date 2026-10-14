import 'package:te_widgets/te_widgets.dart';

/// An item in the [TBottomBar].
class TBottomBarItem {
  /// The icon to display.
  final dynamic icon;

  /// The icon to display when the item is active.
  /// If null, [icon] will be used.
  final dynamic activeIcon;

  /// The label text to display.
  final String label;

  /// Optional tooltip for the item.
  final String? tooltip;

  // Optional items to show in popup
  final List<TDropdownItem>? items;

  /// Optional badge on the icon: an `int` count, a `bool` dot, a `String`
  /// label or a custom `Widget` (same semantics as [TButton.badge]).
  final dynamic badge;

  /// Renders the item as a raised, filled circular primary action (e.g. a
  /// centre "Scan" button) instead of a regular tab.
  final bool emphasized;

  /// Creates a bottom bar item.
  const TBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.tooltip,
    this.items,
    this.badge,
    this.emphasized = false,
  });
}
