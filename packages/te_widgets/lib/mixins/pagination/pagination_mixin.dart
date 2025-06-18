import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/pagination/pagination_config.dart';
import 'package:te_widgets/mixins/pagination/pagination_notifier.dart';

mixin TPaginationMixin<T> {
  List<T>? get items;
  int get itemsPerPage;
  List<int> get itemsPerPageOptions;
  String? get search;
  int get searchDelay;
  bool get loading;
  TLoadListener<T>? get onLoad;
  String Function(T)? get itemToString => null; // Default to toString()

  // External search notifier for components like data table
  ValueNotifier<String>? get searchNotifier => null;
}

mixin TPaginationStateMixin<T, W extends StatefulWidget> on State<W> {
  TPaginationMixin<T> get _widget {
    assert(widget is TPaginationMixin<T>, 'Widget must mix in TPaginationMixin<$T>');
    return widget as TPaginationMixin<T>;
  }

  late TPaginationNotifier<T> paginationNotifier;

  // Getters for backward compatibility
  List<T> get paginatedItems => paginationNotifier.paginatedItems;
  bool get loading => paginationNotifier.loading;
  bool get hasMoreItems => paginationNotifier.hasMoreItems;
  bool get serverSideRendering => _widget.onLoad != null;
  int get currentPage => paginationNotifier.state.currentPage;
  int get currentItemsPerPage => paginationNotifier.state.currentItemsPerPage;
  int get totalItems => paginationNotifier.state.totalItems;
  int get totalPages => paginationNotifier.state.totalPages;
  String get paginationInfo => paginationNotifier.state.paginationInfo;
  int get computedItemsPerPage => paginationNotifier.state.computedItemsPerPage;

  // Notifiers for reactive updates
  ValueNotifier<List<T>> get itemsNotifier => paginationNotifier.itemsNotifier;
  ValueNotifier<bool> get loadingNotifier => paginationNotifier.loadingNotifier;
  ValueNotifier<bool> get hasMoreItemsNotifier => paginationNotifier.hasMoreItemsNotifier;

  List<int> get computedItemsPerPageOptions => paginationNotifier.getComputedItemsPerPageOptions(_widget.itemsPerPageOptions);

  @override
  void initState() {
    super.initState();

    paginationNotifier = TPaginationNotifier<T>(
      initialItems: _widget.items ?? [],
      itemsPerPage: _widget.itemsPerPage,
      searchDelay: _widget.searchDelay,
      itemToString: _widget.itemToString,
      onLoad: _widget.onLoad,
      initialSearch: _getInitialSearch(),
      initialLoading: _widget.loading,
    );

    // Listen to external search notifier if provided
    _widget.searchNotifier?.addListener(_onExternalSearchChanged);
  }

  String _getInitialSearch() {
    return _widget.searchNotifier?.value ?? _widget.search ?? '';
  }

  void _onExternalSearchChanged() {
    final externalSearch = _widget.searchNotifier?.value ?? '';
    if (paginationNotifier.search != externalSearch) {
      paginationNotifier.onSearchChanged(externalSearch);
    }
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldMixin = oldWidget as TPaginationMixin<T>;

    // Update items if they changed
    if (oldMixin.items != _widget.items) {
      paginationNotifier.updateItems(_widget.items ?? []);
    }

    // Handle external search notifier changes
    if (oldMixin.searchNotifier != _widget.searchNotifier) {
      oldMixin.searchNotifier?.removeListener(_onExternalSearchChanged);
      _widget.searchNotifier?.addListener(_onExternalSearchChanged);
    }

    // Handle search value changes
    if (oldMixin.search != _widget.search) {
      final newSearch = _widget.search ?? '';
      if (paginationNotifier.search != newSearch) {
        paginationNotifier.onSearchChanged(newSearch);
      }
    }
  }

  @override
  void dispose() {
    _widget.searchNotifier?.removeListener(_onExternalSearchChanged);
    paginationNotifier.dispose();
    super.dispose();
  }

  // Public API methods
  void onPageChanged(int page) => paginationNotifier.onPageChanged(page);
  void onItemsPerPageChanged(int itemsPerPage) => paginationNotifier.onItemsPerPageChanged(itemsPerPage);
  void nextPage() => paginationNotifier.nextPage();
  void previousPage() => paginationNotifier.previousPage();
  void loadMore() => paginationNotifier.loadMore();
  void refresh() => paginationNotifier.refresh();
  void onSearchChanged(String query) => paginationNotifier.onSearchChanged(query);
  void onScrollEnd() => paginationNotifier.loadMore();
  bool shouldLoadMore(ScrollController controller) => paginationNotifier.shouldLoadMore(controller);
}
