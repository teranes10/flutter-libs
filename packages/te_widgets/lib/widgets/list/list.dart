import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:te_widgets/te_widgets.dart';

/// A powerful list component with pagination, search, and infinite scroll.
///
/// `TList` provides a feature-rich list widget with:
/// - Pagination with automatic or manual items per page
/// - Server-side data loading with `onLoad`
/// - Search and filtering
/// - Infinite scroll support
/// - Reorderable items
/// - Grid layout support
/// - Selection (single/multiple)
/// - Expandable/hierarchical items
/// - Custom animations
/// - Scroll position tracking
///
/// ## Basic Usage
///
/// ```dart
/// TList<String, String>(
///   items: ['Item 1', 'Item 2', 'Item 3'],
///   itemBuilder: (context, item, index) {
///     return ListTile(title: Text(item.data));
///   },
/// )
/// ```
///
/// ## With Server-Side Loading
///
/// ```dart
/// TList<Product, int>(
///   itemsPerPage: 10,
///   itemKey: (product) => product.id,
///   onLoad: (page, search) async {
///     final response = await api.getProducts(page, search);
///     return (response.items, response.hasMore);
///   },
///   itemTitle: (product) => product.name,
///   itemSubTitle: (product) => product.description,
/// )
/// ```
///
/// ## With Search
///
/// ```dart
/// TList<User, int>(
///   items: users,
///   search: searchQuery,
///   searchDelay: 300,
///   itemKey: (user) => user.id,
///   itemTitle: (user) => user.name,
/// )
/// ```
///
/// Type parameters:
/// - [T]: The type of items in the list
/// - [K]: The type of the item key (for tracking items)
///
/// See also:
/// - [TListController] for programmatic control
/// - [TDataTable] for tabular data
/// - [TListCard] for default card rendering
/// A remembered measurement of a list layout: the average [item] height (separator included) and the [chrome]
/// (header, footer and anything else that is not an item) of the list area.
typedef TItemHeightSample = ({double item, double chrome});

class TList<T, K> extends StatefulWidget with TListMixin<T, K> {
  /// Custom builder for rendering each list item.
  final ListItemBuilder<T, K> itemBuilder;

  /// Custom theme for the list.
  final TListTheme? theme;

  // List configuration

  /// The list of items to display.
  ///
  /// If null, items must be loaded via [onLoad].
  @override
  final List<T>? items;

  /// Number of items to display per page.
  ///
  /// If null or 0, will auto-calculate based on available height.
  @override
  final int? itemsPerPage;

  /// Initial search query.
  @override
  final String? search;

  /// Debounce delay for search in milliseconds.
  @override
  final int? searchDelay;

  /// Callback for loading items from a server.
  ///
  /// Returns a tuple of (items, hasMore).
  @override
  final TLoadListener<T>? onLoad;

  /// Function to extract a unique key from an item.
  @override
  final ItemKeyAccessor<T, K>? itemKey;

  /// Controller for managing list state.
  @override
  final TListController<T, K>? controller;

  /// Callback fired when the list controller is initialized and ready.
  @override
  final TControllerReadyListener<T, K>? onControllerReady;

  // Scroll configuration

  /// Custom scroll controller.
  final ScrollController? scrollController;

  /// Callback fired when scrolled to the end.
  final VoidCallback? onScrollEnd;

  /// Threshold distance from bottom to trigger scroll end.
  final double scrollEndThreshold;

  /// ValueNotifier for tracking scroll position (0.0 to 1.0).
  final ValueNotifier<double>? scrollPositionNotifier;

  /// Callback fired when scroll position changes.
  final ValueChanged<double>? onScrollPositionChanged;

  // Auto items per page

  /// Whether to automatically calculate items per page based on height.
  ///
  /// Defaults to true.
  final bool autoItemsPerPage;

  /// Estimated height of one item including its separator, used to size the first page before any item has been
  /// rendered. Falls back to a layout-based guess when null.
  final double? estimatedItemHeight;

  /// Returns a remembered measurement for a list that is [width] wide, used for the first page-size estimate.
  final TItemHeightSample? Function(double width)? itemHeightHint;

