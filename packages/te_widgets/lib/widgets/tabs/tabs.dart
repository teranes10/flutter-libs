import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTab {
  final IconData? icon;
  final String? label;
  final bool isEnabled;
  final bool isActive;

  const TTab({
    this.icon,
    this.label,
    this.isEnabled = true,
    this.isActive = false,
  }) : assert(icon != null || label != null, 'Either icon or label must be provided');
}

class TTabs extends StatefulWidget {
  final List<TTab> tabs;
  final int? selectedIndex;
  final ValueChanged<int>? onTabChanged;
  final Color? borderColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? disabledColor;
  final Color? indicatorColor;
  final EdgeInsets? tabPadding;
  final double? indicatorWidth;

  const TTabs({
    super.key,
    required this.tabs,
    this.selectedIndex,
    this.onTabChanged,
    this.borderColor,
    this.selectedColor,
    this.unselectedColor,
    this.disabledColor,
    this.indicatorColor,
    this.tabPadding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.indicatorWidth = 2,
  });

  @override
  State<TTabs> createState() => _TTabsState();
}

class _TTabsState extends State<TTabs> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex ?? 0;
  }

  @override
  void didUpdateWidget(TTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != null && widget.selectedIndex != _currentIndex) {
      _currentIndex = widget.selectedIndex!;
    }
  }

  void _handleTabTap(int index) {
    if (widget.tabs[index].isEnabled) {
      setState(() {
        _currentIndex = index;
      });
      widget.onTabChanged?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderColor = widget.borderColor ?? AppColors.grey.shade300;
    final defaultSelectedColor = widget.selectedColor ?? theme.colorScheme.onPrimaryContainer;
    final defaultUnselectedColor = widget.unselectedColor ?? theme.colorScheme.onSurface;
    final defaultDisabledColor = widget.disabledColor ?? AppColors.grey.shade400;
    final defaultIndicatorColor = widget.indicatorColor ?? theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: defaultBorderColor)),
      ),
      child: Row(
        children: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _currentIndex == index;

          return Expanded(
            child: _buildTab(
              index: index,
              tab: tab,
              isSelected: isSelected,
              selectedColor: defaultSelectedColor,
              unselectedColor: defaultUnselectedColor,
              disabledColor: defaultDisabledColor,
              indicatorColor: defaultIndicatorColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required TTab tab,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
    required Color disabledColor,
    required Color indicatorColor,
  }) {
    final Color color = tab.isEnabled ? (isSelected ? selectedColor : unselectedColor) : disabledColor;

    return InkWell(
      onTap: tab.isEnabled ? () => _handleTabTap(index) : null,
      child: Container(
        padding: widget.tabPadding,
        decoration: BoxDecoration(
          border: isSelected ? Border(bottom: BorderSide(color: indicatorColor, width: widget.indicatorWidth!)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              Icon(tab.icon, size: 16, color: color),
              if (tab.label != null) const SizedBox(width: 8),
            ],
            if (tab.label != null)
              Text(
                tab.label!,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            if (tab.isActive)
              Container(
                margin: const EdgeInsets.only(left: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
