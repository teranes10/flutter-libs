import 'dart:async';
import 'package:flutter/material.dart';

typedef TLoadListener<T> = void Function(TLoadOptions<T> options);

class TLoadOptions<T> {
  final int page;
  final int itemsPerPage;
  final String? search;
  final void Function(List<T>, int) callback;

  int get offset => (page - 1) * itemsPerPage;

  const TLoadOptions({
    required this.callback,
    required this.page,
    required this.itemsPerPage,
    this.search,
  });

  @override
  String toString() {
    return 'TLoadOptions of $T. page: $page, itemsPerPage: $itemsPerPage, search: $search';
  }
}

class TPaginationState<T> {
  final List<T> items;
  final List<T> paginatedItems;
  final int currentPage;
  final int currentItemsPerPage;
  final int totalItems;
  final bool loading;
  final bool hasMoreItems;
  final String search;

  const TPaginationState({
    required this.items,
    required this.paginatedItems,
    required this.currentPage,
    required this.currentItemsPerPage,
    required this.totalItems,
    required this.loading,
    required this.hasMoreItems,
    required this.search,
  });

  TPaginationState<T> copyWith({
    List<T>? items,
    List<T>? paginatedItems,
    int? currentPage,
    int? currentItemsPerPage,
    int? totalItems,
    bool? loading,
    bool? hasMoreItems,
    String? search,
  }) {
    return TPaginationState<T>(
      items: items ?? this.items,
      paginatedItems: paginatedItems ?? this.paginatedItems,
      currentPage: currentPage ?? this.currentPage,
      currentItemsPerPage: currentItemsPerPage ?? this.currentItemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      loading: loading ?? this.loading,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      search: search ?? this.search,
    );
  }

  int get totalPages => totalItems > 0 ? (totalItems / currentItemsPerPage).ceil() : 1;

  int get computedItemsPerPage => totalItems < currentItemsPerPage ? paginatedItems.length : currentItemsPerPage;

  int get pageStartAt => totalItems == 0 ? 0 : ((currentPage - 1) * currentItemsPerPage) + 1;

  int get pageEndAt => (currentPage * currentItemsPerPage).clamp(0, totalItems);

  String get paginationInfo {
    if (totalItems == 0) return 'No entries';
    return 'Showing $pageStartAt to $pageEndAt of $totalItems entries';
  }
}

class TPaginationFilterHelper<T> {
  final String Function(T)? itemToString;

  const TPaginationFilterHelper({this.itemToString});

  List<T> filterItems(List<T> items, String searchQuery) {
    if (searchQuery.isEmpty) return items;

    final query = searchQuery.toLowerCase();
    return items.where((item) => _itemMatchesQuery(item, query)).toList();
  }

  bool _itemMatchesQuery(T item, String query) {
    final text = itemToString?.call(item) ?? item.toString();
    return text.toLowerCase().contains(query);
  }
}

class TPaginationDebounceHelper {
  Timer? _debounceTimer;
  final int delayMilliseconds;

  TPaginationDebounceHelper({required this.delayMilliseconds});

  void debounce(VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: delayMilliseconds), callback);
  }

  void cancel() {
    _debounceTimer?.cancel();
  }

  void dispose() {
    cancel();
  }
}
