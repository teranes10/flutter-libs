import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TListTheme {
  final TListAnimationBuilder? animationBuilder;
  final Duration animationDuration;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
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
  final Widget? headerWidget;
  final bool headerSticky;
  // Footer widget
  final Widget? footerWidget;
  final bool footerSticky;
  // Horizontal scroll
  final bool needsHorizontalScroll;
  final double? horizontalScrollWidth;
  // Infinite scroll
  final bool infiniteScroll;
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
    this.headerWidget,
    this.headerSticky = false,
    // Footer
    this.footerWidget,
    this.footerSticky = false,
    // Horizontal scroll
    this.needsHorizontalScroll = false,
    this.horizontalScrollWidth,
    // Infinite scroll
    this.infiniteScroll = true,
    this.itemBaseHeight = 50,
    this.loadingMessage = 'Loading...',
    this.noMoreItemsMessage = 'No more items to display.',
    // Separators
    this.separatorBuilder,
    this.showSeparators = false,
    // Spacing
    this.itemSpacing = 0,
  })  : assert(!shrinkWrap || !infiniteScroll, 'TListTheme: shrinkWrap disables scrolling, so infiniteScroll cannot be used.'),
        assert(!shrinkWrap || !headerSticky, 'TListTheme: shrinkWrap disables scrolling, so headerSticky cannot be used.'),
        assert(!shrinkWrap || !footerSticky, 'TListTheme: shrinkWrap disables scrolling, so footerSticky cannot be used.'),
        assert(itemBaseHeight > 0, 'TListTheme: itemBaseHeight must be greater than 0');

  TListTheme copyWith({
    TListAnimationBuilder? animationBuilder,
    Duration? animationDuration,
    bool? shrinkWrap,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
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
    Widget? headerWidget,
    bool? headerSticky,
    // Footer
    Widget? footerWidget,
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
      headerWidget: headerWidget ?? this.headerWidget,
      headerSticky: headerSticky ?? this.headerSticky,
      footerWidget: footerWidget ?? this.footerWidget,
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

  Widget buildListView<T, K>({
    required BuildContext context,
    required List<TListItem<T, K>> items,
    required ListItemBuilder<T, K> itemBuilder,
    required AnimationController animationController,
    required ScrollController scrollController,
    required ScrollController horizontalScrollController,
    required TListController<T, K> listController,
    required TListInteraction<T> interaction,
    required bool loading,
    required bool hasError,
    required TListError? error,
    required bool hasMoreItems,
    double? height,
  }) {
    final effectiveInfiniteScroll = infiniteScroll && listController.hasMoreItems;

    // Error state takes priority
    if (hasError && error != null && items.isEmpty) {
      return buildErrorState(context, error);
    }

    // Empty state when no items and not loading
    if (items.isEmpty && !loading) {
      return buildEmptyState(context);
    }

    Widget buildItem(BuildContext context, int index) {
      // Header (non-sticky)
      if (headerWidget != null && !headerSticky && index == 0) {
        return headerWidget!;
      }

      // Calculate item index offset
      final itemOffset = (headerWidget != null && !headerSticky) ? 1 : 0;
      final itemIndex = index - itemOffset;

      // Infinite scroll indicator
      final infiniteScrollIndex = items.length + itemOffset;
      if (effectiveInfiniteScroll && index == infiniteScrollIndex) {
        return _buildInfiniteScrollFooter(context, items, loading, hasMoreItems);
      }

      // Footer (non-sticky)
      final footerIndex = items.length + itemOffset + (effectiveInfiniteScroll ? 1 : 0);
      if (footerWidget != null && !footerSticky && index == footerIndex) {
        return footerWidget!;
      }

      // Regular item
      final item = items[itemIndex];
      Widget child = interaction.buildGestureDetector(
        key: ObjectKey(item),
        item: item.data,
        index: itemIndex,
        selectable: listController.selectable,
        expandable: listController.expandable,
        controller: listController,
        child: itemBuilder(context, item, itemIndex, listController.isMultiSelect),
      );

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

      return child;
    }

    final totalItemCount = items.length +
        (headerWidget != null && !headerSticky ? 1 : 0) +
        (footerWidget != null && !footerSticky ? 1 : 0) +
        (effectiveInfiniteScroll ? 1 : 0);

    final effectivePhysics = physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics());

    Widget listView;

    if (showSeparators && separatorBuilder != null) {
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
      children: [
        if (loading && items.isEmpty) buildLoadingIndicator(context),
        if (headerWidget != null && headerSticky) headerWidget!,
        if (shrinkWrap) listView else if (height != null) SizedBox(height: height, child: listView) else Expanded(child: listView),
        if (footerWidget != null && footerSticky) footerWidget!,
      ],
    );

    // Wrap with horizontal scroll if needed
    final scrollableContent = needsHorizontalScroll ? _buildHorizontalScroll(column, horizontalScrollController) : column;

    return scrollableContent;
  }

  Widget _buildInfiniteScrollFooter<T>(
    BuildContext context,
    List<T> items,
    bool loading,
    bool hasMoreItems,
  ) {
    final colors = Theme.of(context).colorScheme;

    if (items.isNotEmpty && loading) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
            ),
            if (loadingMessage.isNotEmpty) ...[
              const SizedBox(width: 14),
              Text(
                loadingMessage,
                style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      );
    }

    if (!hasMoreItems && noMoreItemsMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          noMoreItemsMessage,
          style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
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
}
