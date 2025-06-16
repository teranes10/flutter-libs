import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select_notifier.dart';

class TSelectDropdown<T, V> extends StatefulWidget {
  final TSelectStateNotifier<T, V> stateNotifier;
  final bool multiple;
  final double maxHeight;
  final String? footerMessage;
  final IconData? selectedIcon;
  final ValueChanged<TSelectItem<V>> onItemTapped;

  const TSelectDropdown({
    super.key,
    required this.stateNotifier,
    required this.onItemTapped,
    this.multiple = false,
    this.maxHeight = 200.0,
    this.footerMessage,
    this.selectedIcon = Icons.check,
  });

  @override
  State<TSelectDropdown<T, V>> createState() => _TSelectDropdownState<T, V>();
}

class _TSelectDropdownState<T, V> extends State<TSelectDropdown<T, V>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    widget.stateNotifier.scrollPositionNotifier.addListener(_updateScrollPosition);

    _scrollController.addListener(() {
      widget.stateNotifier.updateScrollPosition(_scrollController.offset);

      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent) {
        widget.stateNotifier.onScrollEnd();
      }
    });
  }

  void _updateScrollPosition() {
    if (_scrollController.hasClients) {
      final targetPosition = widget.stateNotifier.scrollPositionNotifier.value;
      if (_scrollController.offset != targetPosition) {
        _scrollController.jumpTo(targetPosition);
      }
    }
  }

  @override
  void dispose() {
    widget.stateNotifier.scrollPositionNotifier.removeListener(_updateScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      child: ValueListenableBuilder<List<TSelectItem<V>>>(
        valueListenable: widget.stateNotifier.filteredItemsNotifier,
        builder: (context, filteredItems, child) {
          if (filteredItems.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.footerMessage ?? 'No items found',
                style: TextStyle(color: AppColors.grey.shade600, fontSize: 14),
              ),
            );
          }

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: filteredItems.length > 10,
            child: ListView(
              controller: _scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildDropdownItems(context, filteredItems, 0),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDropdownItems(BuildContext context, List<TSelectItem<V>> items, int level) {
    List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      widgets.add(_buildDropdownItem(context, item, level, i));

      if (item.hasChildren && item.expanded) {
        widgets.addAll(_buildDropdownItems(context, item.children!, level + 1));
      }
    }

    return widgets;
  }

  Widget _buildDropdownItem(BuildContext context, TSelectItem<V> item, int level, int index) {
    return InkWell(
      key: ValueKey('${item.key}_${item.selected}_${item.expanded}_$level'),
      onTap: () {
        widget.stateNotifier.onItemTapped(item);
        widget.onItemTapped(item);
      },
      splashColor: AppColors.primary.shade100,
      highlightColor: AppColors.primary.shade50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: item.selected ? AppColors.primary.shade50 : Colors.transparent,
        padding: EdgeInsets.only(left: (level * 18.0), right: 16.0, top: 10.0, bottom: 10.0),
        child: Row(
          children: [
            // Selection indicator
            if (widget.multiple)
              Container(
                margin: const EdgeInsets.only(right: 12, left: 12),
                child: Icon(
                  item.selected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 18,
                  color: item.selected ? Theme.of(context).primaryColor : AppColors.grey.shade400,
                ),
              )
            else if (item.selected && widget.selectedIcon != null)
              Container(
                margin: const EdgeInsets.only(right: 12, left: 25),
                child: Icon(
                  widget.selectedIcon,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
              )
            else
              const SizedBox(width: 25),

            // Item text
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 13.6,
                  color: item.selected ? Theme.of(context).primaryColor : AppColors.grey.shade700,
                  fontWeight: item.selected ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            // Expansion indicator for multi-level items
            if (item.isMultiLevel)
              AnimatedRotation(
                turns: item.expanded ? 0.25 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_right,
                  size: 18,
                  color: AppColors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
