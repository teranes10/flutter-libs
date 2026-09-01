import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:te_widgets/te_widgets.dart';

/// A versatile list/grid view with robust features.
///
/// `TListView` serves as the core rendering engine for [TList] and supports:
/// - List and Grid layouts (including Masonry and Aligned)
/// - Sliver-based scrolling
/// - Sticky headers and footers
/// - Infinite scroll support
/// - Pull-to-refresh integration
/// - Empty, Error, and Loading states
/// - Reordering (Drag and Drop)
///
/// This widget is typically used internally by [TList], but can be used directly
/// for advanced custom layouts.
class TListView<T, K> extends StatefulWidget {
  /// The list of items to display.
  final List<TListItem<T, K>> items;

  /// Error object if in error state.
  final TListError? error;

  /// Whether the header is sticky.
  final bool headerSticky;

  /// Builder for the list header.
  final TListHeaderBuilder? headerBuilder;

  /// Whether the footer is sticky.
  final bool footerSticky;

  /// Builder for the list footer.
  final TListFooterBuilder? footerBuilder;

  /// Whether the list is loading.
  final bool loading;

  /// Builder for loading state.
  final TListLoadingBuilder? loadingBuilder;

  /// Whether infinite scroll is enabled.
  final bool infiniteScroll;

  /// Builder for infinite scroll footer.
  final TListFooterBuilder? infiniteScrollFooterBuilder;

  /// Builder for error state.
  final TListErrorBuilder? errorStateBuilder;

  /// Builder for empty state.
  final TListEmptyBuilder? emptyStateBuilder;

  /// Builder for content before the list items.
  final WidgetBuilder? beforeItemsBuilder;

  /// Builder for individual list items.
  final ListItemBuilder<T, K> itemBuilder;

  /// Builder for list separators.
  final TListSeparatorBuilder? listSeparatorBuilder;

  /// Padding around the list content.
  final EdgeInsets? padding;

  /// Whether items can be reordered.
  final bool reorderable;

  /// Decorator for item while dragging.
  final TListDragProxyDecorator? dragProxyDecorator;

  /// Callback when reorder completes.
  final TListReorderCallback? onReorder;

  /// Callback when reorder drag-and-drop starts.
  final void Function(int index)? onReorderStart;

  /// Callback when reorder drag-and-drop ends.
  final void Function(int index)? onReorderEnd;

  /// Grid mode (masonry, aligned, or null for list).
  final TGridMode? grid;

  /// Delegate for grid layout configuration.
  final TGridDelegateBuilder? gridDelegate;

  /// Fixed height for the list (optional).
  final double? height;

  /// Whether to shrink wrap the scroll view.
  final bool shrinkWrap;

  /// Custom scroll controller.
  final ScrollController? scrollController;

  final List<Widget Function(BuildContext)>? sliverBefore;
  final List<Widget Function(BuildContext)>? sliverAfter;

  /// Creates a list view.
  const TListView({
    super.key,
    required this.items,
    this.error,
    this.headerSticky = false,
    this.headerBuilder,
    this.footerSticky = false,
    this.footerBuilder,
    this.loading = false,
    this.loadingBuilder,
    this.infiniteScroll = false,
    this.infiniteScrollFooterBuilder,
    this.errorStateBuilder,
    this.beforeItemsBuilder,
    this.emptyStateBuilder,
    required this.itemBuilder,
    this.listSeparatorBuilder,
    this.padding,
    this.reorderable = false,
    this.dragProxyDecorator,
    this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.grid,
    this.gridDelegate,
    this.height,
    this.shrinkWrap = false,
    this.scrollController,
    this.sliverBefore,
    this.sliverAfter,
  }) : assert(grid == null || !reorderable, "GridView does not support item reordering.");

  @override
  State<TListView<T, K>> createState() => _TListViewState<T, K>();
}

class _TListViewState<T, K> extends State<TListView<T, K>> {
  late final ValueNotifier<bool> _canScrollUp;
  late final ValueNotifier<bool> _canScrollDown;
  ScrollController? _internalScrollController;

