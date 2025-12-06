part of 'list_controller.dart';

/// Extension providing item management for [TListController].
///
/// Handles CRUD operations for list items:
/// - Add, update, remove items
/// - Clear all items
/// - Manage local pagination state updates
extension TListControllerItems<T, K> on TListController<T, K> {
  /// Map of all items by key.
  Map<K, T> get itemsMap => _itemsMap;

  /// List of all items (flattened).
  List<T> get flatItems => _itemsMap.values.toList();

  /// List of currently displayed items (paginated/filtered).
  List<TListItem<T, K>> get listItems => value.displayItems;

  /// Keys of currently displayed items.
  List<K> get listItemKeys => listItems.map((x) => x.key).toList();

  /// Whether the display list is empty.
  bool get isEmpty => listItems.isEmpty;

  /// Whether the display list is not empty.
  bool get isNotEmpty => listItems.isNotEmpty;

  bool get _useLocalPaginationItems => !isServerSide;

  /// The items available for local pagination.
  List<T> get localItems => _useLocalPaginationItems ? _localPaginationItems : flatItems;

  /// Updates the entire list of items.
  ///
  /// Preserves selection and expansion state where possible.
  void updateItems(List<T> items) {
    if (_useLocalPaginationItems) {
      _localPaginationItems.clear();
      _localPaginationItems.addAll(items);
    }

    Set<K> preservedKeys = <K>{...selectedKeys, ...expandedKeys};

    final preservedItems = <K, T>{};
    for (final k in preservedKeys) {
      final v = _itemsMap[k];
      if (v != null) preservedItems[k] = v;
    }

    _itemsMap
      ..clear()
      ..addAll(preservedItems);

    void addItemRecursive(T item) {
      final key = itemKey(item);
      _itemsMap[key] = item;

      if (isHierarchical) {
        final children = itemChildren!(item);
        if (children != null) {
          for (final child in children) {
            addItemRecursive(child);
          }
        }
      }
    }

    for (final item in items) {
      addItemRecursive(item);
    }

    if (!isServerSide) {
      _executePaginationAction('updateItems', page: 1);
    }
  }

  /// Adds a single item.
  ///
  /// Throws if an item with the same key already exists.
  void addItem(T item, [bool prepend = true]) {
    final key = itemKey(item);
    if (_itemsMap.containsKey(key)) {
      throw ArgumentError.value(key, 'key', 'Item already exists');
    }

    _itemsMap[key] = item;

    if (_useLocalPaginationItems) {
      if (prepend) {
        _localPaginationItems.insert(0, item);
      } else {
        _localPaginationItems.add(item);
      }
    }

    updateState(
      who: 'addItem',
      displayItems: value.displayItems.copyWithItem(itemFactory(item), prepend),
      totalItems: value.totalItems + 1,
    );
  }

  /// Adds multiple items.
  void addItems(List<T> newItems, {bool prepend = true}) {
    if (newItems.isEmpty) return;

    for (final item in newItems) {
      final key = itemKey(item);
      _itemsMap[key] = item;
    }

    if (_useLocalPaginationItems) {
      if (prepend) {
        _localPaginationItems.insertAll(0, newItems);
      } else {
        _localPaginationItems.addAll(newItems);
      }
    }

    updateState(
      who: 'addItems',
      displayItems: value.displayItems.copyWithItems(
        newItems.map((item) => itemFactory(item)).toList(),
        prepend,
      ),
      totalItems: value.totalItems + newItems.length,
    );
  }

  /// Updates an item by its key.
  void updateItemByKey(K key, T item) {
    if (!_itemsMap.containsKey(key)) {
      throw ArgumentError.value(key, 'key', 'Item not found');
    }

    _itemsMap[key] = item;

    if (_useLocalPaginationItems) {
      final index = _localPaginationItems.indexWhere((x) => itemKey(x) == key);
      if (index != -1) {
        _localPaginationItems[index] = item;
      }
    }

    final displayItems = value.displayItems;
    final index = displayItems.indexWhere((x) => x.key == key);
    if (index > -1) {
      updateState(
        who: 'updateItem',
        displayItems: displayItems.copyWithReplacedAt(index, displayItems[index].copyWith(data: item)),
      );
    }
  }

