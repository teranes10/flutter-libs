part of 'list_controller.dart';

/// Extension providing expansion functionality for hierarchical lists.
///
/// Enables single and multiple item expansion with methods to:
/// - Expand/collapse individual items
/// - Expand/collapse all items
/// - Toggle expansion states
/// - Expand while setting additional state atomically
/// - Query expansion status
///
/// Example:
/// ```dart
/// // Expand an item
/// controller.expandItem(category);
///
/// // Expand an item and set additional state atomically
/// controller.expandItemAndSetAdditionalState(category, 'active_tab', 'details');
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
  bool get isAllExpanded =>
      value.displayItems.isNotEmpty && value.displayItems.length <= expandedCount && value.displayItems.every((i) => i.isExpanded);

  /// Whether some (but not all) items are expanded.
  bool get isSomeExpanded => hasExpansion && !isAllExpanded;

  /// Human-readable expansion information.
  String get expansionInfo {
    if (expandedCount == 0) return 'No items expanded';
    if (expandedCount == 1) return '1 item expanded';
    return '$expandedCount items expanded';
  }

  bool isItemKeyExpanded(K key) => expandedKeys.contains(key);

  void toggleExpansionByKey(K key, {Map<String, dynamic>? additional}) {
    if (expansionMode == TExpansionMode.none) return;

    final isExpanded = isItemKeyExpanded(key);
    isExpanded ? collapseItemKey(key, additional: additional) : expandItemKey(key, additional: additional);
  }

  void expandItemKey(K key, {Map<String, dynamic>? additional}) {
    if (expansionMode == TExpansionMode.none) return;

    final newExpandedKeys = expansionMode == TExpansionMode.single ? copyKeySet([key]) : copyKeySet(expandedKeys)
      ..add(key);

    updateExpansionState(newExpandedKeys, additional: additional);
  }

  void collapseItemKey(K key, {Map<String, dynamic>? additional}) {
    if (expansionMode == TExpansionMode.none) return;

    final newExpandedKeys = copyKeySet(expandedKeys)..remove(key);
    updateExpansionState(newExpandedKeys, additional: additional);
  }

  void expandItemKeys(Iterable<K> keys, {Map<String, dynamic>? additional}) {
    if (expansionMode != TExpansionMode.multiple || keys.isEmpty) return;

    final newExpandedKeys = copyKeySet(expandedKeys)..addAll(keys);
    updateExpansionState(newExpandedKeys, additional: additional);
  }

  bool isItemExpanded(T item) => isItemKeyExpanded(itemKey(item));

  void toggleExpansion(T item, {Map<String, dynamic>? additional}) => toggleExpansionByKey(itemKey(item), additional: additional);

  void expandItem(T item, {Map<String, dynamic>? additional}) => expandItemKey(itemKey(item), additional: additional);

  void collapseItem(T item, {Map<String, dynamic>? additional}) => collapseItemKey(itemKey(item), additional: additional);

  void expandItems(Iterable<T> items, {Map<String, dynamic>? additional}) => expandItemKeys(items.map((item) => itemKey(item)), additional: additional);

  void expandAll({Map<String, dynamic>? additional}) => expandItemKeys(listItemKeys, additional: additional);

  void collapseAll({Map<String, dynamic>? additional}) {
    if (expandedKeys.isEmpty && additional == null) return;
    updateExpansionState(createEmptyKeySet(), additional: additional);
  }

  void toggleExpandAll({Map<String, dynamic>? additional}) {
    if (expansionMode != TExpansionMode.multiple) return;
    isAllExpanded ? collapseAll(additional: additional) : expandAll(additional: additional);
  }

  /// Expands an item by key and sets a key-value pair in [additional] state atomically.
  void expandItemKeyAndSetAdditionalState(K key, String additionalKey, dynamic additionalValue) {
    expandItemKey(key, additional: {additionalKey: additionalValue});
  }

  /// Expands an item and sets a key-value pair in [additional] state atomically.
  void expandItemAndSetAdditionalState(T item, String additionalKey, dynamic additionalValue) {
    expandItem(item, additional: {additionalKey: additionalValue});
  }

  /// Alias for [expandItemAndSetAdditionalState].
  void expandAndSetAdditionalState(T item, String additionalKey, dynamic additionalValue) {
    expandItemAndSetAdditionalState(item, additionalKey, additionalValue);
  }

  void updateExpansionState(
    LinkedHashSet<K> expandedKeys, {
    Map<String, dynamic>? additional,
  }) {
    final activeKey = expandedKeys.firstOrNull;
    final Map<String, dynamic>? mergedAdditional = additional != null
        ? (Map<String, dynamic>.from(value.additional)..addAll(additional))
        : null;

    updateState(
      who: 'updateExpansionState',
      expandedKeys: expandedKeys,
      activeKey: activeKey,
      clearActive: activeKey == null,
      isCreatingItem: false,
      isEditingItem: false,
      additional: mergedAdditional,
    );
  }
}

