import 'package:flutter/material.dart';
import 'dart:async';

typedef TLoadListener<T> = void Function(TLoadOptions<T> options);

class TLoadOptions<T> {
  final int page;
  final int itemsPerPage;
  final String? search;
  final void Function(List<T>, int) callback;

  int get offset => (page - 1) * itemsPerPage;

  const TLoadOptions({
    required this.callback,
    required this.page,
    required this.itemsPerPage,
    this.search,
  });
}

mixin TPaginationMixin<T> {
  List<T>? get items;
  int get itemsPerPage;
  List<int> get itemsPerPageOptions;
  String? get search;
  int get searchDelay;
  bool get loading;
  TLoadListener<T>? get onLoad;
}

mixin TPaginationStateMixin<T, W extends StatefulWidget> on State<W> {
  TPaginationMixin<T> get _widget {
    assert(widget is TPaginationMixin<T>, 'Widget must mix in TPaginationMixin<$T>');
    return widget as TPaginationMixin<T>;
  }

  late List<T> items;
  late int currentPage;
  late int currentItemsPerPage;
  late bool loading;
  late bool serverSideRendering;
  late bool hasMoreItems;

  Timer? _searchDebounceTimer;
  String _currentSearch = '';

  List<T> paginatedItems = [];
  int totalItems = 0;

  // Notifiers for reactive updates
  final ValueNotifier<List<T>> itemsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> hasMoreItemsNotifier = ValueNotifier(true);

  int get totalPages => (totalItems / currentItemsPerPage).ceil();

  int get computedItemsPerPage => totalItems < currentItemsPerPage ? paginatedItems.length : currentItemsPerPage;

  List<int> get computedItemsPerPageOptions {
    final options = <int>{
      computedItemsPerPage,
      totalItems,
      ...List.from(_widget.itemsPerPageOptions),
    };

    return options.where((x) => x <= totalItems).toList()..sort();
  }

  int get _pageStartAt => ((currentPage - 1) * currentItemsPerPage) + 1;

  int get _pageEndAt => (currentPage * currentItemsPerPage).clamp(0, totalItems);

  String get paginationInfo {
    if (totalItems == 0) return 'No entries';
    return 'Showing $_pageStartAt to $_pageEndAt of $totalItems entries';
  }

  @override
  void initState() {
    super.initState();

    items = List.from(_widget.items ?? []);
    currentPage = 1;
    currentItemsPerPage = _widget.itemsPerPage;
    loading = _widget.loading;
    serverSideRendering = _widget.onLoad != null;
    hasMoreItems = true;
    _currentSearch = _widget.search ?? '';

    _loadData();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldMixin = oldWidget as TPaginationMixin<T>;

    if (oldMixin.items != _widget.items) {
      items = List.from(_widget.items ?? []);
      _resetPagination();
      _loadData();
    }

    if (oldMixin.loading != _widget.loading) {
      loading = _widget.loading;
      loadingNotifier.value = loading;
    }

    if (oldMixin.search != _widget.search) {
      _handleSearchChange(_widget.search ?? '');
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    itemsNotifier.dispose();
    loadingNotifier.dispose();
    hasMoreItemsNotifier.dispose();
    super.dispose();
  }

  void _resetPagination() {
    currentPage = 1;
    hasMoreItems = true;
    paginatedItems.clear();
  }

  void _loadData({bool append = false}) {
    if (loading || (!hasMoreItems && append)) return;

    if (serverSideRendering) {
      _setLoading(true);
      _loadDataFromServer((items, totalItems) {
        this.totalItems = totalItems;

        if (append) {
          paginatedItems.addAll(items);
        } else {
          paginatedItems = items;
        }

        // Update hasMoreItems based on loaded data
        hasMoreItems = paginatedItems.length < totalItems;
        hasMoreItemsNotifier.value = hasMoreItems;

        itemsNotifier.value = List.from(paginatedItems);
        _setLoading(false);
      });
    } else {
      totalItems = items.length;

      if (append) {
        // For client-side, we don't typically append, but handle it anyway
        final startIndex = paginatedItems.length;
        final endIndex = (startIndex + currentItemsPerPage).clamp(0, items.length);
        paginatedItems.addAll(items.sublist(startIndex, endIndex));
      } else {
        final startIndex = (currentPage - 1) * currentItemsPerPage;
        final endIndex = (startIndex + currentItemsPerPage).clamp(0, items.length);
        paginatedItems = items.sublist(startIndex, endIndex);
      }

      hasMoreItems = paginatedItems.length < totalItems;
      hasMoreItemsNotifier.value = hasMoreItems;
      itemsNotifier.value = List.from(paginatedItems);
    }
  }

  void _loadDataFromServer(Function(List<T>, int) callback) {
    final options = TLoadOptions<T>(
      page: currentPage,
      itemsPerPage: currentItemsPerPage,
      search: _currentSearch.isEmpty ? null : _currentSearch,
      callback: callback,
    );

    _widget.onLoad?.call(options);
  }

  void _setLoading(bool value) {
    loading = value;
    loadingNotifier.value = value;
    if (mounted) {
      setState(() {});
    }
  }

  void _handleSearchChange(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(Duration(milliseconds: _widget.searchDelay), () {
      if (_currentSearch != query) {
        _currentSearch = query;
        _resetPagination();
        _loadData();
      }
    });
  }

  // Public API methods
  void onPageChanged(int page) {
    if (page <= 0 || page > totalPages) {
      return;
    }

    currentPage = page;
    _loadData();
  }

  void onItemsPerPageChanged(int itemsPerPage) {
    currentItemsPerPage = itemsPerPage;
    _resetPagination();
    _loadData();
  }

  void nextPage() {
    onPageChanged(currentPage + 1);
  }

  void previousPage() {
    onPageChanged(currentPage - 1);
  }

  void loadMore() {
    if (hasMoreItems && !loading) {
      currentPage++;
      _loadData(append: true);
    }
  }

  void refresh() {
    _resetPagination();
    _loadData();
  }

  void onSearchChanged(String query) {
    _handleSearchChange(query);
  }

  // Helper methods for infinite scroll
  void onScrollEnd() {
    loadMore();
  }

  bool shouldLoadMore(ScrollController controller) {
    if (!controller.hasClients) return false;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    const delta = 100.0;

    return currentScroll >= (maxScroll - delta) && hasMoreItems && !loading;
  }
}
