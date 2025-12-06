part of 'list_controller.dart';

/// Extension providing expansion functionality for hierarchical lists.
///
/// Enables single and multiple item expansion with methods to:
/// - Expand/collapse individual items
/// - Expand/collapse all items
/// - Toggle expansion states
/// - Query expansion status
///
/// Example:
/// ```dart
/// // Expand an item
/// controller.expandItem(category);
///
/// // Expand multiple items
/// controller.expandItems([category1, category2]);
///
/// // Check expansion
/// if (controller.hasExpansion) {
///   print('Expanded: ${controller.expandedCount}');
/// }
///
/// // Collapse all
/// controller.collapseAll();
/// ```
extension TListControllerExpansion<T, K> on TListController<T, K> {
  /// Whether expansion is enabled.
  bool get expandable => expansionMode != TExpansionMode.none;

  /// The set of expanded item keys.
  LinkedHashSet<K> get expandedKeys => value.expandedKeys;

  /// The list of expanded items.
  List<T> get expandedItems => getItemsFromKeys(expandedKeys);

  /// Whether any items are expanded.
  bool get hasExpansion => expandedKeys.isNotEmpty;

  /// Whether multiple items are expanded.
  bool get hasMultipleExpansion => expandedKeys.length > 1;

  /// The number of expanded items.
  int get expandedCount => expandedKeys.length;

  /// Whether all items are expanded.
  bool get isAllExpanded => value.displayItems.isNotEmpty && value.displayItems.length == expandedCount;

  /// Whether some (but not all) items are expanded.
  bool get isSomeExpanded => hasExpansion && !isAllExpanded;

  /// Human-readable expansion information.
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

  void expandAll() => expandItemKeys(listItemKeys);

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
