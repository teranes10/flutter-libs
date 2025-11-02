import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TItemAddPosition { first, last }

enum TSelectionMode { none, single, multiple }

enum TExpansionMode { none, single, multiple }

enum TListInteractionType { none, expand, select }

typedef ItemToString<T> = String Function(T item);
typedef ItemChildrenAccessor<T> = List<T>? Function(T item);
typedef ItemTextAccessor<T> = String Function(T item);
typedef ItemKeyAccessor<T, K> = K Function(T item);
typedef ListItemTap<T, K> = void Function(TListItem<T, K> item);
typedef ListItemFactory<T, K> = TListItem<T, K> Function(T item);
typedef ListItemBuilder<T, K> = Widget Function(BuildContext context, TListItem<T, K> item, int index, bool multiple);
typedef TLoadListener<T> = Future<TLoadResult<T>> Function(TLoadOptions<T> options);

class TLoadOptions<T> {
  final int page;
  final int itemsPerPage;
  final String? search;

  int get offset => (page - 1) * itemsPerPage;
  int get limit => itemsPerPage;

  const TLoadOptions({
    required this.page,
    required this.itemsPerPage,
    this.search,
  });

  TLoadOptions<T> copyWith({
    int? page,
    int? itemsPerPage,
    String? search,
  }) {
    return TLoadOptions<T>(
      page: page ?? this.page,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      search: search ?? this.search,
    );
  }

  @override
  String toString() => 'TLoadOptions<$T>(page: $page, itemsPerPage: $itemsPerPage, search: $search)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TLoadOptions<T> &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          itemsPerPage == other.itemsPerPage &&
          search == other.search;

  @override
  int get hashCode => Object.hash(page, itemsPerPage, search);
}

class TLoadResult<T> {
  final List<T> items;
  final int totalItems;

  const TLoadResult(this.items, this.totalItems);

  TLoadResult<T> copyWith({
    List<T>? items,
    int? totalItems,
  }) {
    return TLoadResult<T>(
      items ?? this.items,
      totalItems ?? this.totalItems,
    );
  }

  @override
  String toString() {
    return 'TLoadResult<$T>(items: ${items.length}, totalItems: $totalItems)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TLoadResult<T> && runtimeType == other.runtimeType && items == other.items && totalItems == other.totalItems;

  @override
  int get hashCode => Object.hash(items, totalItems);
}
