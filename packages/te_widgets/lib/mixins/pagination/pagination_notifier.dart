import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/pagination/pagination_config.dart';
import 'package:te_widgets/mixins/pagination/pagination_handlers.dart';

class TPaginationNotifier<T> extends ChangeNotifier {
  TPaginationState<T> _state;
  final TPaginationLocalHandler<T> _localHandler;
  final TPaginationServerHandler<T> _serverHandler;
  final TPaginationDebounceHelper _debounceHelper;
  final TLoadListener<T>? _onLoad;
  final bool _isServerSide;

  // Value notifiers for reactive updates
  final ValueNotifier<List<T>> itemsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> hasMoreItemsNotifier = ValueNotifier(true);
  final ValueNotifier<String> searchNotifier = ValueNotifier('');

  TPaginationNotifier({
    required List<T> initialItems,
    required int itemsPerPage,
    required int searchDelay,
    required String Function(T)? itemToString,
    TLoadListener<T>? onLoad,
    String? initialSearch,
    bool initialLoading = false,
  })  : _state = TPaginationState<T>(
          items: initialItems,
          paginatedItems: [],
          currentPage: 1,
          currentItemsPerPage: itemsPerPage,
          totalItems: 0,
          loading: initialLoading,
          hasMoreItems: true,
          search: initialSearch ?? '',
        ),
        _localHandler = TPaginationLocalHandler<T>(filterHelper: TPaginationFilterHelper<T>(itemToString: itemToString)),
        _serverHandler = TPaginationServerHandler<T>(),
        _debounceHelper = TPaginationDebounceHelper(delayMilliseconds: searchDelay),
        _onLoad = onLoad,
        _isServerSide = onLoad != null {
    searchNotifier.value = _state.search;
    _loadData();
  }

  TPaginationState<T> get state => _state;
  List<T> get paginatedItems => _state.paginatedItems;
  bool get loading => _state.loading;
  bool get hasMoreItems => _state.hasMoreItems;
  String get search => _state.search;

  void updateItems(List<T> newItems) {
    if (_isServerSide) return; // Server-side items are handled by onLoad callback

    _state = _state.copyWith(items: newItems);
    _resetPagination();
    _loadData();
  }

  void onPageChanged(int page) {
    if (page <= 0 || page > _state.totalPages) return;

    _state = _state.copyWith(currentPage: page);
    _loadData();
  }

  void onItemsPerPageChanged(int itemsPerPage) {
    _state = _state.copyWith(currentItemsPerPage: itemsPerPage);
    _resetPagination();
    _loadData();
  }

  void onSearchChanged(String query) {
    _debounceHelper.debounce(() {
      if (_state.search != query) {
        _state = _state.copyWith(search: query);
        searchNotifier.value = query;
        _resetPagination();
        _loadData();
      }
    });
  }

  void nextPage() {
    onPageChanged(_state.currentPage + 1);
  }

  void previousPage() {
    onPageChanged(_state.currentPage - 1);
  }

  void loadMore() {
    if (_state.hasMoreItems && !_state.loading) {
      _state = _state.copyWith(currentPage: _state.currentPage + 1);
      _loadData(append: true);
    }
  }

  void refresh() {
    _resetPagination();
    _loadData();
  }

  void _resetPagination() {
    _state = _state.copyWith(
      currentPage: 1,
      hasMoreItems: true,
      paginatedItems: [],
    );
  }

  void _loadData({bool append = false}) {
    if (_state.loading || (!_state.hasMoreItems && append)) return;

    if (_isServerSide) {
      _state = _serverHandler.setLoading(_state, true);
      loadingNotifier.value = true;

      final options = TLoadOptions<T>(
        page: _state.currentPage,
        itemsPerPage: _state.currentItemsPerPage,
        search: _state.search.isEmpty ? null : _state.search,
        callback: (items, totalItems) {
          _state = _serverHandler.handleServerResponse(_state, items, totalItems, append: append);
          _updateNotifiers();
        },
      );

      _onLoad?.call(options);
    } else {
      _state = _localHandler.handlePagination(_state, _state.items, append: append);
      _updateNotifiers();
    }
  }

  void _updateNotifiers() {
    itemsNotifier.value = List.from(_state.paginatedItems);
    loadingNotifier.value = _state.loading;
    hasMoreItemsNotifier.value = _state.hasMoreItems;
    notifyListeners();
  }

  List<int> getComputedItemsPerPageOptions(List<int> options) {
    final optionsSet = <int>{
      _state.computedItemsPerPage,
      _state.totalItems,
      ...options,
    };

    return optionsSet.where((x) => x <= _state.totalItems && x > 0).toList()..sort();
  }

  bool shouldLoadMore(ScrollController controller) {
    if (!controller.hasClients) return false;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    const delta = 100.0;

    return currentScroll >= (maxScroll - delta) && _state.hasMoreItems && !_state.loading;
  }

  @override
  void dispose() {
    _debounceHelper.dispose();
    itemsNotifier.dispose();
    loadingNotifier.dispose();
    hasMoreItemsNotifier.dispose();
    searchNotifier.dispose();
    super.dispose();
  }
}
