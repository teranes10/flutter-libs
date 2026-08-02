part of 'list_controller.dart';

/// Extension providing tree node expansion functionality for hierarchical lists (`expandedKeys`).
///
/// Enables expanding and collapsing tree node items to show/hide sub-items inline in lists and tables.
extension TListControllerExpansion<T, K> on TListController<T, K> {
  /// Whether tree node expansion is enabled.
  bool get expandable => expansionMode != TExpansionMode.none;

  /// Whether any tree items are expanded.
  bool get hasExpansion => expandedKeys.isNotEmpty;


  /// The number of expanded tree items.
  int get expandedCount => expandedKeys.length;

  /// Whether all tree items are expanded.
  bool get isAllExpanded =>
      value.displayItems.isNotEmpty && value.displayItems.length <= expandedCount && value.displayItems.every((i) => isExpanded(i.key));

  /// Tristate expansion value (true/null/false).
  bool? get expansionTristate => isAllExpanded
      ? true
      : hasExpansion
          ? null
          : false;

  /// Human-readable expansion information.
  String get expansionInfo {
    if (expandedCount == 0) return 'No items expanded';
    if (expandedCount == 1) return '1 item expanded';
    return '$expandedCount items expanded';
  }

  List<TListItem<T, K>> _flattenDisplayItems({
    required List<TListItem<T, K>> items,
    required LinkedHashSet<K> expandedKeys,
  }) {
    if (items.isEmpty || !isHierarchical) return items;
    if (expandedKeys.isEmpty) {
      return items.where((x) => x.level == 0).toList();
    }

    final rootItems = items.where((x) => x.level == 0).toList();
    final List<TListItem<T, K>> result = [];

    void addWithDescendants(TListItem<T, K> item) {
      result.add(item);
      if (expandedKeys.contains(item.key) && item.hasChildren) {
        for (final childKey in item.childrenKeys!) {
          final childItem = _itemsMap[childKey];
          if (childItem != null) {
            addWithDescendants(childItem);
          }
        }
      }
    }

    for (final item in rootItems) {
      addWithDescendants(item);
    }
    return result;
  }

  bool canExpand(K key) {
    final item = _itemsMap[key];
    return item?.hasChildren ?? false;
  }

  bool isExpanded(K key) => expandedKeys.contains(key);

  void toggleExpansion(K key) {
    isExpanded(key) ? collapse(key) : expand(key);
  }

  void expand(K key) {
    final ancestors = getAncestorsOfKey(key);
    final LinkedHashSet<K> newExpandedKeys;

    if (expansionMode == TExpansionMode.single) {
      // Avoid direct LinkedHashSet<K>() instantiation inside the extension on web (DDC),
      // which can yield a LinkedSet<dynamic> at runtime. Using the class helper
      // copyKeySet preserves the reified type parameter K.
      newExpandedKeys = copyKeySet(ancestors)..add(key);
    } else {
      newExpandedKeys = copyKeySet(expandedKeys)
        ..addAll(ancestors)
        ..add(key);
    }

    updateExpansionState(newExpandedKeys);
  }

  void collapse(K key) {
    final descendants = getDescendantsOfKey(key);
    final newExpandedKeys = copyKeySet(expandedKeys)
      ..remove(key)
      ..removeAll(descendants);
    updateExpansionState(newExpandedKeys);
  }

  void expandKeys(Iterable<K> keys) {
    if (keys.isEmpty) return;

    final newExpandedKeys = copyKeySet(expandedKeys)..addAll(keys);
    updateExpansionState(newExpandedKeys);
  }

  void expandAll() => expandKeys(displayItemKeys);

  void collapseAll() {
    if (expandedKeys.isEmpty) return;
    updateExpansionState(createEmptyKeySet());
  }

  void toggleExpandAll() {
    isAllExpanded ? collapseAll() : expandAll();
  }

  void updateExpansionState(LinkedHashSet<K> expandedKeys) {
    updateState(
      who: 'updateExpansionState',
      expandedKeys: expandedKeys,
    );
  }
}
