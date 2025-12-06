import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'list_controller_expansion.dart';
part 'list_controller_items.dart';
part 'list_controller_pagination.dart';
part 'list_controller_selection.dart';

/// A powerful controller for managing list state and operations.
///
/// `TListController` provides comprehensive list management with:
/// - **Pagination**: Client-side and server-side pagination
/// - **Selection**: Single and multiple item selection
/// - **Expansion**: Hierarchical item expansion/collapse
/// - **Search**: Debounced search with filtering
/// - **Reordering**: Drag-and-drop item reordering
/// - **Loading**: Async data loading with error handling
///
/// ## Client-Side Usage
///
/// ```dart
/// final controller = TListController<Product, int>(
///   items: products,
///   itemsPerPage: 10,
///   itemKey: (product) => product.id,
///   selectionMode: TSelectionMode.multiple,
/// );
///
/// // Use with TList
/// TList<Product, int>(
///   controller: controller,
///   itemBuilder: (context, item, index) {
///     return ProductCard(product: item.data);
///   },
/// )
/// ```
///
/// ## Server-Side Usage
///
/// ```dart
/// final controller = TListController<User, int>(
///   itemsPerPage: 25,
///   itemKey: (user) => user.id,
///   onLoad: (options) async {
///     final response = await api.getUsers(
///       page: options.page,
///       limit: options.itemsPerPage,
///       search: options.search,
///     );
///     return TLoadResult(
///       items: response.users,
///       totalItems: response.total,
///     );
///   },
/// );
/// ```
///
/// ## With Selection
///
/// ```dart
/// // Select items
/// controller.selectItem(product);
/// controller.selectAll();
///
/// // Get selected items
/// final selected = controller.selectedItems;
/// print('Selected: ${controller.selectedCount}');
/// ```
///
/// ## With Search
///
/// ```dart
/// controller.handleSearchChange('query');
/// ```
///
/// Type parameters:
/// - [T]: The type of items in the list
/// - [K]: The type of the item key (must be String, int, double, num, or bool)
///
/// See also:
/// - [TList] for the list widget
/// - [TDataTable] for tabular data display
/// - [TListState] for the state model
class TListController<T, K> extends ValueNotifier<TListState<T, K>> {
  final TDebouncer _debouncer;
  final TSearchFilter<T> _filter;

  /// Whether this controller uses server-side data loading.
  final bool isServerSide;

  /// Function to convert an item to a string for search filtering.
  final ItemToString<T> itemToString;

  /// Function to extract a unique key from an item.
  final ItemKeyAccessor<T, K> itemKey;

  /// Function to extract child items for hierarchical lists.
  final ItemChildrenAccessor<T>? itemChildren;

  /// Factory function to create list items.
  final ListItemFactory<T, K> itemFactory;

  /// Callback for loading data from a server.
  final TLoadListener<T>? onLoad;

  /// The selection mode for the list.
  final TSelectionMode selectionMode;

  /// The expansion mode for hierarchical lists.
  final TExpansionMode expansionMode;

  /// Whether items can be reordered.
  final bool reorderable;

  /// Callback fired when items are reordered.
  final void Function(int oldIndex, int newIndex)? onReorder;

  bool _disposed = false;
  int _requestId = 0;
  final Set<int> _activeRequests = {};
  final Map<K, T> _itemsMap = {};
  final List<T> _localPaginationItems = [];

  /// Creates a list controller.
  ///
  /// For client-side lists, provide [items].
  /// For server-side lists, provide [onLoad].
  TListController({
    List<T> items = const [],
    int itemsPerPage = 0,
    String search = '',
    int? searchDelay,
    this.selectionMode = TSelectionMode.none,
    this.expansionMode = TExpansionMode.none,
    this.onLoad,
    ItemKeyAccessor<T, K>? itemKey,
    ItemToString<T>? itemToString,
    ListItemFactory<T, K>? itemFactory,
    this.itemChildren,
    this.reorderable = false,
    this.onReorder,
  })  : isServerSide = onLoad != null,
        _debouncer = TDebouncer(milliseconds: searchDelay ?? (onLoad != null ? 2500 : 750)),
        itemToString = itemToString ?? _defaultItemToString,
        itemKey = itemKey ?? _defaultItemKey,
        itemFactory = itemFactory ?? _defaultItemFactory(itemKey ?? _defaultItemKey, itemChildren),
        _filter = TSearchFilter(itemToString: itemToString ?? _defaultItemToString),
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
  bool get isHierarchical => itemChildren != null;
  bool get hasError => value.error != null;
  bool get isLoading => value.loading;

  void clearError() {
    if (value.error != null) {
      updateState(who: 'clearError', error: null);
    }
  }

  void handleError(TListError error) {
    updateState(who: 'handleError', error: error);
  }

  void cancelPendingOperations() {
    _debouncer.cancel();
    _activeRequests.clear();
  }

  @override
  void dispose() {
    _disposed = true;
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
    if (_disposed) {
      debugPrint('Controller already disposed.');
      return;
    }

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
      error: error ?? value.error,
    );

    //debugPrint("$who: $value");
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