  /// Called with the measured item height and chrome for the current [width], so callers can remember them and
  /// return them from [itemHeightHint] next time.
  final void Function(double width, double item, double chrome)? onItemHeightMeasured;

  // List card

  /// Custom theme for list item cards.
  final TListCardTheme? cardTheme;

  /// Function to extract title text from an item.
  final ItemTextAccessor<T>? itemTitle;

  /// Function to extract subtitle text from an item.
  final ItemTextAccessor<T>? itemSubTitle;

  /// Function to extract image URL from an item.
  final ItemTextAccessor<T>? itemImageUrl;

  /// Callback fired when an item is tapped.
  final ListItemTap<T, K>? onTap;

  // Theme overrides

  /// Grid layout mode.
  final TGridMode? grid;

  /// Delegate for controlling grid layout.
  final TGridDelegateBuilder? gridDelegate;

  /// Whether the list should shrink-wrap its content.
  final bool? shrinkWrap;

  /// Custom header widget.
  final TListHeaderBuilder? headerBuilder;

  /// Custom footer widget.
  final TListFooterBuilder? footerBuilder;

  /// Builder for content before the list items.
  final WidgetBuilder? beforeItemsBuilder;

  /// Whether to enable infinite scroll.
  final bool? infiniteScroll;

  /// Whether the header should be sticky.
  final bool? headerSticky;

  /// Whether the footer should be sticky.
  final bool? footerSticky;

  /// Callback when reorder drag-and-drop ends.
  final VoidCallback? onReorderEnd;

  // Padding
  final EdgeInsets? padding;

  /// Creates a list component.
  TList({
    super.key,
    this.theme,
    // List
    this.items,
    this.itemsPerPage,
    this.search,
    this.searchDelay,
    this.onLoad,
    this.itemKey,
    this.controller,
    this.onControllerReady,
    // Scroll
    this.scrollController,
    this.onScrollEnd,
    this.scrollEndThreshold = 0.0,
    this.scrollPositionNotifier,
    this.onScrollPositionChanged,
    // Auto
    this.autoItemsPerPage = true,
    this.estimatedItemHeight,
    this.itemHeightHint,
    this.onItemHeightMeasured,
    // List card
    this.cardTheme,
    ItemTextAccessor<T>? itemTitle,
    this.itemSubTitle,
    this.itemImageUrl,
    this.onTap,
    ListItemBuilder<T, K>? itemBuilder,
    this.beforeItemsBuilder,
    // Theme overrides
    this.grid,
    this.gridDelegate,
    this.shrinkWrap,
    this.headerBuilder,
    this.footerBuilder,
    this.infiniteScroll,
    this.headerSticky,
    this.footerSticky,
    this.onReorderEnd,
    this.padding,
  })  : assert(
          theme == null ||
              (grid == null &&
                  gridDelegate == null &&
                  shrinkWrap == null &&
                  headerBuilder == null &&
                  footerBuilder == null &&
                  infiniteScroll == null &&
                  headerSticky == null &&
                  footerSticky == null &&
                  padding == null),
          'Cannot provide both theme and individual theme properties.',
        ),
        itemTitle = itemTitle ?? defaultItemTitle,
        itemBuilder = itemBuilder ?? defaultItemBuilder<T, K>(cardTheme, itemTitle ?? defaultItemTitle, itemSubTitle, itemImageUrl, onTap);

  static String defaultItemTitle<T>(T item) {
    return item.toString();
  }

  static ListItemBuilder<T, K> defaultItemBuilder<T, K>(
    TListCardTheme? theme,
    ItemTextAccessor<T>? itemTitle,
    ItemTextAccessor<T>? itemSubTitle,
    ItemTextAccessor<T>? itemImageUrl,
    ListItemTap<T, K>? onTap,
  ) {
    return (ctx, item, index) {
      final controller = TListScope.of(ctx).controller as TListController<T, K>;

      return TListCard(
        title: itemTitle?.call(item.data) ?? '',
        subTitle: itemSubTitle?.call(item.data),
        imageUrl: itemImageUrl?.call(item.data),
        isSelected: controller.isSelected(item.key),
        isExpanded: controller.isExpanded(item.key),
        level: item.level,
        theme: theme,
        multiple: controller.isMultiSelect,
        hasChildren: item.hasChildren,
        onTap: () {
          if (item.hasChildren) {
            controller.toggleExpansion(item.key);
          }
          onTap?.call(item);
        },
      );
    };
  }

