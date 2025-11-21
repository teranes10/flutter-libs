import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TList<T, K> extends StatefulWidget with TListMixin<T, K> {
  final ListItemBuilder<T, K> itemBuilder;
  final TListTheme? theme;

  // List configuration
  @override
  final List<T>? items;
  @override
  final int? itemsPerPage;
  @override
  final String? search;
  @override
  final int? searchDelay;
  @override
  final TLoadListener<T>? onLoad;
  @override
  final ItemKeyAccessor<T, K>? itemKey;
  @override
  final TListController<T, K>? controller;

  // Scroll configuration
  final ScrollController? horizontalScrollController;
  final ScrollController? scrollController;
  final VoidCallback? onScrollEnd;
  final double scrollEndThreshold;
  final ValueNotifier<double>? scrollPositionNotifier;
  final ValueChanged<double>? onScrollPositionChanged;

  // Auto items per page
  final bool autoItemsPerPage;

  // List card
  final TListCardTheme? cardTheme;
  final ItemTextAccessor<T>? itemTitle;
  final ItemTextAccessor<T>? itemSubTitle;
  final ItemTextAccessor<T>? itemImageUrl;
  final ListItemTap<T, K>? onTap;

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
    // Scroll
    this.horizontalScrollController,
    this.scrollController,
    this.onScrollEnd,
    this.scrollEndThreshold = 0.0,
    this.scrollPositionNotifier,
    this.onScrollPositionChanged,
    // Auto
    this.autoItemsPerPage = true,
    // List card
    this.cardTheme,
    ItemTextAccessor<T>? itemTitle,
    this.itemSubTitle,
    this.itemImageUrl,
    this.onTap,
    ListItemBuilder<T, K>? itemBuilder,
  })  : itemTitle = itemTitle ?? defaultItemTitle,
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
      final controller = TListScope.of<T, K>(ctx).controller;

      TListCard toListCard(TListItem<T, K> item) {
        return TListCard(
          title: itemTitle?.call(item.data) ?? '',
          subTitle: itemSubTitle?.call(item.data),
          imageUrl: itemImageUrl?.call(item.data),
          isSelected: item.isSelected,
          isExpanded: item.isExpanded,
          level: item.level,
          theme: theme,
          multiple: controller.isMultiSelect,
          onTap: () => onTap?.call(item),
          children: item.children?.map((child) => toListCard(child)).toList(),
        );
      }

      return toListCard(item);
    };
  }

  @override
  State<TList<T, K>> createState() => _TListState<T, K>();
}

class _TListState<T, K> extends State<TList<T, K>> with SingleTickerProviderStateMixin, TListStateMixin<T, K, TList<T, K>> {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  late ScrollController _horizontalScrollController;
  bool _scrollControllerOwned = false;
  bool _horizontalScrollControllerOwned = false;

  TListTheme get wTheme => widget.theme ?? context.theme.listTheme;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: wTheme.animationDuration);

    _scrollController = widget.scrollController ?? ScrollController();
    _scrollControllerOwned = widget.scrollController == null;

    _horizontalScrollController = widget.horizontalScrollController ?? ScrollController();
    _horizontalScrollControllerOwned = widget.horizontalScrollController == null;

    if (!wTheme.shrinkWrap) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void didUpdateWidget(TList<T, K> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle scroll controller changes
    if (oldWidget.scrollController != widget.scrollController) {
      if (!wTheme.shrinkWrap) {
        _scrollController.removeListener(_onScroll);
      }

      if (_scrollControllerOwned) {
        _scrollController.dispose();
      }

      _scrollController = widget.scrollController ?? ScrollController();
      _scrollControllerOwned = widget.scrollController == null;

      if (!wTheme.shrinkWrap) {
        _scrollController.addListener(_onScroll);
      }
    }

    // Handle horizontal scroll controller changes
    if (oldWidget.horizontalScrollController != widget.horizontalScrollController) {
      if (_horizontalScrollControllerOwned) {
        _horizontalScrollController.dispose();
      }

      _horizontalScrollController = widget.horizontalScrollController ?? ScrollController();
      _horizontalScrollControllerOwned = widget.horizontalScrollController == null;
    }

    // Handle theme animation duration changes
    if (oldWidget.theme?.animationDuration != widget.theme?.animationDuration) {
      _animationController.duration = wTheme.animationDuration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();

    if (!wTheme.shrinkWrap) {
      _scrollController.removeListener(_onScroll);
    }

    if (_scrollControllerOwned) {
      _scrollController.dispose();
    }

    if (_horizontalScrollControllerOwned) {
      _horizontalScrollController.dispose();
    }

    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final scrollPosition = position.pixels / position.maxScrollExtent;

    widget.scrollPositionNotifier?.value = scrollPosition;
    widget.onScrollPositionChanged?.call(scrollPosition);

    // Handle scroll end
    if (widget.onScrollEnd != null || wTheme.infiniteScroll == true) {
      final threshold = widget.scrollEndThreshold;
      if (position.pixels >= position.maxScrollExtent - threshold) {
        widget.onScrollEnd?.call();
        if (wTheme.infiniteScroll == true) {
          listController.handleLoadMore();
        }
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
            if ((oldState == null || oldState.displayItems.isEmpty) && state.displayItems.isNotEmpty && !_animationController.isAnimating) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _animationController.reset();
                  _animationController.forward();
                }
              });
            }

            return wTheme.buildListView<T, K>(
              context: context,
              items: state.displayItems,
              itemBuilder: widget.itemBuilder,
              animationController: _animationController,
              listController: listController,
              scrollController: _scrollController,
              horizontalScrollController: _horizontalScrollController,
              loading: state.loading,
              hasError: state.error != null,
              error: state.error,
              hasMoreItems: state.hasMoreItems,
              height: _calculateHeight(state),
            );
          },
        );
      }),
    );
  }

  double? _calculateHeight(TListState<T, K> state) {
    if (providedItemsPerPage > 0 && state.hasMoreItems) {
      return providedItemsPerPage * wTheme.itemBaseHeight;
    }
    return null;
  }

  double? _previousHeight;
  int? _resolvedItemsPerPage;

  void _handleAutoItemsPerPage(BoxConstraints constraints) {
    if (providedItemsPerPage > 0) {
      if (providedItemsPerPage != _resolvedItemsPerPage) {
        _resolvedItemsPerPage = providedItemsPerPage;
        _updateItemsPerPage(providedItemsPerPage);
      }
    } else if (constraints.maxHeight.isFinite) {
      final maxHeight = constraints.maxHeight;
      final itemHeight = wTheme.itemBaseHeight;

      if (maxHeight <= 0 || itemHeight <= 0) return;
      if (_previousHeight != null && _previousHeight! > maxHeight) return;

      final count = (maxHeight / itemHeight).floor().clamp(1, 100);
      if (_resolvedItemsPerPage != count) {
        _previousHeight = maxHeight;
        _resolvedItemsPerPage = count;
        _updateItemsPerPage(count);
      }
    } else if (listController.itemsPerPage == 0) {
      _updateItemsPerPage(10);
    }
  }

  void _updateItemsPerPage(int value) {
    if (listController.isEmpty && !listController.isLoading) {
      if (listController.itemsPerPage != value) {
        listController.handleItemsPerPageChange(value);
      } else {
        listController.handleRefresh();
      }
    }
  }
}
