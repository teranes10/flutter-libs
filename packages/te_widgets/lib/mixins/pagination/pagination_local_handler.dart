import 'package:te_widgets/mixins/pagination/pagination_config.dart';

class TPaginationLocalHandler<T> implements TPaginationHandler<T> {
  final TPaginationFilterHelper<T> _filterHelper;

  TPaginationLocalHandler({required TPaginationFilterHelper<T> filterHelper}) : _filterHelper = filterHelper;

  @override
  TPaginationState<T> handlePageChange(TPaginationState<T> state, int page) {
    if (page <= 0 || page > state.totalPages) return state;

    final newState = state.copyWith(currentPage: page);
    return _applyLocalPagination(newState);
  }

  @override
  TPaginationState<T> handleItemsPerPageChange(TPaginationState<T> state, int itemsPerPage) {
    final newState = state.copyWith(
      currentItemsPerPage: itemsPerPage,
      currentPage: 1,
    );
    return _applyLocalPagination(newState);
  }

  @override
  TPaginationState<T> handleSearchChange(TPaginationState<T> state, String search) {
    final newState = state.copyWith(
      search: search,
      currentPage: 1,
    );
    return _applyLocalPagination(newState);
  }

  @override
  TPaginationState<T> handleRefresh(TPaginationState<T> state) {
    final newState = state.copyWith(currentPage: 1);
    return _applyLocalPagination(newState);
  }

  @override
  TPaginationState<T> handleLoadMore(TPaginationState<T> state) {
    if (!state.hasMoreItems) return state;

    final nextPage = state.currentPage + 1;
    final newState = state.copyWith(currentPage: nextPage);
    return _applyLocalPagination(newState, append: true);
  }

  TPaginationState<T> _applyLocalPagination(TPaginationState<T> state, {bool append = false}) {
    final filteredItems = _filterHelper.filterItems(state.items, state.search);
    final totalItems = filteredItems.length;

    List<T> paginatedItems;
    if (append && state.paginatedItems.isNotEmpty) {
      final startIndex = state.paginatedItems.length;
      final endIndex = (startIndex + state.currentItemsPerPage).clamp(0, filteredItems.length);
      paginatedItems = [...state.paginatedItems, ...filteredItems.sublist(startIndex, endIndex)];
    } else {
      final startIndex = (state.currentPage - 1) * state.currentItemsPerPage;
      final endIndex = (startIndex + state.currentItemsPerPage).clamp(0, filteredItems.length);
      paginatedItems = filteredItems.sublist(startIndex, endIndex);
    }

    final hasMoreItems = paginatedItems.length < totalItems;

    return state.copyWith(
      paginatedItems: paginatedItems,
      totalItems: totalItems,
      hasMoreItems: hasMoreItems,
    );
  }

  @override
  void dispose() {
    // Nothing to dispose for local handler
  }
}
