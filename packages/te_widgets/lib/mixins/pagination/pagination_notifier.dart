import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/pagination/pagination_config.dart';
import 'package:te_widgets/mixins/pagination/pagination_local_handler.dart';
import 'package:te_widgets/mixins/pagination/pagination_server_handler.dart';

part 'pagination_notifier_crud_extension.dart';

class TPaginationNotifier<T> extends ChangeNotifier {
  TPaginationState<T> _state;

  late final TPaginationHandler<T> _handler;
  final TPaginationDebounceHelper _debounceHelper;
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
        _isServerSide = onLoad != null,
        _debounceHelper = TPaginationDebounceHelper(delayMilliseconds: searchDelay) {
    _handler = onLoad != null
        ? TPaginationServerHandler<T>(onLoad: onLoad, onStateUpdate: (state) => _updateState(state))
        : TPaginationLocalHandler<T>(filterHelper: TPaginationFilterHelper<T>(itemToString: itemToString));

    searchNotifier.value = _state.search;
    _initializeData();
  }

  // Getters
  TPaginationState<T> get state => _state;
  List<T> get paginatedItems => _state.paginatedItems;
  bool get loading => _state.loading;
  bool get hasMoreItems => _state.hasMoreItems;
  String get search => _state.search;

  // Core Pagination API - ONLY pagination logic here
  void onPageChanged(int page) {
    final newState = _handler.handlePageChange(_state, page);
    _updateState(newState);
  }

  void onItemsPerPageChanged(int itemsPerPage) {
    final newState = _handler.handleItemsPerPageChange(_state, itemsPerPage);
    _updateState(newState);
  }

  void onSearchChanged(String query) {
    _debounceHelper.debounce(() {
      if (_state.search != query) {
        searchNotifier.value = query;
        final newState = _handler.handleSearchChange(_state, query);
        _updateState(newState);
      }
    });
  }

  void nextPage() => onPageChanged(_state.currentPage + 1);
  void previousPage() => onPageChanged(_state.currentPage - 1);

  void loadMore() {
    final newState = _handler.handleLoadMore(_state);
    _updateState(newState);
  }

  void refresh() {
    final newState = _handler.handleRefresh(_state);
    _updateState(newState);
  }

  void updateItems(List<T> newItems) {
    if (_isServerSide) return;
    _state = _state.copyWith(items: newItems);
    final newState = _handler.handleRefresh(_state);
    _updateState(newState);
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

  // Protected methods for extension
  void updateState(TPaginationState<T> newState) => _updateState(newState);
  TPaginationState<T> get currentState => _state;
  TPaginationHandler<T> get handler => _handler;
  bool get isServerSide => _isServerSide;

  // Private methods
  void _initializeData() {
    final newState = _handler.handleRefresh(_state);
    _updateState(newState);
  }

  void _updateState(TPaginationState<T> newState) {
    _state = newState;
    _updateNotifiers();
  }

  void _updateNotifiers() {
    itemsNotifier.value = List.from(_state.paginatedItems);
    loadingNotifier.value = _state.loading;
    hasMoreItemsNotifier.value = _state.hasMoreItems;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceHelper.dispose();
    _handler.dispose();
    itemsNotifier.dispose();
    loadingNotifier.dispose();
    hasMoreItemsNotifier.dispose();
    searchNotifier.dispose();
    super.dispose();
  }
}
