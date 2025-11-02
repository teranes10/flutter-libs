import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'list_controller_expansion.dart';
part 'list_controller_items.dart';
part 'list_controller_pagination.dart';
part 'list_controller_selection.dart';

class TListController<T, K> extends ValueNotifier<TListState<T, K>> {
  final TDebouncer _debouncer;
  final bool _isServerSide;
  final TSearchFilter<T> filter;
  final ItemToString<T> itemToString;
  final ItemKeyAccessor<T, K> itemKey;
  final ItemChildrenAccessor<T>? itemChildren;
  final ListItemFactory<T, K> itemFactory;
  final TLoadListener<T>? onLoad;

  int _requestId = 0;
  final Set<int> _activeRequests = {};
  final Map<K, T> _itemsMap = {};
  final List<T> _localPaginationItems = [];

  TListController({
    List<T> items = const [],
    int itemsPerPage = 0,
    String search = '',
    int? searchDelay,
    TSelectionMode selectionMode = TSelectionMode.none,
    TExpansionMode expansionMode = TExpansionMode.none,
    this.onLoad,
    ItemKeyAccessor<T, K>? itemKey,
    ItemToString<T>? itemToString,
    ListItemFactory<T, K>? itemFactory,
    this.itemChildren,
  })  : _isServerSide = onLoad != null,
        _debouncer = TDebouncer(milliseconds: searchDelay ?? (onLoad != null ? 2500 : 750)),
        itemToString = itemToString ?? _defaultItemToString,
        itemKey = itemKey ?? _defaultItemKey,
        itemFactory = itemFactory ?? _defaultItemFactory(itemKey ?? _defaultItemKey, itemChildren),
        filter = TSearchFilter(itemToString: itemToString ?? _defaultItemToString),
        super(
          TListState<T, K>(
            displayItems: const [],
            selectedKeys: LinkedHashSet<K>(),
            expandedKeys: LinkedHashSet<K>(),
            page: 1,
            itemsPerPage: itemsPerPage,
            totalItems: items.length,
            loading: false,
            hasMoreItems: true,
            search: search,
            selectionMode: selectionMode,
            expansionMode: expansionMode,
            error: null,
          ),
        ) {
    assert(
      allowedKeyTypes.contains(K),
      'Invalid key type <$K>. '
      'Allowed key types are: String, int, double, num, bool.',
    );

    assert(
      itemKey != null || (allowedKeyTypes.contains(T) && K == T) || K == int,
      'If `itemKey` is not provided, generic type K must be int.',
    );

    updateItems(items);
  }
  static const allowedKeyTypes = [String, int, double, num, bool];

  static K _defaultItemKey<T, K>(T item) {
    if (allowedKeyTypes.contains(T)) {
      return item as K;
    }

    return identityHashCode(item) as K;
  }

  static String _defaultItemToString<T>(T item) => item.toString();

  static ListItemFactory<T, K> _defaultItemFactory<T, K>(
    ItemKeyAccessor<T, K> itemKey,
    ItemChildrenAccessor<T>? itemChildren, [
    int level = 0,
  ]) {
    return (item) => TListItem<T, K>(
          key: itemKey(item),
          data: item,
          level: level,
          children: itemChildren?.call(item)?.map((child) => _defaultItemFactory(itemKey, itemChildren, level + 1)(child)).toList(),
        );
  }

  // Getters
  bool get mounted => hasListeners;
  bool get isServerSide => _isServerSide;
  bool get isHierarchical => itemChildren != null;
  bool get hasError => value.error != null;
  bool get isLoading => value.loading;
  bool get isEmpty => value.displayItems.isEmpty;
  bool get isNotEmpty => value.displayItems.isNotEmpty;
  List<K> get displayItemKeys => value.displayItems.map((x) => x.key).toList();

  void clearError() {
    if (value.error != null) {
      updateState(who: 'clearError', error: null);
    }
  }

  void cancelPendingOperations() {
    _debouncer.cancel();
    _activeRequests.clear();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    cancelPendingOperations();
    super.dispose();
  }

  void updateState({
    required String who,
    LinkedHashSet<K>? selectedKeys,
    LinkedHashSet<K>? expandedKeys,
    List<TListItem<T, K>>? displayItems,
    int? page,
    int? itemsPerPage,
    int? totalItems,
    bool? loading,
    bool? hasMoreItems,
    String? search,
    TSelectionMode? selectionMode,
    TExpansionMode? expansionMode,
    TListError? error,
  }) {
    var effectiveSelectedKeys = selectedKeys ?? value.selectedKeys;
    var effectiveExpandedKeys = expandedKeys ?? value.expandedKeys;
    var effectiveDisplayItems = displayItems ?? value.displayItems;

    if ((selectable || expandable) && (displayItems != null || selectedKeys != null || expandedKeys != null)) {
      effectiveDisplayItems = _preserveStateOptimized(
        items: effectiveDisplayItems,
        selectedKeys: effectiveSelectedKeys,
        expandedKeys: effectiveExpandedKeys,
      );
    }

    value = TListState<T, K>(
      displayItems: effectiveDisplayItems,
      selectedKeys: effectiveSelectedKeys,
      expandedKeys: effectiveExpandedKeys,
      page: page ?? value.page,
      itemsPerPage: itemsPerPage ?? value.itemsPerPage,
      totalItems: totalItems ?? value.totalItems,
      loading: loading ?? value.loading,
      hasMoreItems: hasMoreItems ?? value.hasMoreItems,
      search: search ?? value.search,
      selectionMode: selectionMode ?? value.selectionMode,
      expansionMode: expansionMode ?? value.expansionMode,
      error: error ?? value.error,
    );

    debugPrint("$who: $value");
  }

  List<TListItem<T, K>> _preserveStateOptimized({
    required List<TListItem<T, K>> items,
    required LinkedHashSet<K> selectedKeys,
    required LinkedHashSet<K> expandedKeys,
  }) {
    if (items.isEmpty) return items;

    return items.map((item) {
      final isSelected = selectedKeys.contains(item.key);
      final isExpanded = expandedKeys.contains(item.key);

      if (item.isSelected == isSelected && item.isExpanded == isExpanded && (item.children == null || item.children!.isEmpty)) {
        return item;
      }

      List<TListItem<T, K>>? updatedChildren;
      if (item.children != null && item.children!.isNotEmpty) {
        updatedChildren = _preserveStateOptimized(
          items: item.children!,
          selectedKeys: selectedKeys,
          expandedKeys: expandedKeys,
        );
      }

      return item.copyWith(
        isSelected: isSelected,
        isExpanded: isExpanded,
        children: updatedChildren,
      );
    }).toList();
  }
}
