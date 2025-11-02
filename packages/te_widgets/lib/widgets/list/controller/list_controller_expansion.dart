part of 'list_controller.dart';

extension TListControllerExpansion<T, K> on TListController<T, K> {
  TExpansionMode get expansionMode => value.expansionMode;
  bool get expandable => expansionMode != TExpansionMode.none;
  LinkedHashSet<K> get expandedKeys => value.expandedKeys;
  List<T> get expandedItems => getItemsFromKeys(expandedKeys);
  bool get hasExpansion => expandedKeys.isNotEmpty;
  bool get hasMultipleExpansion => expandedKeys.length > 1;
  int get expandedCount => expandedKeys.length;
  bool get isAllExpanded => value.displayItems.isNotEmpty && value.displayItems.length == expandedCount;
  bool get isSomeExpanded => hasExpansion && !isAllExpanded;

  String get expansionInfo {
    if (expandedCount == 0) return 'No items expanded';
    if (expandedCount == 1) return '1 item expanded';
    return '$expandedCount items expanded';
  }

  bool isItemKeyExpanded(K key) => expandedKeys.contains(key);

  void toggleExpansionByKey(K key) {
    if (expansionMode == TExpansionMode.none) return;

    final isExpanded = isItemKeyExpanded(key);
    isExpanded ? collapseItemKey(key) : expandItemKey(key);
  }

  void expandItemKey(K key) {
    if (expansionMode == TExpansionMode.none) return;

    final newExpandedKeys = expansionMode == TExpansionMode.single ? LinkedHashSet<K>.from([key]) : LinkedHashSet<K>.from(expandedKeys)
      ..add(key);

    updateExpansionState(newExpandedKeys);
  }

  void collapseItemKey(K key) {
    if (expansionMode == TExpansionMode.none) return;

    final newExpandedKeys = LinkedHashSet<K>.from(expandedKeys)..remove(key);
    updateExpansionState(newExpandedKeys);
  }

  void expandItemKeys(Iterable<K> keys) {
    if (expansionMode != TExpansionMode.multiple || keys.isEmpty) return;

    final newExpandedKeys = LinkedHashSet<K>.from(expandedKeys)..addAll(keys);
    updateExpansionState(newExpandedKeys);
  }

  void isItemExpanded(T item) => isItemKeyExpanded(itemKey(item));

  void toggleExpansion(T item) => toggleExpansionByKey(itemKey(item));

  void expandItem(T item) => expandItemKey(itemKey(item));

  void collapseItem(T item) => collapseItemKey(itemKey(item));

  void expandItems(Iterable<T> items) => expandItemKeys(items.map((item) => itemKey(item)));

  void expandAll() => expandItemKeys(displayItemKeys);

  void collapseAll() {
    if (expandedKeys.isEmpty) return;
    updateExpansionState(LinkedHashSet<K>());
  }

  void toggleExpandAll() {
    if (expansionMode != TExpansionMode.multiple) return;
    isAllExpanded ? collapseAll() : expandAll();
  }

  void updateExpansionState(LinkedHashSet<K> expandedKeys) {
    updateState(
      who: 'updateExpansionState',
      expandedKeys: expandedKeys,
    );
  }
}
