import 'package:te_widgets/mixins/pagination/pagination_config.dart';

class TPaginationLocalHandler<T> {
  final TPaginationFilterHelper<T> filterHelper;

  const TPaginationLocalHandler({required this.filterHelper});

  TPaginationState<T> handlePagination(
    TPaginationState<T> currentState,
    List<T> allItems, {
    bool append = false,
  }) {
    // Apply filtering first
    final filteredItems = filterHelper.filterItems(allItems, currentState.search);
    final totalItems = filteredItems.length;

    List<T> paginatedItems;
    if (append && currentState.paginatedItems.isNotEmpty) {
      // For infinite scroll - append new items
      final startIndex = currentState.paginatedItems.length;
      final endIndex = (startIndex + currentState.currentItemsPerPage).clamp(0, filteredItems.length);
      paginatedItems = [...currentState.paginatedItems, ...filteredItems.sublist(startIndex, endIndex)];
    } else {
      // Regular pagination
      final startIndex = (currentState.currentPage - 1) * currentState.currentItemsPerPage;
      final endIndex = (startIndex + currentState.currentItemsPerPage).clamp(0, filteredItems.length);
      paginatedItems = filteredItems.sublist(startIndex, endIndex);
    }

    final hasMoreItems = paginatedItems.length < totalItems;

    return currentState.copyWith(
      items: allItems,
      paginatedItems: paginatedItems,
      totalItems: totalItems,
      hasMoreItems: hasMoreItems,
    );
  }
}

class TPaginationServerHandler<T> {
  TPaginationState<T> handleServerResponse(TPaginationState<T> currentState, List<T> newItems, int serverTotalItems, {bool append = false}) {
    List<T> paginatedItems;
    if (append && currentState.paginatedItems.isNotEmpty) {
      paginatedItems = [...currentState.paginatedItems, ...newItems];
    } else {
      paginatedItems = newItems;
    }

    final hasMoreItems = paginatedItems.length < serverTotalItems;

    return currentState.copyWith(
      paginatedItems: paginatedItems,
      totalItems: serverTotalItems,
      hasMoreItems: hasMoreItems,
      loading: false,
    );
  }

  TPaginationState<T> setLoading(TPaginationState<T> currentState, bool loading) {
    return currentState.copyWith(loading: loading);
  }
}
