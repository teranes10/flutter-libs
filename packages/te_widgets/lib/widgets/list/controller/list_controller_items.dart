part of 'list_controller.dart';

/// Extension providing item management for [TListController].
///
/// Handles CRUD operations for list items:
/// - Add, update, remove items
/// - Clear all items
/// - Manage local pagination state updates
extension TListControllerItems<T, K> on TListController<T, K> {
  /// Map of all items by key.
  Map<K, TListItem<T, K>> get itemsMap => _itemsMap;

  /// Flat list of all item data values (across all levels).
  List<T> get flatItems => _itemsMap.values.map((x) => x.data).toList();

  /// List of selected data items.
  List<T> get selectedItems => getItems(selectedKeys);

  /// List of expanded data items.
  List<T> get expandedItems => getItems(expandedKeys);

  /// Whether the display list is empty.
  bool get isEmpty => displayItems.isEmpty;


  /// Whether the display list is not empty.
  bool get isNotEmpty => displayItems.isNotEmpty;

  /// Whether to use client-side local pagination items.
  /// Always false for server-side lists.
  bool get _useLocalPaginationItems => !isServerSide;

  /// The items available for local pagination.
  ///
  /// For client-side lists, this is the ordered root-level item list.
  /// For server-side lists, falls back to all items in [_itemsMap].
  List<T> get localItems =>
      _useLocalPaginationItems ? _localPaginationItems.map((x) => x.data).toList() : flatItems;

  /// Updates the entire list of items.
  ///
  /// Preserves selection and expansion state where possible.
  /// For server-side lists, updates [totalItems] in state without triggering pagination.
  void updateItems(List<T> items, {bool append = false}) {
    if (!append) {
      if (_useLocalPaginationItems) {
        _localPaginationItems.clear();
      }
      // Preserve items that are currently selected or expanded so that
      // state (selection/expansion) doesn't get orphaned after a refresh.
      final Set<K> preservedKeys = <K>{...selectedKeys, ...expandedKeys};
      final preservedItems = <K, TListItem<T, K>>{};
      for (final k in preservedKeys) {
        final v = _itemsMap[k];
        if (v != null) preservedItems[k] = v;
      }

      _itemsMap
        ..clear()
        ..addAll(preservedItems);
    }

    for (final item in items) {
      _registerRecursive(item);
    }

    if (!isServerSide) {
      _executePaginationAction('updateItems', page: 1);
    } else if (!append) {
      // Server-side: reflect updated item count in state without re-fetching.
      updateState(who: 'updateItems_serverSide', totalItems: _itemsMap.length);
    }
  }

  /// Adds a single item.
  ///
  /// Throws if an item with the same key already exists.
  void addItem(T item, {K? parentKey, bool prepend = true}) {
    addItems([item], parentKey: parentKey, prepend: prepend);
  }

  /// Adds multiple items.
  ///
  /// When [parentKey] is provided, items are added as children of that parent.
  /// Throws [ArgumentError] if any key already exists or if [parentKey] is unknown.
  void addItems(List<T> newItems, {K? parentKey, bool prepend = true}) {
    if (newItems.isEmpty) return;

    TListItem<T, K>? parent;
    if (parentKey != null) {
      parent = _itemsMap[parentKey];
      if (parent == null) {
        throw ArgumentError.value(parentKey, 'parentKey', 'Provided parent key does not exist');
      }
    }
    final level = parent != null ? parent.level + 1 : 0;

    // Validate all keys up front so a duplicate-key throw mid-loop can't leave
    // _itemsMap partially mutated (atomicity guarantee).
    for (final item in newItems) {
      final key = itemKey(item);
      if (_itemsMap.containsKey(key)) {
        throw ArgumentError.value(key, 'key', 'Item already exists');
      }
    }

    final newElements = [
      for (final item in newItems) _registerRecursive(item, parentKey: parent?.key, level: level, prepend: prepend),
    ];

    // Keep the parent's childrenKeys in sync — without this, expansion/descendant
    // traversal never discovers the new items.
    if (parent != null) {
      final newKeys = newElements.map((e) => e.key).toList();
      final existing = parent.childrenKeys ?? const [];
      // Avoid spread-into-list — on web (DDC) spreads can produce JSArray<dynamic>.
      final merged = <K>[];
      if (prepend) {
        merged.addAll(newKeys);
        merged.addAll(existing);
      } else {
        merged.addAll(existing);
        merged.addAll(newKeys);
      }
      _itemsMap[parent.key] = itemFactory(parent.data, parentKey: parent.parentKey, childrenKeys: merged, level: parent.level);
      // Sync the updated parent back into _localPaginationItems and displayItems.
      _syncParentInLocalAndDisplay(parent.key);
    }

    final newDisplayItems = _spliceNewItems(parent, newElements, prepend);

    updateState(who: 'addItems', displayItems: newDisplayItems, totalItems: value.totalItems + newItems.length);
  }

