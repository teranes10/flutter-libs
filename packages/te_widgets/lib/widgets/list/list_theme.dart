import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TListTheme {
  final TListAnimationBuilder? animationBuilder;
  final Duration animationDuration;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  // Empty state
  final Widget Function(BuildContext context)? emptyStateBuilder;
  final String emptyStateMessage;
  final IconData emptyStateIcon;
  // Error state
  final Widget Function(BuildContext context, TListError error)? errorStateBuilder;
  final String errorStateMessage;
  // Loading state
  final Widget Function(BuildContext context)? loadingBuilder;
  // Header widget
  final Widget Function(BuildContext context)? headerBuilder;
  final bool? headerSticky;
  // Footer widget
  final Widget Function(BuildContext context)? footerBuilder;
  final bool? footerSticky;
  // Horizontal scroll
  final bool needsHorizontalScroll;
  final double? horizontalScrollWidth;
  // Infinite scroll
  final bool? infiniteScroll;
  final double itemBaseHeight;
  final String loadingMessage;
  final String noMoreItemsMessage;
  // Separators
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final bool showSeparators;
  // Item spacing
  final double itemSpacing;

  const TListTheme({
    this.animationBuilder = TListAnimationBuilders.staggered,
    this.animationDuration = const Duration(milliseconds: 800),
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    // Empty state
    this.emptyStateBuilder,
    this.emptyStateMessage = 'No items found',
    this.emptyStateIcon = Icons.inbox_outlined,
    // Error state
    this.errorStateBuilder,
    this.errorStateMessage = 'An error occurred',
    // Loading state
    this.loadingBuilder,
    // Header
    this.headerBuilder,
    this.headerSticky,
    // Footer
    this.footerBuilder,
    this.footerSticky,
    // Horizontal scroll
    this.needsHorizontalScroll = false,
    this.horizontalScrollWidth,
    // Infinite scroll
    this.infiniteScroll,
    this.itemBaseHeight = 50,
    this.loadingMessage = 'Loading...',
    this.noMoreItemsMessage = 'No more items to display.',
    // Separators
    this.separatorBuilder,
    this.showSeparators = false,
    // Spacing
    this.itemSpacing = 0,
  })  : assert(!shrinkWrap || infiniteScroll != true, 'TListTheme: shrinkWrap disables scrolling, so infiniteScroll cannot be used.'),
        assert(!shrinkWrap || headerSticky != true, 'TListTheme: shrinkWrap disables scrolling, so headerSticky cannot be used.'),
        assert(!shrinkWrap || footerSticky != true, 'TListTheme: shrinkWrap disables scrolling, so footerSticky cannot be used.'),
        assert(itemBaseHeight > 0, 'TListTheme: itemBaseHeight must be greater than 0');

  TListTheme copyWith({
    TListAnimationBuilder? animationBuilder,
    Duration? animationDuration,
    bool? shrinkWrap,
    ScrollPhysics? physics,
    EdgeInsets? padding,
    // Empty state
    Widget Function(BuildContext context)? emptyStateBuilder,
    String? emptyStateMessage,
    IconData? emptyStateIcon,
    // Error state
    Widget Function(BuildContext context, TListError error)? errorStateBuilder,
    String? errorStateMessage,
    // Loading state
    Widget Function(BuildContext context)? loadingBuilder,
    // Header
    Widget Function(BuildContext context)? headerBuilder,
    bool? headerSticky,
    // Footer
    Widget Function(BuildContext context)? footerBuilder,
    bool? footerSticky,
    // Horizontal scroll
    bool? needsHorizontalScroll,
    double? horizontalScrollWidth,
    // Infinite scroll
    bool? infiniteScroll,
    double? itemBaseHeight,
    String? loadingMessage,
    String? noMoreItemsMessage,
    // Separators
    Widget Function(BuildContext context, int index)? separatorBuilder,
    bool? showSeparators,
    // Spacing
    double? itemSpacing,
  }) {
    return TListTheme(
      animationBuilder: animationBuilder ?? this.animationBuilder,
      animationDuration: animationDuration ?? this.animationDuration,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      physics: physics ?? this.physics,
      padding: padding ?? this.padding,
      emptyStateBuilder: emptyStateBuilder ?? this.emptyStateBuilder,
      emptyStateMessage: emptyStateMessage ?? this.emptyStateMessage,
      emptyStateIcon: emptyStateIcon ?? this.emptyStateIcon,
      errorStateBuilder: errorStateBuilder ?? this.errorStateBuilder,
      errorStateMessage: errorStateMessage ?? this.errorStateMessage,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      headerSticky: headerSticky ?? this.headerSticky,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      footerSticky: footerSticky ?? this.footerSticky,
      needsHorizontalScroll: needsHorizontalScroll ?? this.needsHorizontalScroll,
      horizontalScrollWidth: horizontalScrollWidth ?? this.horizontalScrollWidth,
      infiniteScroll: infiniteScroll ?? this.infiniteScroll,
      itemBaseHeight: itemBaseHeight ?? this.itemBaseHeight,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      noMoreItemsMessage: noMoreItemsMessage ?? this.noMoreItemsMessage,
      separatorBuilder: separatorBuilder ?? this.separatorBuilder,
      showSeparators: showSeparators ?? this.showSeparators,
      itemSpacing: itemSpacing ?? this.itemSpacing,
    );
  }

  Widget buildListView<T, K>({
    required BuildContext context,
    required List<TListItem<T, K>> items,
    required ListItemBuilder<T, K> itemBuilder,
    required AnimationController animationController,
    required ScrollController scrollController,
    required ScrollController horizontalScrollController,
    required TListController<T, K> listController,
    required bool loading,
    required bool hasError,
    required TListError? error,
    required bool hasMoreItems,
    double? height,
  }) {
    final effectiveInfiniteScroll = infiniteScroll == true && listController.hasMoreItems;

    // Determine if we should show error/empty as a list item
    final showErrorItem = hasError && error != null;
    final showEmptyItem = !loading && items.isEmpty && !showErrorItem;

    // Adjust item count for error/empty
    final itemCountForList = (showErrorItem || showEmptyItem) ? 1 : items.length;
    final itemOffset = (headerBuilder != null && headerSticky != true) ? 1 : 0;

    Widget buildItem(BuildContext context, int index) {
      // Header (non-sticky)
      if (headerBuilder != null && headerSticky != true && index == 0) {
        return Container(
          key: const ValueKey('list_header'),
          child: headerBuilder!(context),
        );
      }

      // Infinite scroll indicator
      final infiniteScrollIndex = itemCountForList + itemOffset;
      if (effectiveInfiniteScroll && index == infiniteScrollIndex) {
        return Container(
          key: const ValueKey('list_infinite_scroll_footer'),
          child: _buildInfiniteScrollFooter(context, items, loading, hasMoreItems),
        );
      }

      // Footer (non-sticky)
      final footerIndex = itemCountForList + itemOffset + (effectiveInfiniteScroll ? 1 : 0);
      if (footerBuilder != null && footerSticky != true && index == footerIndex) {
        return Container(
          key: const ValueKey('list_footer'),
          child: footerBuilder!(context),
        );
      }

      // Error state
      if (showErrorItem) {
        return Container(
          key: const ValueKey('list_error_message'),
          child: buildErrorState(context, error),
        );
      }

      //Empty state
      if (showEmptyItem) {
        return Container(
          key: const ValueKey('list_empty_message'),
          child: buildEmptyState(context),
        );
      }

      // Regular item
      final itemIndex = index - itemOffset;
      final item = items[itemIndex];
      Widget child = itemBuilder(context, item, itemIndex);

      // Apply animation
      if (animationBuilder != null) {
        child = animationBuilder!(context, animationController, child, itemIndex);
      }

      // Add spacing
      if (itemSpacing > 0) {
        child = Padding(
          padding: EdgeInsets.only(bottom: itemSpacing),
          child: child,
        );
      }

      // Add key for reorderable items
      if (listController.reorderable) {
        return Container(
          key: ValueKey('list_item_${item.key}'),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Opacity(
                  opacity: 0.5,
                  child: Icon(Icons.drag_indicator_rounded, size: 20, color: context.colors.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(child: child)
            ],
          ),
        );
      }

      return Container(
        key: ValueKey('list_item_${item.key}'),
        child: child,
      );
    }

    final totalItemCount = itemCountForList +
        (headerBuilder != null && headerSticky != true ? 1 : 0) +
        (footerBuilder != null && footerSticky != true ? 1 : 0) +
        (effectiveInfiniteScroll ? 1 : 0);

    final effectivePhysics = physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics());

    Widget listView;
    if (listController.reorderable) {
      listView = ReorderableListView.builder(
        buildDefaultDragHandles: false,
        scrollController: shrinkWrap ? null : scrollController,
        shrinkWrap: shrinkWrap,
        physics: effectivePhysics,
        padding: padding,
        itemCount: totalItemCount,
        itemBuilder: buildItem,
        onReorder: (int oldIndex, int newIndex) {
          final adjustedOldIndex = oldIndex - itemOffset;
          var adjustedNewIndex = newIndex - itemOffset;
          if (adjustedNewIndex > adjustedOldIndex) adjustedNewIndex -= 1;
          if (adjustedOldIndex >= 0 && adjustedOldIndex < items.length && adjustedNewIndex >= 0 && adjustedNewIndex <= items.length) {
            listController.reorder(adjustedOldIndex, adjustedNewIndex);
          }
        },
      );
    } else if (showSeparators && separatorBuilder != null) {
      listView = ListView.separated(
        controller: shrinkWrap ? null : scrollController,
        shrinkWrap: shrinkWrap,
        physics: effectivePhysics,
        padding: padding,
        itemCount: totalItemCount,
        itemBuilder: buildItem,
        separatorBuilder: separatorBuilder!,
      );
    } else {
      listView = ListView.builder(
        controller: shrinkWrap ? null : scrollController,
        shrinkWrap: shrinkWrap,
        physics: effectivePhysics,
        padding: padding,
        itemCount: totalItemCount,
        itemBuilder: buildItem,
      );
    }

    // Build column with sticky elements
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (loading && items.isEmpty) buildLoadingIndicator(context),
        if (headerBuilder != null && headerSticky == true) headerBuilder!(context),
        if (shrinkWrap) listView else if (height != null) SizedBox(height: height, child: listView) else Expanded(child: listView),
        if (footerBuilder != null && footerSticky == true) footerBuilder!(context),
      ],
    );

    // Wrap with horizontal scroll if needed
    final scrollableContent = needsHorizontalScroll ? _buildHorizontalScroll(column, horizontalScrollController) : column;

    return scrollableContent;
  }

  Widget _buildInfiniteScrollFooter<T>(BuildContext context, List<T> items, bool loading, bool hasMoreItems) {
    final colors = Theme.of(context).colorScheme;

    if (items.isNotEmpty && loading) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary)),
            if (loadingMessage.isNotEmpty) ...[
              const SizedBox(width: 14),
              Text(loadingMessage, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
            ],
          ],
        ),
      );
    }

    if (!hasMoreItems && noMoreItemsMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(noMoreItemsMessage, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant), textAlign: TextAlign.center),
      );
    }

    return const SizedBox(height: 50);
  }

  Widget _buildHorizontalScroll(Widget child, ScrollController controller) {
    Widget scrollContent = child;

    if (horizontalScrollWidth != null) {
      scrollContent = SizedBox(
        width: horizontalScrollWidth,
        child: scrollContent,
      );
    }

    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: scrollContent,
      ),
    );
  }

  Widget buildLoadingIndicator(BuildContext context) {
    if (loadingBuilder != null) return loadingBuilder!(context);

    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        backgroundColor: colors.primaryContainer,
        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
      ),
    );
  }

  Widget buildEmptyState(BuildContext context) {
    if (emptyStateBuilder != null) return emptyStateBuilder!(context);

    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (_, constraints) {
      return constraints.maxWidth > 250
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(emptyStateIcon, size: 64, color: colors.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('No data available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.onSurface)),
                    const SizedBox(height: 8),
                    Text(emptyStateMessage, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : SizedBox.shrink();
    });
  }

  Widget buildErrorState(BuildContext context, TListError error) {
    if (errorStateBuilder != null) return errorStateBuilder!(context, error);

    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              errorStateMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
