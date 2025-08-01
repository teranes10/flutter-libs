import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/select/select_notifier.dart';

class TSelectDropdown<T, V> extends StatefulWidget {
  final TSelectStateNotifier<T, V> stateNotifier;
  final String? footerMessage;
  final bool multiple;
  final double maxHeight;
  final IconData? selectedIcon;
  final ValueChanged<TSelectItem<V>> onItemTapped;
  final bool showLoadingIndicator;
  final bool loading;
  final VoidCallback? onScrollEnd;

  const TSelectDropdown({
    super.key,
    required this.stateNotifier,
    required this.onItemTapped,
    this.footerMessage,
    this.multiple = false,
    this.maxHeight = 200.0,
    this.selectedIcon = Icons.check,
    this.showLoadingIndicator = false,
    this.loading = false,
    this.onScrollEnd,
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

    // Listen for scroll position updates from state notifier
    widget.stateNotifier.scrollPositionNotifier.addListener(_updateScrollPosition);

    // Listen for scroll events for infinite scroll
    if (widget.onScrollEnd != null) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.stateNotifier.scrollPositionNotifier.removeListener(_updateScrollPosition);
    if (widget.onScrollEnd != null) {
      _scrollController.removeListener(_onScroll);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollPosition() {
    if (_scrollController.hasClients) {
      final targetPosition = widget.stateNotifier.scrollPositionNotifier.value;
      if (_scrollController.offset != targetPosition) {
        _scrollController.jumpTo(targetPosition);
      }
    }
  }

  void _onScroll() {
    // Update scroll position in state notifier
    widget.stateNotifier.updateScrollPosition(_scrollController.position.pixels);

    // Check if we're near the bottom for infinite scroll
    if (_scrollController.hasClients && widget.onScrollEnd != null) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      const delta = 100.0; // Trigger load when 100px from bottom

      if (currentScroll >= (maxScroll - delta) && !widget.loading) {
        widget.onScrollEnd!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    // Calculate footer height to account for it in constraints
    final footerHeight = (widget.footerMessage?.isNotEmpty == true) ? 40.0 : 0.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,
        minHeight: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ValueListenableBuilder<List<TSelectItem<V>>>(
              valueListenable: widget.stateNotifier.displayItemsNotifier,
              builder: (context, displayItems, child) {
                // Show loading indicator when initially loading and no items
                if (displayItems.isEmpty && widget.loading) {
                  return SizedBox(
                    height: widget.maxHeight - footerHeight,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Show no items message when not loading and no items
                if (displayItems.isEmpty && !widget.loading) {
                  return SizedBox(
                    height: 60,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No items found',
                          style: TextStyle(color: theme.onSurface, fontSize: 14),
                        ),
                      ),
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: widget.maxHeight - footerHeight,
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: displayItems.length > 10,
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: displayItems.length + (widget.showLoadingIndicator ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end for infinite scroll
                        if (index == displayItems.length && widget.showLoadingIndicator) {
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: widget.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }

                        final item = displayItems[index];
                        return _buildSelectItem(theme, item, 0);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.footerMessage?.isNotEmpty == true)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.surfaceContainer,
                border: Border(top: BorderSide(color: theme.outline)),
              ),
              child: Text(
                widget.footerMessage!,
                style: TextStyle(fontSize: 12, color: theme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectItem(ColorScheme theme, TSelectItem<V> item, int level) {
    return Column(
      children: [
        Listener(
          onPointerUp: (_) {
            widget.stateNotifier.onItemTapped(item);
            widget.onItemTapped(item);
          },
          child: InkWell(
            key: ValueKey('${item.key}_${item.selected}_${item.expanded}_$level'),
            splashColor: theme.primaryContainer.withAlpha(150),
            highlightColor: theme.primaryContainer.withAlpha(200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: item.selected ? theme.primaryContainer : theme.surface,
              padding: EdgeInsets.only(left: 16.0 + (level * 18.0), right: 16.0, top: 10.0, bottom: 10.0),
              child: Row(
                children: [
                  // Selection indicator
                  if (widget.multiple)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Icon(
                        item.selected ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 18,
                        color: item.selected ? theme.onPrimaryContainer : theme.onSurface,
                      ),
                    )
                  else if (item.selected && widget.selectedIcon != null)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Icon(
                        widget.selectedIcon,
                        size: 18,
                        color: theme.primary,
                      ),
                    )
                  else
                    const SizedBox(width: 12),

                  // Item text
                  Expanded(
                    child: Text(
                      item.text,
                      style: TextStyle(
                        fontSize: 13.6,
                        color: item.selected ? theme.primary : theme.onSurface,
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
                        color: theme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Render children if expanded
        if (item.hasChildren && item.expanded) ...item.children!.map((child) => _buildSelectItem(theme, child, level + 1)),
      ],
    );
  }
}