  List<TListItem<T, K>> _spliceNewItems(TListItem<T, K>? parent, List<TListItem<T, K>> newElements, bool prepend) {
    if (parent == null) return value.displayItems.copyWithItems(newElements, prepend);
    if (!isExpanded(parent.key)) return value.displayItems; // parent collapsed — new kids aren't visible yet

    final current = value.displayItems;
    final parentIndex = current.indexWhere((x) => x.key == parent.key);
    if (parentIndex == -1) return current; // parent itself filtered out / not visible

    var childBlockEnd = parentIndex + 1;
    while (childBlockEnd < current.length && current[childBlockEnd].level > parent.level) {
      childBlockEnd++;
    }
    // Avoid spread-into-list — on web (DDC) spreads across generic list types
    // produce JSArray<dynamic>, causing runtime type errors at typed boundaries.
    final insertAt = prepend ? parentIndex + 1 : childBlockEnd;
    final result = <TListItem<T, K>>[];
    result.addAll(current.sublist(0, insertAt));
    result.addAll(newElements);
    result.addAll(current.sublist(insertAt));
    return result;
  }

  /// Updates an item by its key.
  ///
  /// Handles child hierarchy changes: removes stale descendants, registers new ones.
  void updateItemByKey(K key, T newItem) {
    final existing = _itemsMap[key];
    if (existing == null) throw ArgumentError.value(key, 'key', 'Item not found');

    final rawChildren = getChildren(newItem);
    final newChildKeys = rawChildren != null && rawChildren.isNotEmpty ? rawChildren.map(itemKey).toList() : null;

    _itemsMap[key] = itemFactory(newItem, parentKey: existing.parentKey, childrenKeys: newChildKeys, level: existing.level);

    final oldChildKeys = existing.childrenKeys ?? const [];
    final newKeysSet = (newChildKeys ?? const []).toSet();
    final removedDescendants = <K>{};

    for (final oldKey in oldChildKeys) {
      if (!newKeysSet.contains(oldKey)) {
        final descendants = getDescendantsOfKey(oldKey)..add(oldKey);
        removedDescendants.addAll(descendants);
        _itemsMap.removeWhere((k, _) => descendants.contains(k));
        if (_useLocalPaginationItems) {
          _localPaginationItems.removeWhere((x) => descendants.contains(x.key));
        }
      }
    }

    if (isHierarchical && rawChildren != null) {
      for (final child in rawChildren) {
        _registerRecursive(child, parentKey: key, level: existing.level + 1);
      }
    }

    if (_useLocalPaginationItems) {
      final idx = _localPaginationItems.indexWhere((x) => x.key == key);
      if (idx != -1) _localPaginationItems[idx] = _itemsMap[key]!;
    }

    var newDisplayItems =
        removedDescendants.isEmpty ? value.displayItems : value.displayItems.where((x) => !removedDescendants.contains(x.key)).toList();

    final idx = newDisplayItems.indexWhere((x) => x.key == key);
    if (idx > -1) newDisplayItems = newDisplayItems.copyWithReplacedAt(idx, _itemsMap[key]!);

    // If childrenKeys changed, sync the parent entry (the updated item itself IS the parent here).
    if (existing.parentKey != null) {
      _syncParentInLocalAndDisplay(existing.parentKey as K);
    }

    updateState(
      who: 'updateItem',
      displayItems: newDisplayItems,
      selectedKeys: removedDescendants.isEmpty ? null : (copyKeySet(value.selectedKeys)..removeAll(removedDescendants)),
      expandedKeys: removedDescendants.isEmpty ? null : (copyKeySet(value.expandedKeys)..removeAll(removedDescendants)),
      totalItems: removedDescendants.isEmpty ? null : value.totalItems - removedDescendants.length,
    );
  }

  /// Updates an existing item by value equality on its key.
  void updateItem(T oldItem, T newItem) => updateItemByKey(itemKey(oldItem), newItem);

  /// Removes an item by key.
  void removeItemByKey(K key) {
    removeItemsByKeys({key});
  }

  /// Removes a specific item.
  void removeItem(T item) => removeItemByKey(itemKey(item));

