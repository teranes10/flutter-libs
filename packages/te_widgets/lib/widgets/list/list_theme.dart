import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TListTheme {
  final TListAnimationBuilder? animationBuilder;
  final Duration animationDuration;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final Widget Function(BuildContext context)? emptyStateBuilder;
  final Widget Function(BuildContext context, TListError error)? errorStateBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? headerBuilder;
  final bool? headerSticky;
  final Widget Function(BuildContext context)? footerBuilder;
  final bool? footerSticky;
  final bool? infiniteScroll;
  final double itemBaseHeight;
  final Widget Function(BuildContext context) infiniteScrollFooterBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget Function(Widget, int, Animation<double>)? dragProxyDecorator;
  final TGridMode? grid;
  final TGridDelegate Function(BuildContext context)? gridDelegateBuilder;

  const TListTheme({
    this.animationBuilder = TListAnimationBuilders.staggered,
    this.animationDuration = const Duration(milliseconds: 800),
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.emptyStateBuilder,
    this.errorStateBuilder,
    this.loadingBuilder,
    this.headerBuilder,
    this.headerSticky,
    this.footerBuilder,
    this.footerSticky,
    this.infiniteScroll,
    double? itemBaseHeight,
    required this.infiniteScrollFooterBuilder,
    this.separatorBuilder,
    this.dragProxyDecorator,
    this.grid,
    this.gridDelegateBuilder,
  })  : assert(!shrinkWrap || infiniteScroll != true, 'TListTheme: shrinkWrap disables scrolling, so infiniteScroll cannot be used.'),
        assert(!shrinkWrap || headerSticky != true, 'TListTheme: shrinkWrap disables scrolling, so headerSticky cannot be used.'),
        assert(!shrinkWrap || footerSticky != true, 'TListTheme: shrinkWrap disables scrolling, so footerSticky cannot be used.'),
        itemBaseHeight = grid != null ? 200 : 50;

  TListTheme copyWith({
    TListAnimationBuilder? animationBuilder,
    Duration? animationDuration,
    bool? shrinkWrap,
    ScrollPhysics? physics,
    EdgeInsets? padding,
    Widget Function(BuildContext context)? emptyStateBuilder,
    Widget Function(BuildContext context, TListError error)? errorStateBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context)? headerBuilder,
    bool? headerSticky,
    Widget Function(BuildContext context)? footerBuilder,
    bool? footerSticky,
    bool? infiniteScroll,
    double? itemBaseHeight,
    Widget Function(BuildContext context)? infiniteScrollFooterBuilder,
    Widget Function(BuildContext context, int index)? separatorBuilder,
    Widget Function(Widget, int, Animation<double>)? dragProxyDecorator,
    TGridMode? grid,
    TGridDelegate Function(BuildContext context)? gridDelegateBuilder,
  }) {
    return TListTheme(
      animationBuilder: animationBuilder ?? this.animationBuilder,
      animationDuration: animationDuration ?? this.animationDuration,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      physics: physics ?? this.physics,
      padding: padding ?? this.padding,
      emptyStateBuilder: emptyStateBuilder ?? this.emptyStateBuilder,
      errorStateBuilder: errorStateBuilder ?? this.errorStateBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      headerSticky: headerSticky ?? this.headerSticky,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      footerSticky: footerSticky ?? this.footerSticky,
      infiniteScroll: infiniteScroll ?? this.infiniteScroll,
      itemBaseHeight: itemBaseHeight ?? this.itemBaseHeight,
      infiniteScrollFooterBuilder: infiniteScrollFooterBuilder ?? this.infiniteScrollFooterBuilder,
      separatorBuilder: separatorBuilder ?? this.separatorBuilder,
      dragProxyDecorator: dragProxyDecorator ?? this.dragProxyDecorator,
      grid: grid ?? this.grid,
      gridDelegateBuilder: gridDelegateBuilder ?? this.gridDelegateBuilder,
    );
  }

  Widget buildListView<T, K>({
    required BuildContext context,
    required List<TListItem<T, K>> items,
    required ListItemBuilder<T, K> itemBuilder,
    required AnimationController animationController,
    required ScrollController scrollController,
    required TListController<T, K> listController,
    required bool loading,
    required bool hasError,
    required TListError? error,
    required bool hasMoreItems,
    double? height,
  }) {
    assert(grid == null || !listController.reorderable, "GridView does not support item reordering.");
    final effectiveInfiniteScroll = infiniteScroll != false && listController.hasMoreItems;
    final effectivePhysics = physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics());

    final showErrorState = hasError && error != null && errorStateBuilder != null;
    final showEmptyState = !loading && items.isEmpty && !showErrorState && emptyStateBuilder != null;

    Widget buildItem(BuildContext context, int index) {
      final item = items[index];
      Widget child = itemBuilder(context, item, index);

      if (animationBuilder != null) {
        child = animationBuilder!(context, animationController, child, index);
      }

      final keyedChild = Container(key: ValueKey('list_item_${item.key}'), child: child);

      if (listController.reorderable) {
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

    Widget buildContentSliver() {
      if (showErrorState) {
        return SliverToBoxAdapter(
          child: Container(
            key: const ValueKey('list_error_message'),
            child: errorStateBuilder!(context, error),
          ),
        );
      }

      if (showEmptyState) {
        return SliverToBoxAdapter(
          child: Container(
            key: const ValueKey('list_empty_message'),
            child: emptyStateBuilder!(context),
          ),
        );
      }

      if (listController.reorderable) {
        return SliverReorderableList(
          itemBuilder: buildItem,
          itemCount: items.length,
          onReorder: (int oldIndex, int newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            if (oldIndex >= 0 && oldIndex < items.length && newIndex >= 0 && newIndex < items.length) {
              listController.reorder(oldIndex, newIndex);
            }
          },
          proxyDecorator: dragProxyDecorator,
        );
      } else if (grid != null) {
        final config = gridDelegateBuilder!(context);

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
      } else if (separatorBuilder != null) {
        return SliverList.separated(
          itemCount: items.length,
          itemBuilder: buildItem,
          separatorBuilder: separatorBuilder!,
        );
      } else {
        return SliverList.builder(
          itemCount: items.length,
          itemBuilder: buildItem,
        );
      }

      throw UnimplementedError();
    }

    List<Widget> buildSlivers() {
      return [
        // Non-sticky header
        if (headerBuilder != null && headerSticky != true)
          SliverToBoxAdapter(
            child: Container(key: const ValueKey('list_header'), child: headerBuilder!(context)),
          ),
        // Main content with padding
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: buildContentSliver(),
        ),
        // Infinite scroll indicator
        if (effectiveInfiniteScroll)
          SliverToBoxAdapter(
            child: Container(key: const ValueKey('list_infinite_scroll_footer'), child: infiniteScrollFooterBuilder(context)),
          ),
        // Non-sticky footer
        if (footerBuilder != null && footerSticky != true)
          SliverToBoxAdapter(
            child: Container(key: const ValueKey('list_footer'), child: footerBuilder!(context)),
          ),
      ];
    }

    Widget listView = CustomScrollView(
      controller: shrinkWrap ? null : scrollController,
      shrinkWrap: shrinkWrap,
      physics: effectivePhysics,
      slivers: buildSlivers(),
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

  factory TListTheme.defaultTheme(ColorScheme colors) {
    return TListTheme(
      loadingBuilder: (BuildContext context) {
        return SizedBox(
          height: 4,
          child: LinearProgressIndicator(
            backgroundColor: colors.primaryContainer,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
        );
      },
      infiniteScrollFooterBuilder: (BuildContext context) {
        final controller = TListScope.maybeOf(context)?.controller;
        final showLoading = controller != null ? controller.listItems.isNotEmpty && controller.isLoading : false;
        final showNoMoreItems = controller != null ? !controller.hasMoreItems : false;

        if (showLoading) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 14,
              children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary)),
                Text('Loading...', style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
              ],
            ),
          );
        }

        if (showNoMoreItems) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No more items to display.',
                style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant), textAlign: TextAlign.center),
          );
        }

        return const SizedBox(height: 50);
      },
      emptyStateBuilder: (BuildContext context) {
        return LayoutBuilder(builder: (_, constraints) {
          return constraints.maxWidth > 250
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: colors.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No data available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.onSurface)),
                        const SizedBox(height: 8),
                        Text('No items found', style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : SizedBox.shrink();
        });
      },
      errorStateBuilder: (BuildContext context, TListError error) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: colors.error),
                const SizedBox(height: 16),
                Text('An error occurred', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.onSurface)),
                const SizedBox(height: 8),
                Text(error.message, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
      dragProxyDecorator: (Widget child, int index, Animation<double> animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final animValue = Curves.easeInOut.transform(animation.value);
            final elevation = lerpDouble(0, 8, animValue) ?? 0;
            final scale = lerpDouble(1.0, 1.01, animValue) ?? 1.0;

            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: elevation,
                color: Colors.transparent,
                shadowColor: context.colors.shadow,
                borderRadius: BorderRadius.circular(8),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}
