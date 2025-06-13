// select_dropdown.dart
import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'select_configs.dart';

class TSelectDropdown<V> extends StatefulWidget {
  final List<TSelectItem<V>> items;
  final bool multiple;
  final double maxHeight;
  final String? footerMessage;
  final ValueChanged<TSelectItem<V>> onItemTap;
  final double? scrollPosition;
  final ValueChanged<double>? onScrollPositionChanged;

  const TSelectDropdown({
    super.key,
    required this.items,
    required this.onItemTap,
    this.multiple = false,
    this.maxHeight = 200.0,
    this.footerMessage,
    this.scrollPosition,
    this.onScrollPositionChanged,
  });

  @override
  State<TSelectDropdown<V>> createState() => _TSelectDropdownState<V>();
}

class _TSelectDropdownState<V> extends State<TSelectDropdown<V>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.scrollPosition ?? 0.0,
    );

    // Listen to scroll changes to preserve position
    _scrollController.addListener(() {
      widget.onScrollPositionChanged?.call(_scrollController.offset);
    });
  }

  @override
  void didUpdateWidget(TSelectDropdown<V> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restore scroll position after rebuild
    if (widget.scrollPosition != null && _scrollController.hasClients && _scrollController.offset != widget.scrollPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(widget.scrollPosition!);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: widget.items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.footerMessage ?? 'No items found',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              )
            : Scrollbar(
                controller: _scrollController,
                thumbVisibility: widget.items.length > 10,
                child: ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: _buildDropdownItems(context, widget.items, 0),
                ),
              ),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => widget.onItemTap(item),
        child: InkWell(
          key: ValueKey('${item.key}_${item.selected}_${item.expanded}_$level'),
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12, left: 12),
                    child: Icon(
                      item.selected ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 18,
                      color: item.selected ? Theme.of(context).primaryColor : Colors.grey.shade400,
                    ),
                  )
                else if (item.selected)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12, left: 25),
                    child: Icon(
                      Icons.check,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                else
                  const SizedBox(width: 25),

                // Item text
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 13.6,
                      color: item.selected ? AppColors.primary : AppColors.grey.shade700,
                      fontWeight: item.selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                    child: Text(
                      item.text,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),

                // Expansion indicator for multi-level items
                if (item.isMultiLevel)
                  AnimatedRotation(
                    turns: item.expanded ? 0.25 : 0.0, // 90 degrees when expanded
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
