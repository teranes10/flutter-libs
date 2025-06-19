import 'package:te_widgets/mixins/pagination/pagination_config.dart';

class TPaginationServerHandler<T> implements TPaginationHandler<T> {
  final TLoadListener<T> _onLoad;
  final Function(TPaginationState<T>) _onStateUpdate;

  TPaginationServerHandler({
    required TLoadListener<T> onLoad,
    required Function(TPaginationState<T>) onStateUpdate,
  })  : _onLoad = onLoad,
        _onStateUpdate = onStateUpdate;

  @override
  TPaginationState<T> handlePageChange(TPaginationState<T> state, int page) {
    if (page <= 0 || (state.totalItems > 0 && page > state.totalPages)) return state;

    final newState = state.copyWith(currentPage: page, loading: true);
    _loadData(newState);
    return newState;
  }

  @override
  TPaginationState<T> handleItemsPerPageChange(TPaginationState<T> state, int itemsPerPage) {
    final newState = state.copyWith(
      currentItemsPerPage: itemsPerPage,
      currentPage: 1,
      loading: true,
    );
    _loadData(newState);
    return newState;
  }

  @override
  TPaginationState<T> handleSearchChange(TPaginationState<T> state, String search) {
    final newState = state.copyWith(
      search: search,
      currentPage: 1,
      loading: true,
    );
    _loadData(newState);
    return newState;
  }

  @override
  TPaginationState<T> handleRefresh(TPaginationState<T> state) {
    final newState = state.copyWith(currentPage: 1, loading: true);
    _loadData(newState);
    return newState;
  }

  @override
  TPaginationState<T> handleLoadMore(TPaginationState<T> state) {
    if (!state.hasMoreItems || state.loading) return state;

    final newState = state.copyWith(
      currentPage: state.currentPage + 1,
      loading: true,
    );
    _loadData(newState, append: true);
    return newState;
  }

  void _loadData(TPaginationState<T> state, {bool append = false}) {
    final options = TLoadOptions<T>(
      page: state.currentPage,
      itemsPerPage: state.currentItemsPerPage,
      search: state.search.isEmpty ? null : state.search,
      callback: (items, totalItems) {
        List<T> paginatedItems;
        if (append && state.paginatedItems.isNotEmpty) {
          paginatedItems = [...state.paginatedItems, ...items];
        } else {
          paginatedItems = items;
        }

        final hasMoreItems = paginatedItems.length < totalItems;

        final updatedState = state.copyWith(
          paginatedItems: paginatedItems,
          totalItems: totalItems,
          hasMoreItems: hasMoreItems,
          loading: false,
        );

        _onStateUpdate(updatedState);
      },
    );

    _onLoad(options);
  }

  @override
  void dispose() {
    // Nothing to dispose for server handler
  }
}