  /// Removes multiple items by keys.
  ///
  /// Also removes all descendants of the specified items.
  /// Throws [ArgumentError] if none of the keys exist.
  void removeItemsByKeys(Set<K> keys) {
    final existingKeys = keys.where(_itemsMap.containsKey).toSet();
    if (existingKeys.isEmpty) {
      throw ArgumentError.value(keys, 'keys', 'No matching items found');
    }

    // Collect all descendants for the keys being removed.
    final allToRemove = <K>{...existingKeys};
    for (final key in existingKeys) {
      allToRemove.addAll(getDescendantsOfKey(key));
    }

    // Update parent childrenKeys if parent is NOT also being removed.
    for (final key in existingKeys) {
      final item = _itemsMap[key];
      if (item != null && item.parentKey != null && !allToRemove.contains(item.parentKey)) {
        final parentItem = _itemsMap[item.parentKey!];
        if (parentItem != null && parentItem.childrenKeys != null) {
          final updatedChildrenKeys = parentItem.childrenKeys!.where((k) => !allToRemove.contains(k)).toList();
          _itemsMap[parentItem.key] = itemFactory(
            parentItem.data,
            parentKey: parentItem.parentKey,
            childrenKeys: updatedChildrenKeys.isNotEmpty ? updatedChildrenKeys : null,
            level: parentItem.level,
          );
          // Sync updated parent back into _localPaginationItems and displayItems.
          _syncParentInLocalAndDisplay(parentItem.key);
        }
      }
    }

    _itemsMap.removeWhere((k, _) => allToRemove.contains(k));

    if (_useLocalPaginationItems) {
      _localPaginationItems.removeWhere((x) => allToRemove.contains(x.key));
    }

    final displayItems = value.displayItems;
    final newDisplayItems = displayItems.where((x) => !allToRemove.contains(x.key)).toList();

    final newSelectedKeys = copyKeySet(value.selectedKeys)..removeAll(allToRemove);
    final newExpandedKeys = copyKeySet(value.expandedKeys)..removeAll(allToRemove);

    updateState(
      who: 'removeItems',
      displayItems: newDisplayItems,
      // Fix: subtract ALL removed items (including descendants), not just the top-level keys.
      totalItems: value.totalItems - allToRemove.length,
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
      displayItems: displayItems.reorder(oldIndex, newIndex),
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
      selectedKeys: createEmptyKeySet(),
      expandedKeys: createEmptyKeySet(),
      page: 1,
    );
  }

  /// Retrieves a list of items corresponding to the provided keys.
  List<T> getItems(Iterable<K> keys) {
    if (keys.isEmpty) return [];

    final keySet = keys.toSet();
    final results = <T>[];

    for (final key in keySet) {
      final item = _itemsMap[key];
      if (item != null) {
        results.add(item.data);
      }
    }

    return results;
  }

  /// Registers an item in the items map if not already present.
  void registerItem(T item) {
    final key = itemKey(item);
    if (!_itemsMap.containsKey(key)) {
      _itemsMap[key] = itemFactory(item);
    }
  }

  TListItem<T, K> _registerRecursive(T item, {K? parentKey, int level = 0, bool prepend = false}) {
    final key = itemKey(item);
    final listItem = itemFactory(item, parentKey: parentKey, level: level);

    _itemsMap[key] = listItem;

    // Client-side only: only root-level (level == 0) items go into _localPaginationItems.
    // Children are resolved from _itemsMap via their parent's childrenKeys.
    assert(
      level != 0 || _useLocalPaginationItems || isServerSide,
      '_registerRecursive: level-0 items should only be tracked in _localPaginationItems for client-side lists.',
    );
    if (level == 0 && _useLocalPaginationItems) {
      if (prepend) {
        _localPaginationItems.insert(0, listItem);
      } else {
        _localPaginationItems.add(listItem);
      }
    }

    if (isHierarchical) {
      final children = itemChildren?.call(item);

      if (children != null) {
        for (final child in children) {
          _registerRecursive(child, parentKey: key, level: level + 1);
        }
      }
    }

    return listItem;
  }

  /// Safely retrieves an item from `_itemsMap` or registers it if not present.
  TListItem<T, K> getOrRegisterItem(T item) {
    final key = itemKey(item);
    final existing = _itemsMap[key];
    if (existing != null) return existing;
    return _registerRecursive(item);
  }

  /// Syncs the updated [TListItem] for [parentKey] back into [_localPaginationItems]
  /// and [displayItems] after its [childrenKeys] have been mutated in [_itemsMap].
  ///
  /// This ensures no stale item references remain in the local/display lists.
  void _syncParentInLocalAndDisplay(K parentKey) {
    final updated = _itemsMap[parentKey];
    if (updated == null) return;

    if (_useLocalPaginationItems) {
      final idx = _localPaginationItems.indexWhere((x) => x.key == parentKey);
      if (idx != -1) _localPaginationItems[idx] = updated;
    }

    final displayIdx = value.displayItems.indexWhere((x) => x.key == parentKey);
    if (displayIdx != -1) {
      // We update the displayItems reference in-place without triggering a full state rebuild.
      // The next updateState call will pick up the new reference from value.displayItems.
      final newDisplay = List<TListItem<T, K>>.from(value.displayItems);
      newDisplay[displayIdx] = updated;
      // Store directly to avoid recursive updateState during a parent-add operation.
      value = value.copyWith(displayItems: newDisplay);
    }
  }
}
