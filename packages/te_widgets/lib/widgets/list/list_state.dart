import 'dart:collection';

class TListState<T, K> {
  final LinkedHashSet<K> selectedKeys;
  final LinkedHashSet<K> expandedKeys;
  final List<TListItem<T, K>> displayItems;
  final int page;
  final int itemsPerPage;
  final int totalItems;
  final bool loading;
  final bool hasMoreItems;
  final String search;
  final TListError? error;

  const TListState({
    required this.selectedKeys,
    required this.expandedKeys,
    required this.displayItems,
    required this.page,
    required this.itemsPerPage,
    required this.totalItems,
    required this.loading,
    required this.hasMoreItems,
    required this.search,
    this.error,
  });

  @override
  String toString() {
    return 'TListState(page: $page, itemsPerPage: $itemsPerPage, total: $totalItems,'
        'displayed: ${displayItems.length}, selected: ${selectedKeys.length}, expanded: ${expandedKeys.length}, '
        '\n\tloading: $loading, hasMoreItems: $hasMoreItems, search: $search)';
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
  final bool isSelected;
  final bool isExpanded;
  final List<TListItem<T, K>>? children;
  final int level;

  const TListItem({
    required this.key,
    required this.data,
    this.isSelected = false,
    this.isExpanded = false,
    this.children,
    this.level = 0,
  });

  bool get hasChildren => children != null && children!.isNotEmpty;
  int get childCount => children?.length ?? 0;

  TListItem<T, K> copyWith({
    T? data,
    bool? isSelected,
    bool? isExpanded,
    List<TListItem<T, K>>? children,
  }) {
    return TListItem<T, K>(
      key: this.key,
      data: data ?? this.data,
      isSelected: isSelected ?? this.isSelected,
      isExpanded: isExpanded ?? this.isExpanded,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TListItem<T, K> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() {
    return 'TListItem(data: $data, selected: $isSelected, expanded: $isExpanded, children: ${children?.length ?? 0})';
  }
}
