part of 'list_controller.dart';

/// Extension providing pagination functionality for [TListController].
///
/// Handles both client-side and server-side pagination with methods to:
/// - Navigate between pages
/// - Change items per page
/// - Load more items (infinite scroll)
/// - Refresh data
/// - Handle search
///
/// Example:
/// ```dart
/// // Navigate pages
/// controller.goToNextPage();
/// controller.goToFirstPage();
///
/// // Change page size
/// controller.handleItemsPerPageChange(25);
///
/// // Infinite scroll
/// controller.handleLoadMore();
///
/// // Search
/// controller.handleSearchChange('query');
///
/// // Get pagination info
/// print(controller.paginationInfo);
/// // "Showing 1 to 10 of 100 entries"
/// ```
extension TListControllerPagination<T, K> on TListController<T, K> {
  /// The current page number (1-indexed).
  int get page => value.page;

  /// The number of items per page.
  int get itemsPerPage => value.itemsPerPage;

  /// The total number of items.
  int get totalItems => value.totalItems;

  /// The number of items currently displayed.
  int get totalDisplayItems => value.displayItems.length;

  /// The total number of pages.
  int get totalPages => totalItems > 0 ? (totalItems / itemsPerPage).ceil() : 1;

  /// The computed items per page (adjusted for last page).
  int get computedItemsPerPage => totalItems < itemsPerPage ? totalItems : itemsPerPage;

  /// The starting index of the current page.
  int get pageStartedAt => totalItems == 0 ? 0 : ((page - 1) * itemsPerPage) + 1;

  /// The ending index of the current page.
  int get pageEndedAt => (page * itemsPerPage).clamp(0, totalItems);

  /// Whether there is a next page.
  bool get canGoToNextPage => page < totalPages;

  /// Whether there is a previous page.
  bool get canGoToPreviousPage => page > 1;

  /// Whether this is the first page.
  bool get isFirstPage => page == 1;

  /// Whether this is the last page.
  bool get isLastPage => totalItems == 0 || page == totalPages;

  /// Whether there are more items to load.
  bool get hasMoreItems => value.hasMoreItems;

  /// Human-readable pagination information.
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
    if (totalItems == 0) return [];

    return <int>{computedItemsPerPage, ...options}.where((x) => x <= totalItems && x > 0).toList()..sort();
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
    final effectiveItems = localItems;
    final effectivePage = page ?? value.page;
    final effectiveItemsPerPage = itemsPerPage ?? value.itemsPerPage;
    final effectiveSearch = search ?? value.search;

    final filteredItems = _filter.apply(effectiveItems, effectiveSearch);
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
