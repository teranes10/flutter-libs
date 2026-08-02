import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import '../../../extensions/list_x.dart';
import '../../../helpers/debouncer.dart';
import '../../../helpers/search_filter.dart';
import '../list_config.dart';
import '../list_state.dart';

part 'list_controller_expansion.dart';
part 'list_controller_details_expansion.dart';
part 'list_controller_items.dart';
part 'list_controller_pagination.dart';
part 'list_controller_selection.dart';
part 'list_controller_actions.dart';
part 'list_controller_riverpod.dart';

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
///        response.users,
///        response.total,
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

  /// Whether to automatically select the first item when items are loaded.
  final bool autoSelectFirst;

  /// Whether to automatically expand the first item when items are loaded.
  final bool autoExpandFirst;

  bool _disposed = false;
  int _requestId = 0;
  final Set<int> _activeRequests = {};
  final Map<K, TListItem<T, K>> _itemsMap = {};

  // Client-side only: tracks root-level (level == 0) items for local pagination.
  // Never used for server-side lists.
  final List<TListItem<T, K>> _localPaginationItems = [];

  bool _hasAutoSelectedFirst = false;
  bool _hasAutoExpandedFirst = false;

  /// Safely retrieves child items for an item using [itemChildren].
  List<T>? getChildren(T item) {
    final fn = itemChildren;
    if (fn == null) return null;
    return fn(item);
  }

  /// Retrieves all ancestor item keys for a given item key in tree hierarchy.
  List<K> getAncestorsOfKey(K key) {
    final ancestors = <K>[];
    K? current = _itemsMap[key]?.parentKey;
    while (current != null) {
      ancestors.add(current);
      current = _itemsMap[current]?.parentKey;
    }
    return ancestors.reversed.toList();
  }

  /// Retrieves all descendant item keys for a given item key in tree hierarchy.
  Set<K> getDescendantsOfKey(K key) {
    final descendants = <K>{};
    void collect(K parentKey) {
      final item = _itemsMap[parentKey];
      if (item != null && item.hasChildren) {
        for (final childKey in item.childrenKeys!) {
          descendants.add(childKey);
          collect(childKey);
        }
      }
    }

    collect(key);
    return descendants;
  }


  /// The single canonical factory for creating a [TListItem] from raw data.
  ///
  /// Accepts optional [childrenKeys] to override auto-resolution from [itemChildren].
  /// When [childrenKeys] is not provided and [itemChildren] is set, children are resolved automatically.
  TListItem<T, K> itemFactory(
    T data, {
    K? parentKey,
    List<K>? childrenKeys,
    int level = 0,
  }) {
    final resolvedChildrenKeys = childrenKeys ?? (() {
      final children = itemChildren?.call(data);
      return children != null && children.isNotEmpty ? children.map(itemKey).toList() : null;
    })();

    return TListItem<T, K>(
      key: itemKey(data),
      data: data,
      parentKey: parentKey,
      childrenKeys: resolvedChildrenKeys,
      level: level,
    );
  }

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
    this.itemChildren,
    this.reorderable = false,
    this.onReorder,
    this.autoSelectFirst = false,
    this.autoExpandFirst = false,
    Iterable<K>? initialSelectedKeys,
    Iterable<K>? initialExpandedKeys,
    bool loading = false,
    bool hasMoreItems = true,
  })  : isServerSide = onLoad != null,
        _debouncer = TDebouncer(milliseconds: searchDelay ?? (onLoad != null ? 2500 : 750)),
        itemToString = itemToString ?? _defaultItemToString,
        itemKey = itemKey ?? defaultItemKey,
        _filter = TSearchFilter(itemToString: itemToString ?? _defaultItemToString),
        super(
          TListState<T, K>(
            displayItems: const [],
            selectedKeys: initialSelectedKeys != null ? LinkedHashSet<K>.from(initialSelectedKeys) : LinkedHashSet<K>(),
            expandedKeys: initialExpandedKeys != null ? LinkedHashSet<K>.from(initialExpandedKeys) : LinkedHashSet<K>(),
            page: 1,
            itemsPerPage: itemsPerPage,
            totalItems: items.length,
            loading: loading,
            fetching: false,
            hasMoreItems: hasMoreItems,
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

    if (items.isNotEmpty) {
      updateItems(items);
    }
  }
  static const allowedKeyTypes = [String, int, double, num, bool];

  static K defaultItemKey<T, K>(T item) {
    if (allowedKeyTypes.contains(T)) {
      return item as K;
    }

    return identityHashCode(item) as K;
  }

  static String _defaultItemToString<T>(T item) => item.toString();

  // Getters
  bool get mounted => hasListeners;
  bool get isHierarchical => itemChildren != null;
  bool get hasError => value.error != null;
  bool get isLoading => value.loading;
  bool get isFetching => value.fetching;

  /// The set of selected item keys.
  UnmodifiableSetView<K> get selectedKeys => UnmodifiableSetView(value.selectedKeys);

  /// The set of expanded tree parent item keys.
  UnmodifiableSetView<K> get expandedKeys => UnmodifiableSetView(value.expandedKeys);

  /// List of currently displayed items (paginated/filtered).
  List<TListItem<T, K>> get displayItems => value.displayItems;

  /// Keys of currently displayed items.
  List<K> get displayItemKeys => displayItems.map((x) => x.key).toList();


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
    K? expandedDetailKey,
    bool clearExpandedDetail = false,
    K? editingItemKey,
    bool clearEditingItem = false,
    int? page,
    int? itemsPerPage,
    int? totalItems,
    bool? loading,
    bool? fetching,
    bool? hasMoreItems,
    bool? isCreatingItem,
    String? search,
    TSelectionMode? selectionMode,
    TExpansionMode? expansionMode,
    TListError? error,
    String? currentCursor,
    String? nextCursor,
    List<String>? cursorHistory,
    Map<String, dynamic>? advancedSearch,
    Map<String, dynamic>? additional,
  }) {
    if (_disposed) {
      debugPrint('Controller already disposed.');
      return;
    }

    var effectiveSelectedKeys = selectedKeys ?? value.selectedKeys;
    var effectiveExpandedKeys = expandedKeys ?? value.expandedKeys;
    var effectiveDisplayItems = displayItems ?? value.displayItems;

    var effectiveExpandedDetailKey = clearExpandedDetail ? null : (expandedDetailKey ?? value.expandedDetailKey);
    var effectiveEditingItemKey = clearEditingItem ? null : (editingItemKey ?? value.editingItemKey);

    if (displayItems != null && value.displayItems.isEmpty && effectiveDisplayItems.isNotEmpty) {
      if (autoSelectFirst && effectiveSelectedKeys.isEmpty && !_hasAutoSelectedFirst) {
        effectiveSelectedKeys = copyKeySet(effectiveSelectedKeys)..add(effectiveDisplayItems.first.key);
        _hasAutoSelectedFirst = true;
      }
      if (autoExpandFirst && effectiveExpandedKeys.isEmpty && !_hasAutoExpandedFirst) {
        effectiveExpandedKeys = copyKeySet(effectiveExpandedKeys)..add(effectiveDisplayItems.first.key);
        effectiveExpandedDetailKey = effectiveDisplayItems.first.key;
        _hasAutoExpandedFirst = true;
      }
    }

    if (isHierarchical && (displayItems != null || expandedKeys != null)) {
      effectiveDisplayItems = _flattenDisplayItems(
        items: effectiveDisplayItems,
        expandedKeys: effectiveExpandedKeys,
      );
    }

    value = TListState<T, K>(
      displayItems: effectiveDisplayItems,
      selectedKeys: effectiveSelectedKeys,
      expandedKeys: effectiveExpandedKeys,
      expandedDetailKey: effectiveExpandedDetailKey,
      editingItemKey: effectiveEditingItemKey,
      isCreatingItem: isCreatingItem ?? value.isCreatingItem,
      page: page ?? value.page,
      itemsPerPage: itemsPerPage ?? value.itemsPerPage,
      totalItems: totalItems ?? value.totalItems,
      loading: loading ?? value.loading,
      fetching: fetching ?? value.fetching,
      hasMoreItems: hasMoreItems ?? value.hasMoreItems,
      search: search ?? value.search,
      error: error ?? value.error,
      currentCursor: currentCursor ?? value.currentCursor,
      nextCursor: nextCursor ?? value.nextCursor,
      cursorHistory: cursorHistory ?? value.cursorHistory,
      advancedSearch: advancedSearch ?? value.advancedSearch,
      additional: additional ?? value.additional,
    );

    //debugPrint("$who: $value");
  }

  /// Retrieves a [TListItem] by key, or null if not found.
  TListItem<T, K>? getItem(K key) => _itemsMap[key];

  LinkedHashSet<K> createEmptyKeySet() => LinkedHashSet<K>();
  LinkedHashSet<K> copyKeySet(Iterable<K> keys) => LinkedHashSet<K>.from(keys);
}
