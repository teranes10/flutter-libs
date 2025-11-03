import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTab<T> {
  final T value;
  final String? text;
  final IconData? icon;
  final bool isEnabled;
  final bool isActive;

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

class TTabs<T> extends StatelessWidget {
  final List<TTab<T>> tabs;
  final T? selectedValue;
  final ValueChanged<T>? onTabChanged;
  final Color? borderColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? disabledColor;
  final Color? indicatorColor;
  final EdgeInsets? tabPadding;
  final double? indicatorWidth;
  final bool inline;

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
