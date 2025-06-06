import 'package:te_widgets/widgets/table/table_configs.dart';

typedef ItemKey<T> = String Function(T item);
typedef DataTableOnLoadListener<T> = void Function(DataTableLoadOptions<T> options);
typedef DataTableInitializeCallback<T> = void Function(DataTableContext<T> context);

class DataTableLoadOptions<T> {
  final int page;
  final int itemsPerPage;
  final String? search;
  final Map<String, dynamic>? params;

  const DataTableLoadOptions({
    required this.page,
    required this.itemsPerPage,
    this.search,
    this.params,
  });
}

class DataTableContext<T> {
  final bool Function() isServerSideRendering;
  final void Function(List<TTableHeader<T>>) setHeaders;
  final void Function(DataTableOnLoadListener<T>) setOnLoadListener;
  final List<T> Function() getItems;
  final void Function(List<T>) setItems;
  final void Function(T) addItem;
  final void Function(int, T) updateItem;
  final void Function(int) removeItem;
  final void Function() notifyDataSetChanged;
  final void Function(bool) setLoading;

  const DataTableContext({
    required this.isServerSideRendering,
    required this.setHeaders,
    required this.setOnLoadListener,
    required this.getItems,
    required this.setItems,
    required this.addItem,
    required this.updateItem,
    required this.removeItem,
    required this.notifyDataSetChanged,
    required this.setLoading,
  });
}
