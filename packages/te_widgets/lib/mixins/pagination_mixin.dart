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
}

mixin TPaginationMixin<T> {
  List<T>? get items;
  int get itemsPerPage;
  List<int> get itemsPerPageOptions;
  String? get search;
  int get searchDelay;
  bool get loading;
  TLoadListener<T>? get onLoad;
}

mixin TPaginationStateMixin<T, W extends StatefulWidget> on State<W> {
  TPaginationMixin<T> get _widget {
    assert(widget is TPaginationMixin<T>, 'Widget must mix in TPaginationMixin<$T>');
    return widget as TPaginationMixin<T>;
  }

  late List<T> items;
  late int currentPage;
  late int currentItemsPerPage;
  late bool loading;
  late bool serverSideRendering;

  List<T> paginatedItems = [];

  int totalItems = 0;

  int get totalPages => (totalItems / currentItemsPerPage).ceil();

  int get computedItemsPerPage => totalItems < currentItemsPerPage ? paginatedItems.length : currentItemsPerPage;

  List<int> get computedItemsPerPageOptions {
    final options = <int>{
      computedItemsPerPage,
      totalItems,
      ...List.from(_widget.itemsPerPageOptions),
    };

    return options.where((x) => x <= totalItems).toList()..sort();
  }

  int get _pageStartAt => ((currentPage - 1) * currentItemsPerPage) + 1;

  int get _pageEndAt => (currentPage * currentItemsPerPage).clamp(0, totalItems);

  String get paginationInfo {
    if (totalItems == 0) return 'No entries';
    return 'Showing $_pageStartAt to $_pageEndAt of $totalItems entries';
  }

  @override
  void initState() {
    super.initState();

    items = List.from(_widget.items ?? []);
    currentPage = 1;
    currentItemsPerPage = _widget.itemsPerPage;
    loading = _widget.loading;
    serverSideRendering = _widget.onLoad != null;

    _loadData();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldMixin = oldWidget as TPaginationMixin<T>;

    if (oldMixin.items != _widget.items) {
      items = List.from(_widget.items ?? []);
      _loadData();
    }

    if (oldMixin.loading != _widget.loading) {
      loading = _widget.loading;
    }
  }

  void _loadData() {
    if (serverSideRendering) {
      loading = true;
      _loadDataFromServer((items, totalItems) {
        this.totalItems = totalItems;
        paginatedItems = items;
        setState(() {
          loading = false;
        });
      });
    } else {
      totalItems = items.length;
      final startIndex = (currentPage - 1) * currentItemsPerPage;
      final endIndex = (startIndex + currentItemsPerPage).clamp(0, items.length);
      paginatedItems = items.sublist(startIndex, endIndex);
    }
  }

  void _loadDataFromServer(Function(List<T>, int) callback) {
    final options = TLoadOptions<T>(
      page: currentPage,
      itemsPerPage: currentItemsPerPage,
      search: _widget.search,
      callback: callback,
    );

    _widget.onLoad?.call(options);
  }

  void onPageChanged(int page) {
    if (page <= 0 || page > totalPages) {
      return;
    }

    setState(() {
      currentPage = page;
    });

    _loadData();
  }

  void onItemsPerPageChanged(int itemsPerPage) {
    setState(() {
      currentItemsPerPage = itemsPerPage;
      currentPage = 1;
    });

    _loadData();
  }

  void nextPage() {
    onPageChanged(currentPage + 1);
  }
}
