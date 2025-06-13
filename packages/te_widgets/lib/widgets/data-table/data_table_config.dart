typedef ItemKey<T> = String Function(T item);
typedef DataTableOnLoadListener<T> = void Function(DataTableLoadOptions<T> options);

class DataTableLoadOptions<T> {
  final int page;
  final int itemsPerPage;
  final String? search;
  final void Function(List<T>, int) callback;

  int get offset => (page - 1) * itemsPerPage;

  const DataTableLoadOptions({
    required this.callback,
    required this.page,
    required this.itemsPerPage,
    this.search,
  });
}