  @override
  State<TList<T, K>> createState() => _TListState<T, K>();
}

class _TListState<T, K> extends State<TList<T, K>> with SingleTickerProviderStateMixin, TListStateMixin<T, K, TList<T, K>> {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _scrollControllerOwned = false;
  TListTheme? _cachedTheme;

  TListTheme get wTheme {
    if (widget.theme != null) return widget.theme!;

    return _cachedTheme ??
        context.theme.listTheme.copyWith(
          grid: widget.grid,
          gridDelegate: widget.gridDelegate,
          shrinkWrap: widget.shrinkWrap,
          headerBuilder: widget.headerBuilder,
          footerBuilder: widget.footerBuilder,
          infiniteScroll: widget.infiniteScroll,
          headerSticky: widget.headerSticky,
          footerSticky: widget.footerSticky,
          padding: widget.padding,
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedTheme = context.theme.listTheme.copyWith(
      grid: widget.grid,
      gridDelegate: widget.gridDelegate,
      shrinkWrap: widget.shrinkWrap,
      headerBuilder: widget.headerBuilder,
      footerBuilder: widget.footerBuilder,
      infiniteScroll: widget.infiniteScroll,
      headerSticky: widget.headerSticky,
      footerSticky: widget.footerSticky,
      padding: widget.padding,
    );
  }

  @override
  void initState() {
    super.initState();
    final animationDuration = widget.theme?.animationDuration ?? Duration(milliseconds: 800);
    _animationController = AnimationController(vsync: this, duration: animationDuration);

    _scrollController = widget.scrollController ?? ScrollController();
    _scrollControllerOwned = widget.scrollController == null;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(TList<T, K> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.theme == null) {
      _cachedTheme = context.theme.listTheme.copyWith(
        grid: widget.grid,
        gridDelegate: widget.gridDelegate,
        shrinkWrap: widget.shrinkWrap,
        headerBuilder: widget.headerBuilder,
        footerBuilder: widget.footerBuilder,
        infiniteScroll: widget.infiniteScroll,
        headerSticky: widget.headerSticky,
        footerSticky: widget.footerSticky,
        padding: widget.padding,
      );
    }

    // Handle scroll controller changes
    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController.removeListener(_onScroll);

      if (_scrollControllerOwned) {
        _scrollController.dispose();
      }

      _scrollController = widget.scrollController ?? ScrollController();
      _scrollControllerOwned = widget.scrollController == null;

      _scrollController.addListener(_onScroll);
    }

    // Handle theme animation duration changes
    if (oldWidget.theme?.animationDuration != widget.theme?.animationDuration) {
      _animationController.duration = wTheme.animationDuration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();

    _scrollController.removeListener(_onScroll);

    if (_scrollControllerOwned) {
      _scrollController.dispose();
    }

    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final scrollPosition = position.pixels / position.maxScrollExtent;

    widget.scrollPositionNotifier?.value = scrollPosition;
    widget.onScrollPositionChanged?.call(scrollPosition);

    // Handle scroll end
    if (widget.onScrollEnd != null || wTheme.infiniteScroll != false) {
      final threshold = widget.scrollEndThreshold;
      if (position.pixels >= position.maxScrollExtent - threshold) {
        widget.onScrollEnd?.call();
        listController.handleLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TListScope(
      controller: listController,
      child: LayoutBuilder(builder: (context, constraints) {
        if (widget.autoItemsPerPage) {
          _handleAutoItemsPerPage(constraints);
        }

        return TReactiveSelector(
          listenable: listController,
          selector: (x) => x,
          builder: (context, state, oldState) {
            if (state.displayItems.isEmpty && _animationController.status == AnimationStatus.completed) {
              _animationController.reset();
            }

            if (state.displayItems.isNotEmpty &&
                !_animationController.isAnimating &&
                _animationController.status == AnimationStatus.dismissed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _animationController.forward();
                }
              });
            }

            if (widget.autoItemsPerPage) _handleAutoItemsPerPage(constraints);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (wTheme.infiniteScroll != false &&
                  listController.value.hasMoreItems &&
                  !listController.value.fetching &&
                  !listController.value.loading) {
                if (_scrollController.hasClients) {
                  final position = _scrollController.position;
                  if (position.maxScrollExtent <= 0.0) {
                    listController.handleLoadMore();
                  }
                }
              }
            });

            return TListView(
              items: state.displayItems,
              error: state.error,
              headerSticky: wTheme.headerSticky ?? false,
              headerBuilder: wTheme.headerBuilder,
              footerSticky: wTheme.footerSticky ?? false,
              footerBuilder: wTheme.footerBuilder,
              loading: state.loading,
              loadingBuilder: wTheme.loadingBuilder,
              infiniteScroll: wTheme.infiniteScroll ?? false,
              infiniteScrollFooterBuilder: wTheme.infiniteScrollFooterBuilder,
              errorStateBuilder: wTheme.errorStateBuilder,
              emptyStateBuilder: wTheme.emptyStateBuilder,
              beforeItemsBuilder: widget.beforeItemsBuilder,
              itemBuilder: (context, item, index) {
                final child = widget.itemBuilder(context, item, index);
                final animationBuilder = wTheme.animationBuilder;

                if (animationBuilder != null) {
                  return animationBuilder(context, _animationController, child, index);
                }
                return child;
              },
              listSeparatorBuilder: wTheme.listSeparatorBuilder,
              padding: wTheme.padding,
              reorderable: listController.reorderable,
              dragProxyDecorator: wTheme.dragProxyDecorator,
              onReorder: listController.reorder,
              onReorderEnd: widget.onReorderEnd != null ? (_) => widget.onReorderEnd!() : null,
              grid: wTheme.grid,
              gridDelegate: wTheme.gridDelegate,
              //    height: _calculateHeight(state),
              shrinkWrap: wTheme.shrinkWrap ?? false,
              scrollController: _scrollController,
            );
          },
        );
      }),
    );
  }

  int? _lastAutoItemsPerPage;
  bool _fitScheduled = false;
  bool _initialLoadRequested = false;

  /// Row height used for the very first estimate, before any row has been measured. It is a little under the
  /// real height so the estimate over-fills (a bit of scrolling is fine, blank space is not).
  double get _estimatedRowHeight {
    if (widget.estimatedItemHeight != null) return widget.estimatedItemHeight!;
    final scope = TTableScope.maybeOf(context);
    if (scope == null) return 60;
    if (scope.isCardView) return scope.dense ? 84 : 112;
    return scope.dense ? 52 : 76;
  }

  /// Height taken by the column header and the pagination footer, which sit inside the list and are not rows.
  double get _estimatedChromeHeight {
    final scope = TTableScope.maybeOf(context);
    if (scope == null) return 0;
    final header = scope.isCardView ? 0.0 : (scope.dense ? 34.0 : 46.0);
    final footer = scope.dense ? 48.0 : 60.0;
    return header + footer;
  }

  /// Starts the first load with an estimated page size (a single request), then lets [_fitItemsPerPage]
  /// grow the page from the measured row height if blank space remains.
  void _handleAutoItemsPerPage(BoxConstraints constraints) {
    final c = listController;
    _lastWidth = constraints.maxWidth;
    _lastMaxHeight = constraints.maxHeight;

    if (!_initialLoadRequested) {
      _initialLoadRequested = true;
      final sample = widget.itemHeightHint?.call(constraints.maxWidth);
      final estimate = c.autoItemsPerPage
          ? (constraints.hasBoundedHeight && constraints.maxHeight > 0
              ? ((constraints.maxHeight - (sample?.chrome ?? _estimatedChromeHeight)) / (sample?.item ?? _estimatedRowHeight))
                  .ceil()
                  .clamp(1, 200)
              : (c.itemsPerPage > 0 ? c.itemsPerPage : 10))
          : c.itemsPerPage;
      if (c.autoItemsPerPage) _lastAutoItemsPerPage = estimate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (estimate > 0 && estimate != listController.itemsPerPage) {
          listController.handleItemsPerPageChange(estimate); // loads with the new size
        } else if (listController.isEmpty && !listController.isFetching) {
          listController.handleRefresh();
        }
      });
      return;
    }

    if (!c.autoItemsPerPage && widget.onItemHeightMeasured == null) return;
    if (!constraints.hasBoundedHeight || wTheme.shrinkWrap == true || wTheme.infiniteScroll == true || wTheme.grid != null) return;
    if (_fitScheduled) return;
    _fitScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitScheduled = false;
      if (mounted) _fitItemsPerPage();
    });
  }

  double? _lastReportedItemHeight;
  double? _lastReportedChrome;
  double? _lastReportedWidth;
  double _lastWidth = 0;
  double _lastMaxHeight = 0;

  void _fitItemsPerPage() {
    final c = listController;
    final state = c.value;
    if (state.loading || state.fetching || state.displayItems.isEmpty) return;
    // Expanded/edited rows change the content height, which is neither a row measurement nor a reason to resize.
    if (state.activeKey != null || state.isCreatingItem) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (!position.hasViewportDimension) return;

    final viewport = _findViewport(context.findRenderObject(), position);
    if (viewport == null) return;

    // Total laid-out extent of the slivers (header/footer inside the scroll view plus the items) and the items alone.
    double content = 0;
    double itemsExtent = 0;
    for (RenderSliver? child = viewport.firstChild; child != null; child = viewport.childAfter(child)) {
      content += child.geometry?.scrollExtent ?? 0;
      final items = _findItemsSliver(child);
      if (items != null && itemsExtent == 0) itemsExtent = items.geometry?.scrollExtent ?? 0;
    }

    final rows = state.displayItems.length;
    if (itemsExtent <= 0) return;
    final rowExtent = itemsExtent / rows;

    // Chrome = what surrounds the items: sticky header/footer outside the scroll view plus the in-scroll parts.
    final chrome = (_lastMaxHeight.isFinite ? _lastMaxHeight - position.viewportDimension : 0) + (content - itemsExtent);

    // Reported on every measurement (tiny changes ignored) so the caller can keep a running average per width.
    if (_lastReportedItemHeight == null ||
        (_lastReportedItemHeight! - rowExtent).abs() > 1 ||
        (_lastReportedChrome! - chrome).abs() > 1 ||
        _lastReportedWidth != _lastWidth) {
      _lastReportedItemHeight = rowExtent;
      _lastReportedChrome = chrome;
      _lastReportedWidth = _lastWidth;
      widget.onItemHeightMeasured?.call(_lastWidth, rowExtent, chrome);
    }

    if (!c.autoItemsPerPage) return;
    if (_lastAutoItemsPerPage != null && c.itemsPerPage != _lastAutoItemsPerPage) {
      // The page size was changed from outside (e.g. the page-size dropdown): stop auto-fitting.
      c.autoItemsPerPage = false;
      return;
    }

    // Only ever grow: scrolling is fine, blank space below the rows is not. Round up so the space is always covered.
    int? target;
    final slack = position.viewportDimension - content;
    if (slack > 1 && rows >= c.itemsPerPage && (state.hasMoreItems || state.totalItems > rows)) {
      target = (c.itemsPerPage + (slack / rowExtent).ceil()).clamp(1, 200);
    }
    if (target == null || target == c.itemsPerPage) return;

    _lastAutoItemsPerPage = target;
    c.handleItemsPerPageChange(target);
  }

  /// The sliver that lays out the items (a multi-box sliver list) inside [root], if any.
  RenderSliverMultiBoxAdaptor? _findItemsSliver(RenderObject root) {
    RenderSliverMultiBoxAdaptor? found;
    void visit(RenderObject node) {
      if (found != null) return;
      if (node is RenderSliverMultiBoxAdaptor) {
        found = node;
        return;
      }
      node.visitChildren(visit);
    }

    visit(root);
    return found;
  }

  RenderViewport? _findViewport(RenderObject? root, ScrollPosition position) {
    RenderViewport? found;
    void visit(RenderObject node) {
      if (found != null) return;
      if (node is RenderViewport && node.offset == position) {
        found = node;
        return;
      }
      node.visitChildren(visit);
    }

    if (root != null) visit(root);
    return found;
  }
}
