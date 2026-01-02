import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Helper class for rendering tab widgets with consistent styling.
class TabRenderer<T> {
  /// Builds a default tab widget with standard styling.
  static Widget buildDefaultTab<T>({
    required BuildContext context,
    required TTab<T> tab,
    required bool isSelected,
    required ColorScheme colors,
    required GlobalKey tabKey,
    required Axis axis,
    EdgeInsets? tabPadding,
    required double? indicatorWidth,
    Color? selectedColor,
    Color? unselectedColor,
    Color? disabledColor,
    Color? indicatorColor,
    TTabController<T>? controller,
    VoidCallback? onTab,
  }) {
    final defaultSelectedColor = selectedColor ?? colors.onPrimaryContainer;
    final defaultUnselectedColor = unselectedColor ?? colors.onSurface;
    final defaultDisabledColor = disabledColor ?? colors.onSurfaceVariant;
    final defaultIndicatorColor = indicatorColor ?? colors.primary;

    final color = tab.isEnabled ? (isSelected ? defaultSelectedColor : defaultUnselectedColor) : defaultDisabledColor;

    final indicatorBorder = isSelected
        ? (axis == Axis.horizontal
            ? Border(bottom: BorderSide(color: defaultIndicatorColor, width: indicatorWidth ?? 1))
            : Border(right: BorderSide(color: defaultIndicatorColor, width: indicatorWidth ?? 1)))
        : null;

    // For vertical tabs on mobile, show only icons to prevent overflow
    final isMobile = MediaQuery.of(context).size.width < 600;
    final showTextInVertical = axis == Axis.horizontal || !isMobile;

    final content = axis == Axis.horizontal
        ? _buildHorizontalTabContent(
            tab: tab,
            color: color,
            isSelected: isSelected,
            defaultIndicatorColor: defaultIndicatorColor,
          )
        : _buildVerticalTabContent(
            tab: tab,
            color: color,
            isSelected: isSelected,
            defaultIndicatorColor: defaultIndicatorColor,
            showText: showTextInVertical,
          );

    return Container(
      key: tabKey,
      decoration: BoxDecoration(border: indicatorBorder),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTab,
          child: Container(
              padding: tabPadding ??
                  (axis == Axis.horizontal
                      ? const EdgeInsets.symmetric(vertical: 6, horizontal: 8)
                      : const EdgeInsets.symmetric(vertical: 4, horizontal: 8)),
              child: content),
        ),
      ),
    );
  }

  /// Builds horizontal tab content layout.
  static Widget _buildHorizontalTabContent<T>({
    required TTab<T> tab,
    required Color color,
    required bool isSelected,
    required Color defaultIndicatorColor,
  }) {
    return Row(
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
            decoration: BoxDecoration(
              color: defaultIndicatorColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  /// Builds vertical tab content layout.
  static Widget _buildVerticalTabContent<T>({
    required TTab<T> tab,
    required Color color,
    required bool isSelected,
    required Color defaultIndicatorColor,
    required bool showText,
  }) {
    return Column(
      children: [
        if (tab.icon != null) ...[
          Icon(tab.icon, size: 16, color: color),
          if (tab.text != null && showText) const SizedBox(height: 4),
        ],
        if (tab.text != null && showText)
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
            margin: EdgeInsets.only(top: showText ? 4 : 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: defaultIndicatorColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
