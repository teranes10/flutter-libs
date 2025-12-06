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

  /// Creates a tab item.
  const TTab({
    required this.value,
    this.text,
    this.icon,
    this.isEnabled = true,
    this.isActive = false,
  }) : assert(icon != null || text != null, 'Either icon or text must be provided');

  double calculateWidth() {
    return (text?.length.let((x) => x * 16 * 0.75) ?? 0) + (icon != null ? 17 : 0);
  }

  static double calculateTabsWidth(List<TTab> tabs) {
    return tabs.fold<double>(0.0, (a, b) => a + b.calculateWidth()) + ((tabs.length - 1) * 16);
  }
}

/// A tab navigation component with indicator.
///
/// `TTabs` provides tab navigation with:
/// - Icon and/or text tabs
/// - Active indicator line
/// - Disabled state support
/// - Inline or full-width layout
/// - Custom colors
///
/// ## Basic Usage
///
/// ```dart
/// TTabs<int>(
///   tabs: [
///     TTab(value: 0, text: 'Home', icon: Icons.home),
///     TTab(value: 1, text: 'Profile', icon: Icons.person),
///     TTab(value: 2, text: 'Settings', icon: Icons.settings),
///   ],
///   selectedValue: currentTab,
///   onTabChanged: (value) => setState(() => currentTab = value),
/// )
/// ```
///
/// ## With Active Indicator
///
/// ```dart
/// TTabs<String>(
///   tabs: [
///     TTab(value: 'active', text: 'Active', isActive: hasActiveItems),
///     TTab(value: 'archived', text: 'Archived'),
///   ],
///   selectedValue: selectedTab,
///   onTabChanged: (value) => loadData(value),
/// )
/// ```
///
/// Type parameter:
/// - [T]: The type of tab values
///
/// See also:
/// - [TTab] for tab configuration
class TTabs<T> extends StatelessWidget {
  /// The list of tabs to display.
  final List<TTab<T>> tabs;

  /// The currently selected tab value.
  final T? selectedValue;

  /// Callback fired when a tab is selected.
  final ValueChanged<T>? onTabChanged;

  /// Border color for the tab bar.
  final Color? borderColor;

  /// Color for the selected tab.
  final Color? selectedColor;

  /// Color for unselected tabs.
  final Color? unselectedColor;

  /// Color for disabled tabs.
  final Color? disabledColor;

  /// Color for the selection indicator.
  final Color? indicatorColor;

  /// Padding for each tab.
  final EdgeInsets? tabPadding;

  /// Width of the selection indicator.
  final double? indicatorWidth;

  /// Whether to use inline layout (wrap) instead of full-width.
  final bool inline;

  /// Creates a tabs component.
  const TTabs({
    super.key,
    required this.tabs,
    this.selectedValue,
    this.onTabChanged,
    this.borderColor,
    this.selectedColor,
    this.unselectedColor,
    this.disabledColor,
    this.indicatorColor,
    this.tabPadding = const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
    this.indicatorWidth = 1,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final defaultBorderColor = borderColor ?? Colors.transparent;
    final defaultSelectedColor = selectedColor ?? colors.onPrimaryContainer;
    final defaultUnselectedColor = unselectedColor ?? colors.onSurface;
    final defaultDisabledColor = disabledColor ?? colors.onSurfaceVariant;
    final defaultIndicatorColor = indicatorColor ?? colors.primary;

    final tabWidgets = tabs.map((tab) {
      final isSelected = selectedValue == tab.value;
      final color = tab.isEnabled ? (isSelected ? defaultSelectedColor : defaultUnselectedColor) : defaultDisabledColor;

      final tabWidget = InkWell(
        onTap: tab.isEnabled ? () => onTabChanged?.call(tab.value) : null,
        child: Container(
          padding: tabPadding,
          decoration: BoxDecoration(
            border: isSelected ? Border(bottom: BorderSide(color: defaultIndicatorColor, width: indicatorWidth!)) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (tab.icon != null) ...[
                Icon(tab.icon, size: 16, color: color),
                if (tab.text != null) const SizedBox(width: 8),
              ],
              if (tab.text != null)
                Text(
                  tab.text!,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
                  ),
                ),
              if (tab.isActive)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: defaultIndicatorColor, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      );

      return inline ? tabWidget : Expanded(child: tabWidget);
    }).toList();

    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: defaultBorderColor))),
      child: inline ? Wrap(children: tabWidgets) : Row(children: tabWidgets),
    );
  }
}
