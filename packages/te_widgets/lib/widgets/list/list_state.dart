import 'dart:collection';

class TListState<T, K> {
  final LinkedHashSet<K> selectedKeys;
  final LinkedHashSet<K> expandedKeys;
  final List<TListItem<T, K>> displayItems;
  final int page;
  final int itemsPerPage;
  final int totalItems;
  final bool loading;
  final bool fetching;
  final bool hasMoreItems;
  final String search;
  final TListError? error;

  // Explicitly track row detail expansion and inline item editing separate from tree expansion (expandedKeys)
  final K? expandedDetailKey;
  final K? editingItemKey;

  K? get activeKey => editingItemKey ?? expandedDetailKey;

  final bool isCreatingItem;
  bool get isEditingItem => editingItemKey != null;

  // Cursor pagination fields
  final String? currentCursor;
  final String? nextCursor;
  final List<String> cursorHistory; // Stack of previous cursors for backward navigation

  // Advanced search filters
  final Map<String, dynamic>? advancedSearch;

  final Map<String, dynamic> additional;

  const TListState({
    required this.selectedKeys,
    required this.expandedKeys,
    required this.displayItems,
    required this.page,
    required this.itemsPerPage,
    required this.totalItems,
    required this.loading,
    required this.fetching,
    required this.hasMoreItems,
    required this.search,
    this.error,
    this.expandedDetailKey,
    this.editingItemKey,
    this.isCreatingItem = false,
    this.currentCursor,
    this.nextCursor,
    this.cursorHistory = const [],
    this.advancedSearch,
    this.additional = const {},
  });

  /// Creates a copy of this state with the given fields updated.
  TListState<T, K> copyWith({
    LinkedHashSet<K>? selectedKeys,
    LinkedHashSet<K>? expandedKeys,
    List<TListItem<T, K>>? displayItems,
    int? page,
    int? itemsPerPage,
    int? totalItems,
    bool? loading,
    bool? fetching,
    bool? hasMoreItems,
    String? search,
    TListError? error,
    K? expandedDetailKey,
    K? editingItemKey,
    bool? isCreatingItem,
    String? currentCursor,
    String? nextCursor,
    List<String>? cursorHistory,
    Map<String, dynamic>? advancedSearch,
    Map<String, dynamic>? additional,
  }) {
    return TListState<T, K>(
      selectedKeys: selectedKeys ?? this.selectedKeys,
      expandedKeys: expandedKeys ?? this.expandedKeys,
      displayItems: displayItems ?? this.displayItems,
      page: page ?? this.page,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      loading: loading ?? this.loading,
      fetching: fetching ?? this.fetching,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      search: search ?? this.search,
      error: error ?? this.error,
      expandedDetailKey: expandedDetailKey ?? this.expandedDetailKey,
      editingItemKey: editingItemKey ?? this.editingItemKey,
      isCreatingItem: isCreatingItem ?? this.isCreatingItem,
      currentCursor: currentCursor ?? this.currentCursor,
      nextCursor: nextCursor ?? this.nextCursor,
      cursorHistory: cursorHistory ?? this.cursorHistory,
      advancedSearch: advancedSearch ?? this.advancedSearch,
      additional: additional ?? this.additional,
    );
  }

  @override
  String toString() {
    return 'TListState(page: $page, itemsPerPage: $itemsPerPage, total: $totalItems,'
        'displayed: ${displayItems.length}, selected: ${selectedKeys.length}, expanded: ${expandedKeys.length}, '
        'expandedContentKey: $expandedDetailKey, editingItemKey: $editingItemKey,'
        'loading: $loading, fetching: $fetching, hasMoreItems: $hasMoreItems, search: $search, '
        'isCreatingItem: $isCreatingItem, isEditingItem: $isEditingItem, '
        'nextCursor: $nextCursor, cursorHistory: ${cursorHistory.length})';
  }
}

class TListError {
  final String title;
  final String message;
  final Object error;
  final StackTrace stackTrace;

  const TListError({
    this.title = 'An error occurred',
    required this.message,
    required this.error,
    required this.stackTrace,
  });

  @override
  String toString() => 'TListError: $message';
}

class TListItem<T, K> {
  final K key;
  final T data;
  final K? parentKey;
  final List<K>? childrenKeys;
  final int level;

  const TListItem({
    required this.key,
    required this.data,
    this.parentKey,
    this.childrenKeys,
    this.level = 0,
  });

  bool get hasChildren => childrenKeys != null && childrenKeys!.isNotEmpty;
  int get childCount => childrenKeys?.length ?? 0;

  TListItem<T, K> copyWith({
    T? data,
    K? parentKey,
    List<K>? childrenKeys,
    int? level,
  }) {
    return TListItem<T, K>(
      key: key,
      data: data ?? this.data,
      parentKey: parentKey ?? this.parentKey,
      childrenKeys: childrenKeys ?? this.childrenKeys,
      level: level ?? this.level,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TListItem<T, K> && other.key == key && other.data == data;
  }

  @override
  int get hashCode => Object.hash(key, data);

  @override
  String toString() {
    return 'TListItem(key: $key, level: $level, parent: $parentKey, children: ${childrenKeys?.length ?? 0})';
  }
}