  /// Updates an existing item.
  void updateItem(T oldItem, T item) => updateItemByKey(itemKey(oldItem), item);

  /// Removes an item by key.
  void removeItemByKey(K key) {
    if (!_itemsMap.containsKey(key)) {
      throw ArgumentError.value(key, 'key', 'Item not found');
    }

    _itemsMap.remove(key);

    if (_useLocalPaginationItems) {
      _localPaginationItems.removeWhere((x) => itemKey(x) == key);
    }

    final displayItems = value.displayItems;
    final index = displayItems.indexWhere((x) => x.key == key);
    if (index > -1) {
      updateState(
        who: 'removeItem',
        displayItems: displayItems.copyWithRemovedAt(index),
        totalItems: value.totalItems - 1,
        selectedKeys: LinkedHashSet<K>.from(value.selectedKeys)..remove(key),
        expandedKeys: LinkedHashSet<K>.from(value.expandedKeys)..remove(key),
      );
    }
  }

  /// Removes a specific item.
  void removeItem(T item) => removeItemByKey(itemKey(item));

  /// Removes multiple items by keys.
  void removeItemsByKeys(Set<K> keys) {
    final existingKeys = keys.where(_itemsMap.containsKey).toSet();
    if (existingKeys.isEmpty) {
      throw ArgumentError.value(keys, 'keys', 'No matching items found');
    }

    _itemsMap.removeWhere((k, _) => existingKeys.contains(k));

    if (_useLocalPaginationItems) {
      _localPaginationItems.removeWhere((x) => existingKeys.contains(itemKey(x)));
    }

    final displayItems = value.displayItems;
    final newDisplayItems = displayItems.where((x) => !existingKeys.contains(x.key)).toList();

    final newSelectedKeys = LinkedHashSet<K>.from(value.selectedKeys)..removeAll(existingKeys);
    final newExpandedKeys = LinkedHashSet<K>.from(value.expandedKeys)..removeAll(existingKeys);

    updateState(
      who: 'removeItems',
      displayItems: newDisplayItems,
      totalItems: value.totalItems - existingKeys.length,
      selectedKeys: newSelectedKeys,
      expandedKeys: newExpandedKeys,
    );
  }

  /// Removes multiple items.
  void removeItems(List<T> items) => removeItemsByKeys(items.map((x) => itemKey(x)).toSet());

  /// Removes all currently selected items.
  void removeSelectedItems() {
    if (selectedKeys.isEmpty) return;
    removeItemsByKeys(value.selectedKeys);
  }

  /// Reorders items in the list.
  void reorder(int oldIndex, int newIndex) {
    updateState(
      who: 'reorder',
      displayItems: listItems.reorder(oldIndex, newIndex),
    );
    onReorder?.call(oldIndex, newIndex);
  }

  /// Clears all items and resets state.
  void clear() {
    _itemsMap.clear();
    if (_useLocalPaginationItems) {
      _localPaginationItems.clear();
    }

    updateState(
      who: 'clear',
      displayItems: const [],
      totalItems: 0,
      selectedKeys: LinkedHashSet<K>(),
      expandedKeys: LinkedHashSet<K>(),
      page: 1,
    );
  }

  /// Retrieves a list of items corresponding to the provided keys.
  List<T> getItemsFromKeys(Iterable<K> keys) {
    if (keys.isEmpty) return [];

    final keySet = keys.toSet();
    final results = <T>[];

    for (final key in keySet) {
      final item = _itemsMap[key];
      if (item != null) {
        results.add(item);
      }
    }

    return results;
  }
}
