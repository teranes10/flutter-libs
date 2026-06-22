import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  final int? itemsCount;

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
    this.grid,
    this.gridDelegate,
    this.height,
    this.shrinkWrap = false,
    this.scrollController,
    this.itemsCount,
  }) : assert(grid == null || !reorderable, "GridView does not support item reordering.");

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final autoShrinkWrap = shrinkWrap || !constraints.hasBoundedHeight;

        return _MeasuredLayout(
          shrinkWrap: autoShrinkWrap,
          headerBuilder: headerBuilder,
          footerBuilder: footerBuilder,
          loading: loading,
          loadingBuilder: loadingBuilder,
          headerSticky: headerSticky,
          footerSticky: footerSticky,
          stickyRatioThreshold: 0.125,
          scrollController: scrollController,
          scrollBuilder: (context, headerHeight, footerHeight) {
            return CustomScrollView(
              controller: scrollController,
              shrinkWrap: autoShrinkWrap,
              slivers: _buildSlivers(context, isExpanded: !autoShrinkWrap),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildSlivers(BuildContext context, {required bool isExpanded}) => [
        // Header in scroll view when not using Stack-based sticky header
        if (headerBuilder != null && isExpanded && !headerSticky) SliverToBoxAdapter(child: headerBuilder!(context)),

        if (loading && loadingBuilder != null) SliverToBoxAdapter(child: loadingBuilder!(context)),

        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: SliverMainAxisGroup(slivers: [
            if (beforeItemsBuilder != null) SliverToBoxAdapter(child: beforeItemsBuilder!(context)),
            _buildContentSliver(context),
          ]),
        ),

        if (infiniteScroll && infiniteScrollFooterBuilder != null) SliverToBoxAdapter(child: infiniteScrollFooterBuilder!(context)),

        // Footer in scroll view when not using Stack-based sticky footer
        if (footerBuilder != null && isExpanded && !footerSticky) SliverToBoxAdapter(child: footerBuilder!(context)),
      ];

  Widget _buildContentSliver(BuildContext context) {
    if (error != null) {
      return SliverToBoxAdapter(
        child: Container(
          key: const ValueKey('list_error_message'),
          child: errorStateBuilder?.call(context, error!) ??
              TListTheme.buildErrorState(
                context.colors,
                title: error!.title,
                message: error!.message,
              ),
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
        itemBuilder: _buildItem,
        itemCount: itemsCount ?? items.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          if (oldIndex >= 0 && oldIndex < items.length && newIndex >= 0 && newIndex < items.length) {
            onReorder?.call(oldIndex, newIndex);
          }
        },
        proxyDecorator: dragProxyDecorator,
      );
    }

    if (grid != null) {
      final config = gridDelegate!(context);
      switch (grid!) {
        case TGridMode.masonry:
          return SliverMasonryGrid(
            delegate: SliverChildBuilderDelegate(
              _buildItem,
              childCount: itemsCount ?? items.length,
            ),
            gridDelegate: config.simpleGridDelegate,
            mainAxisSpacing: config.mainAxisSpacing,
            crossAxisSpacing: config.crossAxisSpacing,
          );
        case TGridMode.aligned:
          return SliverAlignedGrid(
            itemBuilder: _buildItem,
            itemCount: itemsCount ?? items.length,
            gridDelegate: config.simpleGridDelegate,
            mainAxisSpacing: config.mainAxisSpacing,
            crossAxisSpacing: config.crossAxisSpacing,
          );
      }
    }

    if (listSeparatorBuilder != null) {
      return SliverList.separated(
        itemCount: itemsCount ?? items.length,
        itemBuilder: _buildItem,
        separatorBuilder: listSeparatorBuilder!,
      );
    }

    return SliverList.builder(
      itemCount: itemsCount ?? items.length,
      itemBuilder: _buildItem,
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = items[index];
    final child = itemBuilder(context, item, index);
    final keyed = Container(key: ValueKey('list_item_${item.key}'), child: child);

    if (reorderable) {
      return Row(
        key: keyed.key,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 20,
                color: context.colors.onSurfaceVariant.withAlpha(200),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      );
    }

    return keyed;
  }
}

class _SliverMeasuredHeader extends StatefulWidget {
  final Widget child;
  final bool sticky;
  final double stickyRatioThreshold;

  const _SliverMeasuredHeader({
    required this.child,
    required this.sticky,
    this.stickyRatioThreshold = 0.125,
  });

  @override
  State<_SliverMeasuredHeader> createState() => _SliverMeasuredHeaderState();
}

class _SliverMeasuredHeaderState extends State<_SliverMeasuredHeader> {
  double? _measuredHeight;

  @override
  Widget build(BuildContext context) {
    if (_measuredHeight == null) {
      return SliverToBoxAdapter(
        child: Offstage(
          offstage: true,
          child: MeasureSize(
            onChange: (size) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _measuredHeight = size.height);
              });
            },
            child: widget.child,
          ),
        ),
      );
    }

    return _buildFinal(context, _measuredHeight!);
  }

  Widget _buildFinal(BuildContext context, double height) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = constraints.viewportMainAxisExtent;
        final ratio = viewportHeight > 0 ? height / viewportHeight : 0.0;
        final shouldPin = widget.sticky && ratio <= widget.stickyRatioThreshold;

        return SliverPersistentHeader(
          pinned: shouldPin,
          floating: false,
          delegate: _FixedHeightHeaderDelegate(
            height: height,
            child: widget.child,
            pinned: shouldPin,
          ),
        );
      },
    );
  }
}

