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
class TListView<T, K> extends StatelessWidget {
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
    this.emptyStateBuilder,
    required this.itemBuilder,
    this.listSeparatorBuilder,
    this.padding,
    this.reorderable = false,
    this.dragProxyDecorator,
    this.onReorder,
    this.grid,
    this.gridDelegate,
    this.height,
    this.shrinkWrap = false,
    this.scrollController,
  }) : assert(grid == null || !reorderable, "GridView does not support item reordering.");

  @override
  Widget build(BuildContext context) {
    Widget listView = CustomScrollView(
      controller: shrinkWrap ? null : scrollController,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
      slivers: buildSlivers(context),
    );

    if (!shrinkWrap) {
      if (height != null) {
        listView = SizedBox(height: height, child: listView);
      } else {
        listView = Expanded(child: listView);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerBuilder != null && headerSticky == true) headerBuilder!(context),
        if (loading && items.isEmpty && loadingBuilder != null) loadingBuilder!(context),
        listView,
        if (footerBuilder != null && footerSticky == true) footerBuilder!(context),
      ],
    );
  }

  /// Builds the slivers for the scroll view.
  List<Widget> buildSlivers(BuildContext context) {
    return [
      // Non-sticky header
      if (headerBuilder != null && headerSticky != true)
        SliverToBoxAdapter(
          child: Container(key: const ValueKey('list_header'), child: headerBuilder!(context)),
        ),
      // Main content with padding
      SliverPadding(padding: padding ?? EdgeInsets.zero, sliver: buildContentSliver(context)),
      // Infinite scroll indicator
      if (infiniteScroll && infiniteScrollFooterBuilder != null)
        SliverToBoxAdapter(
          child: Container(key: const ValueKey('list_infinite_scroll_footer'), child: infiniteScrollFooterBuilder!(context)),
        ),
      // Non-sticky footer
      if (footerBuilder != null && footerSticky != true)
        SliverToBoxAdapter(
          child: Container(key: const ValueKey('list_footer'), child: footerBuilder!(context)),
        ),
    ];
  }

  /// Builds the main content sliver.
  Widget buildContentSliver(BuildContext context) {
    if (error != null) {
      return SliverToBoxAdapter(
        child: Container(
          key: const ValueKey('list_error_message'),
          child: errorStateBuilder?.call(context, error!) ??
              TListTheme.buildErrorState(context.colors, title: error!.title, message: error!.message),
        ),
      );
    }

    if (!loading && error == null && items.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          key: const ValueKey('list_empty_message'),
          child: emptyStateBuilder?.call(context) ?? TListTheme.buildEmptyState(context.colors),
        ),
      );
    }

    if (reorderable) {
      return SliverReorderableList(
        itemBuilder: buildItem,
        itemCount: items.length,
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          if (oldIndex >= 0 && oldIndex < items.length && newIndex >= 0 && newIndex < items.length) {
            onReorder?.call(oldIndex, newIndex);
          }
        },
        proxyDecorator: dragProxyDecorator,
      );
    } else if (grid != null) {
      final config = gridDelegate!(context);

      if (grid == TGridMode.masonry) {
        return SliverMasonryGrid(
          delegate: SliverChildBuilderDelegate(buildItem, childCount: items.length),
          gridDelegate: config.simpleGridDelegate,
          mainAxisSpacing: config.mainAxisSpacing,
          crossAxisSpacing: config.crossAxisSpacing,
        );
      } else if (grid == TGridMode.aligned) {
        return SliverAlignedGrid(
          itemBuilder: buildItem,
          itemCount: items.length,
          gridDelegate: config.simpleGridDelegate,
          mainAxisSpacing: config.mainAxisSpacing,
          crossAxisSpacing: config.crossAxisSpacing,
        );
      }
    } else if (listSeparatorBuilder != null) {
      return SliverList.separated(
        itemCount: items.length,
        itemBuilder: buildItem,
        separatorBuilder: listSeparatorBuilder!,
      );
    } else {
      return SliverList.builder(
        itemCount: items.length,
        itemBuilder: buildItem,
      );
    }

    throw UnimplementedError();
  }

  /// Builds a single list item helper.
  Widget buildItem(BuildContext context, int index) {
    final item = items[index];
    final child = itemBuilder(context, item, index);
    final keyedChild = Container(key: ValueKey('list_item_${item.key}'), child: child);

    if (reorderable) {
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