  ScrollController get _effectiveScrollController => widget.scrollController ?? (_internalScrollController ??= ScrollController());

  @override
  void initState() {
    super.initState();
    _canScrollUp = ValueNotifier(false);
    _canScrollDown = ValueNotifier(false);
    _effectiveScrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(TListView<T, K> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController != null) {
        oldWidget.scrollController!.removeListener(_onScroll);
      } else {
        _internalScrollController?.removeListener(_onScroll);
      }
      _effectiveScrollController.addListener(_onScroll);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!mounted) return;
    if (_effectiveScrollController.hasClients && _effectiveScrollController.position.hasContentDimensions) {
      final pos = _effectiveScrollController.position;
      final canUp = pos.pixels > 0;
      final canDown = pos.pixels < (pos.maxScrollExtent - 1);

      if (_canScrollUp.value != canUp) {
        _canScrollUp.value = canUp;
      }
      if (_canScrollDown.value != canDown) {
        _canScrollDown.value = canDown;
      }
    }
  }

  @override
  void dispose() {
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_onScroll);
    }
    _internalScrollController?.removeListener(_onScroll);
    _internalScrollController?.dispose();
    _canScrollUp.dispose();
    _canScrollDown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shadowColor = colors.shadow.withAlpha(50);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isUnbounded = !constraints.hasBoundedHeight;
        final bool effectiveShrinkWrap = widget.shrinkWrap || isUnbounded;

        Widget listView = CustomScrollView(
          controller: effectiveShrinkWrap ? null : _effectiveScrollController,
          primary: effectiveShrinkWrap ? null : (widget.scrollController == null ? true : null),
          shrinkWrap: effectiveShrinkWrap,
          physics: effectiveShrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          slivers: _buildSlivers(context),
        );

        if (!effectiveShrinkWrap) {
          listView = Scrollbar(
            controller: _effectiveScrollController,
            child: listView,
          );
        }

        final hasStickyHeader = widget.headerBuilder != null && widget.headerSticky;
        final hasStickyFooter = widget.footerBuilder != null && widget.footerSticky;

        Widget? headerContent;
        if (hasStickyHeader) {
          headerContent = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.headerBuilder!(context),
              if (widget.loading && widget.loadingBuilder != null) widget.loadingBuilder!(context),
            ],
          );
        }

        Widget? footerContent;
        if (hasStickyFooter) {
          footerContent = widget.footerBuilder!(context);
        }

        Widget elevatedListContent = NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _onScroll();
            return false;
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (effectiveShrinkWrap) listView else Positioned.fill(child: ClipRect(child: listView)),
              // Soft fade cast BY the sticky header ONTO the list — header reads as elevated.
              if (hasStickyHeader)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _canScrollUp,
                    builder: (context, canScrollUp, _) {
                      return IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: canScrollUp ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  shadowColor,
                                  shadowColor.withAlpha(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Soft fade cast BY the sticky footer ONTO the list.
              if (hasStickyFooter)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _canScrollDown,
                    builder: (context, canScrollDown, _) {
                      return IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: canScrollDown ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  shadowColor,
                                  shadowColor.withAlpha(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );

        if (!effectiveShrinkWrap) {
          if (widget.height != null) {
            elevatedListContent = SizedBox(height: widget.height, child: elevatedListContent);
          } else {
            elevatedListContent = Expanded(child: elevatedListContent);
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (headerContent != null) headerContent,
            elevatedListContent,
            if (footerContent != null) footerContent,
          ],
        );
      },
    );
  }

  /// Builds the slivers for the scroll view.
  List<Widget> _buildSlivers(BuildContext context) {
    return [
      if (widget.sliverBefore != null) ...widget.sliverBefore!.map((x) => x(context)),
      // Non-sticky header
      if (widget.headerBuilder != null && widget.headerSticky != true)
        SliverToBoxAdapter(
          child: Container(key: const ValueKey('list_header'), child: widget.headerBuilder!(context)),
        ),
      // Non-sticky loading indicator
      if (widget.loading && widget.loadingBuilder != null && widget.headerSticky != true)
        SliverToBoxAdapter(
          child: widget.loadingBuilder!(context),
        ),
      // Main content with padding
      SliverPadding(
        padding: widget.padding ?? EdgeInsets.zero,
        sliver: SliverMainAxisGroup(
          slivers: [
            if (widget.beforeItemsBuilder != null)
              SliverToBoxAdapter(
                child: Container(
                  key: const ValueKey('list_before_items'),
                  child: widget.beforeItemsBuilder!(context),
                ),
              ),
            _buildContentSliver(context),
          ],
        ),
      ),
      // Infinite scroll indicator
      if (widget.infiniteScroll && widget.infiniteScrollFooterBuilder != null)
        SliverToBoxAdapter(
          child: Container(key: const ValueKey('list_infinite_scroll_footer'), child: widget.infiniteScrollFooterBuilder!(context)),
        ),
      // Non-sticky footer
      if (widget.footerBuilder != null && widget.footerSticky != true)
        SliverToBoxAdapter(
          child: Container(key: const ValueKey('list_footer'), child: widget.footerBuilder!(context)),
        ),
      if (widget.sliverAfter != null) ...widget.sliverAfter!.map((x) => x(context)),
    ];
  }

  /// Builds the main content sliver.
  Widget _buildContentSliver(BuildContext context) {
    if (widget.error != null) {
      return SliverToBoxAdapter(
        child: Container(
          key: const ValueKey('list_error_message'),
          child: widget.errorStateBuilder?.call(context, widget.error!) ??
              TListTheme.buildErrorState(context.colors, title: widget.error!.title, message: widget.error!.message),
        ),
      );
    }

    if (!widget.loading && widget.error == null && widget.items.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          key: const ValueKey('list_empty_message'),
          child: widget.emptyStateBuilder?.call(context) ?? TListTheme.buildEmptyState(context.colors),
        ),
      );
    }

    if (widget.reorderable) {
      return SliverReorderableList(
        itemBuilder: _buildItem,
        itemCount: widget.items.length,
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          if (oldIndex >= 0 && oldIndex < widget.items.length && newIndex >= 0 && newIndex < widget.items.length) {
            widget.onReorder?.call(oldIndex, newIndex);
          }
        },
        onReorderStart: widget.onReorderStart,
        onReorderEnd: widget.onReorderEnd,
        proxyDecorator: widget.dragProxyDecorator,
      );
    } else if (widget.grid != null) {
      final config = widget.gridDelegate!(context);

      if (widget.grid == TGridMode.masonry) {
        return SliverMasonryGrid(
          delegate: SliverChildBuilderDelegate(_buildItem, childCount: widget.items.length),
          gridDelegate: config.simpleGridDelegate,
          mainAxisSpacing: config.mainAxisSpacing,
          crossAxisSpacing: config.crossAxisSpacing,
        );
      } else if (widget.grid == TGridMode.aligned) {
        return SliverAlignedGrid(
          itemBuilder: _buildItem,
          itemCount: widget.items.length,
          gridDelegate: config.simpleGridDelegate,
          mainAxisSpacing: config.mainAxisSpacing,
          crossAxisSpacing: config.crossAxisSpacing,
        );
      }
    } else if (widget.listSeparatorBuilder != null) {
      return SliverList.separated(
        itemCount: widget.items.length,
        itemBuilder: _buildItem,
        separatorBuilder: widget.listSeparatorBuilder!,
      );
    } else {
      return SliverList.builder(
        itemCount: widget.items.length,
        itemBuilder: _buildItem,
      );
    }

    throw UnimplementedError();
  }

  /// Builds a single list item helper.
  Widget _buildItem(BuildContext context, int index) {
    final item = widget.items[index];
    final child = widget.itemBuilder(context, item, index);
    final keyedChild = Container(key: ValueKey('list_item_${item.key}'), child: child);

    if (widget.reorderable) {
      return Row(
        key: keyedChild.key,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.drag_indicator_rounded, size: 20, color: context.colors.onSurfaceVariant.withAlpha(200)),
            ),
          ),
          Expanded(child: child)
        ],
      );
    }

    return keyedChild;
  }
}