// Step 2: Simple fixed-height delegate — no rebuilding, no intrinsics issues.
class _FixedHeightHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  final bool pinned;

  _FixedHeightHeaderDelegate({
    required this.height,
    required this.child,
    required this.pinned,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isStuck = shrinkOffset > 0;

    return Material(
      elevation: isStuck ? 4 : 0,
      shadowColor: Colors.black.withOpacity(0.15),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_FixedHeightHeaderDelegate old) => old.height != height || old.child != child || old.pinned != pinned;
}

typedef _ScrollBuilder = Widget Function(
  BuildContext context,
  double headerHeight,
  double footerHeight,
);

class _MeasuredLayout extends StatefulWidget {
  final TListHeaderBuilder? headerBuilder;
  final TListFooterBuilder? footerBuilder;
  final bool headerSticky;
  final bool footerSticky;
  final double stickyRatioThreshold;
  final _ScrollBuilder scrollBuilder;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final bool loading;
  final TListLoadingBuilder? loadingBuilder;

  const _MeasuredLayout({
    required this.headerBuilder,
    required this.footerBuilder,
    required this.headerSticky,
    required this.footerSticky,
    required this.stickyRatioThreshold,
    required this.scrollBuilder,
    required this.shrinkWrap,
    required this.loading,
    this.loadingBuilder,
    this.scrollController,
  });

  @override
  State<_MeasuredLayout> createState() => _MeasuredLayoutState();
}

class _MeasuredLayoutState extends State<_MeasuredLayout> {
  final _headerHeight = ValueNotifier<double>(0);
  final _footerHeight = ValueNotifier<double>(0);
  final _headerElevated = ValueNotifier<bool>(false);
  final _footerElevated = ValueNotifier<bool>(true);
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _onScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (widget.scrollController == null) _scrollController.dispose();
    _headerHeight.dispose();
    _footerHeight.dispose();
    _headerElevated.dispose();
    _footerElevated.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;
    _headerElevated.value = offset > 0;
    _footerElevated.value = offset < maxExtent;
  }

  @override
  Widget build(BuildContext context) {
    // shrinkWrap = no bounded height = simple Column, no sticky logic needed.
    if (widget.shrinkWrap) return _buildShrinkWrap(context);
    return _buildExpanded(context);
  }

  Widget _buildShrinkWrap(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.headerBuilder != null) widget.headerBuilder!(context),
        if (widget.loading && widget.loadingBuilder != null) widget.loadingBuilder!(context),
        // scrollBuilder excludes header/footer in slivers when shrinkWrap.
        widget.scrollBuilder(context, 0, 0),
        if (widget.footerBuilder != null) widget.footerBuilder!(context),
      ],
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder2(
          first: _headerHeight,
          second: _footerHeight,
          builder: (context, headerH, footerH, _) => Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: widget.headerSticky ? headerH : 0,
                bottom: widget.footerSticky ? footerH : 0,
              ),
              child: widget.scrollBuilder(context, headerH, footerH),
            ),
          ),
        ),
        if (widget.headerBuilder != null && widget.headerSticky)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _MeasureSizeNotifier(
              notifier: _headerHeight,
              onMeasure: (h) {
                if (_headerHeight.value != h) _headerHeight.value = h;
              },
              child: ValueListenableBuilder(
                valueListenable: _headerElevated,
                builder: (context, elevated, child) => _StickyContainer(
                  elevated: elevated,
                  shadowOffset: const Offset(0, 6),
                  child: child!,
                ),
                child: widget.headerBuilder!(context),
              ),
            ),
          ),
        if (widget.footerBuilder != null && widget.footerSticky)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _MeasureSizeNotifier(
              notifier: _footerHeight,
              onMeasure: (h) {
                if (_footerHeight.value != h) _footerHeight.value = h;
              },
              child: ValueListenableBuilder(
                valueListenable: _footerElevated,
                builder: (context, elevated, child) => _StickyContainer(
                  elevated: elevated,
                  shadowOffset: const Offset(0, -6),
                  child: child!,
                ),
                child: widget.footerBuilder!(context),
              ),
            ),
          ),
      ],
    );
  }
}

// Replaces MeasureSize but writes directly to a ValueNotifier.
class _MeasureSizeNotifier extends SingleChildRenderObjectWidget {
  final ValueNotifier<double> notifier;
  final ValueChanged<double> onMeasure;

  const _MeasureSizeNotifier({
    required this.notifier,
    required this.onMeasure,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => _MeasureSizeNotifierRenderObject(onMeasure);

  @override
  void updateRenderObject(BuildContext context, _MeasureSizeNotifierRenderObject ro) {
    ro.onMeasure = onMeasure;
  }
}

class _MeasureSizeNotifierRenderObject extends RenderProxyBox {
  ValueChanged<double> onMeasure;
  double? _prevHeight;

  _MeasureSizeNotifierRenderObject(this.onMeasure);

  @override
  void performLayout() {
    super.performLayout();
    final h = child?.size.height ?? 0;
    if (_prevHeight != h) {
      _prevHeight = h;
      WidgetsBinding.instance.addPostFrameCallback((_) => onMeasure(h));
    }
  }
}

// Animated shadow container — only rebuilds when [elevated] flips.
class _StickyContainer extends StatelessWidget {
  final bool elevated;
  final Offset shadowOffset;
  final Widget child;

  const _StickyContainer({
    required this.elevated,
    required this.shadowOffset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(context.isDarkMode ? 160 : 40),
                  blurRadius: 15,
                  spreadRadius: -13,
                  offset: shadowOffset,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}

// Listens to two ValueNotifiers with a single builder.
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext, A, B, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      child: child,
      builder: (context, a, child) => ValueListenableBuilder<B>(
        valueListenable: second,
        child: child,
        builder: (context, b, child) => builder(context, a, b, child),
      ),
    );
  }
}
