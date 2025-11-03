part of 'list_controller.dart';

extension TListControllerPagination<T, K> on TListController<T, K> {
  int get page => value.page;
  int get itemsPerPage => value.itemsPerPage;
  int get totalItems => value.totalItems;
  int get totalPages => value.totalPages;
  int get totalDisplayItems => value.displayItems.length;
  int get computedItemsPerPage => totalItems < itemsPerPage ? totalItems : itemsPerPage;
  int get pageStartedAt => totalItems == 0 ? 0 : ((page - 1) * itemsPerPage) + 1;
  int get pageEndedAt => (page * itemsPerPage).clamp(0, totalItems);
  bool get canGoToNextPage => page < totalPages;
  bool get canGoToPreviousPage => page > 1;
  bool get isFirstPage => page == 1;
  bool get isLastPage => totalItems == 0 || page == totalPages;
  bool get hasMoreItems => value.hasMoreItems;

  String get paginationInfo {
    if (totalItems == 0) return 'No entries';
    return 'Showing $pageStartedAt to $pageEndedAt of $totalItems entries';
  }

  void goToNextPage() {
    if (canGoToNextPage) handlePageChange(page + 1);
  }

  void goToPreviousPage() {
    if (canGoToPreviousPage) handlePageChange(page - 1);
  }

  void goToFirstPage() => handlePageChange(1);

  void goToLastPage() {
    if (totalPages > 0) handlePageChange(totalPages);
  }

  void handlePageChange(int newPage) {
    if (newPage == page || newPage <= 0 || (totalItems > 0 && newPage > totalPages)) {
      return;
    }
    _executePaginationAction('handlePageChange', page: newPage);
  }

  void handleItemsPerPageChange(int newItemsPerPage) {
    if (newItemsPerPage == itemsPerPage || newItemsPerPage <= 0) return;
    _executePaginationAction('handleItemsPerPageChange', itemsPerPage: newItemsPerPage, page: 1);
  }

  void handleLoadMore() {
    if (!hasMoreItems || isLoading) return;
    _executePaginationAction('handleLoadMore', page: page + 1, append: true);
  }

  void handleRefresh() {
    clearError();
    _executePaginationAction('handleRefresh', page: 1);
  }

  void handleSearchChange(String search) {
    _debouncer.run(() {
      if (value.search != search) {
        _executePaginationAction('handleSearchChange', search: search, page: 1);
      }
    });
  }

  void handleSearchImmediate(String search) {
    _debouncer.cancel();
    if (value.search != search) {
      _executePaginationAction('handleSearchChange', search: search, page: 1);
    }
  }

  List<int> computeItemsPerPageOptions(List<int> options) {
    if (totalItems == 0) return options.where((x) => x > 0).toList()..sort();

    final optionsSet = <int>{
      computedItemsPerPage,
      totalItems,
      ...options,
    };

    return optionsSet.where((x) => x <= totalItems && x > 0).toList()..sort();
  }

  void _executePaginationAction(String who, {int? page, int? itemsPerPage, String? search, bool append = false}) {
    if (isServerSide) {
      _loadData(who: who, page: page, itemsPerPage: itemsPerPage, search: search, append: append);
    } else {
      _applyLocalPagination(
        who: who,
        page: page,
        itemsPerPage: itemsPerPage,
        search: search,
        append: append,
      );
    }
  }

  void _applyLocalPagination({String? who, int? page, int? itemsPerPage, String? search, bool append = false}) {
    final effectiveItems = _localPaginationItems;
    final effectivePage = page ?? value.page;
    final effectiveItemsPerPage = itemsPerPage ?? value.itemsPerPage;
    final effectiveSearch = search ?? value.search;

    final filteredItems = filter.apply(effectiveItems, effectiveSearch);
    final filteredCount = filteredItems.length;

    List<TListItem<T, K>> rawDisplayItems;
    if (append && value.displayItems.isNotEmpty) {
      final startIndex = value.displayItems.length;
      final endIndex = (startIndex + effectiveItemsPerPage).clamp(0, filteredCount);

      if (startIndex < filteredCount) {
        final newItems = filteredItems.sublist(startIndex, endIndex).map((item) => itemFactory(item));
        rawDisplayItems = [...value.displayItems, ...newItems];
      } else {
        rawDisplayItems = value.displayItems;
      }
    } else {
      final startIndex = (effectivePage - 1) * effectiveItemsPerPage;
      final endIndex = (startIndex + effectiveItemsPerPage).clamp(0, filteredCount);

      if (startIndex < filteredCount) {
        rawDisplayItems = filteredItems.sublist(startIndex, endIndex).map((item) => itemFactory(item)).toList();
      } else {
        rawDisplayItems = [];
      }
    }

    updateState(
      who: who ?? '_applyLocalPagination',
      page: effectivePage,
      itemsPerPage: effectiveItemsPerPage,
      search: effectiveSearch,
      displayItems: rawDisplayItems,
      totalItems: filteredCount,
      hasMoreItems: rawDisplayItems.length < filteredCount,
    );
  }

  void _loadData({String? who, int? page, int? itemsPerPage, String? search, bool append = false}) async {
    assert(onLoad != null, "ListControllerError: onLoad is required for server-side rendering.");

    updateState(
      who: '$who _loadData',
      page: page,
      itemsPerPage: itemsPerPage,
      search: search,
      loading: true,
      error: null,
    );

    final currentRequestId = ++_requestId;
    _activeRequests.add(currentRequestId);

    final options = TLoadOptions<T>(
      page: value.page,
      itemsPerPage: value.itemsPerPage,
      search: value.search.isEmpty ? null : value.search,
    );

    try {
      final result = await onLoad!.call(options);

      // Check if this request is still valid
      if (currentRequestId != _requestId) return;

      List<TListItem<T, K>> rawDisplayItems;
      if (append && value.displayItems.isNotEmpty) {
        final newItems = result.items.map((item) => itemFactory(item));
        rawDisplayItems = [...value.displayItems, ...newItems];
      } else {
        rawDisplayItems = result.items.map((item) => itemFactory(item)).toList();
      }

      updateItems(result.items);
      updateState(
        who: '$who _loadData',
        totalItems: result.totalItems,
        displayItems: rawDisplayItems,
        hasMoreItems: rawDisplayItems.length < result.totalItems,
        loading: false,
        error: null,
      );
    } catch (error, stackTrace) {
      if (currentRequestId != _requestId) return;

      updateState(
        who: '$who _loadData',
        loading: false,
        error: TListError(
          message: error.toString(),
          error: error,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      _activeRequests.remove(currentRequestId);
    }
  }
}
