part of 'list_controller.dart';

/// Extension providing selection functionality for [TListController].
///
/// Enables single and multiple item selection with methods to:
/// - Select/deselect individual items
/// - Select/deselect all items
/// - Toggle selection states
/// - Query selection status
///
/// Example:
/// ```dart
/// // Select an item
/// controller.selectItem(product);
///
/// // Select multiple items
/// controller.selectItems([product1, product2]);
///
/// // Check selection
/// if (controller.hasSelection) {
///   print('Selected: ${controller.selectedCount}');
/// }
///
/// // Clear selection
/// controller.clearSelection();
/// ```
extension TListControllerSelection<T, K> on TListController<T, K> {
  /// Whether selection is enabled.
  bool get selectable => selectionMode != TSelectionMode.none;

  /// Whether multiple selection is enabled.
  bool get isMultiSelect => selectionMode == TSelectionMode.multiple;

  /// Whether any items are selected.
  bool get hasSelection => selectedKeys.isNotEmpty;


  /// Whether multiple items are selected.
  bool get hasMultipleSelection => selectedKeys.length > 1;

  /// The number of selected items.
  int get selectedCount => selectedKeys.length;

  /// Whether all items are selected.
  bool get isAllSelected =>
      value.displayItems.isNotEmpty && value.displayItems.length <= selectedCount && value.displayItems.every((i) => isSelected(i.key));

  /// Tristate selection value (true/null/false).
  bool? get selectionTristate => isAllSelected
      ? true
      : hasSelection
          ? null
          : false;

  /// Human-readable selection information.
  String get selectionInfo {
    if (selectedCount == 0) return 'No items selected';
    if (selectedCount == 1) return '1 item selected';
    return '$selectedCount items selected';
  }

  bool isSelected(K key) => selectedKeys.contains(key);

  void toggleSelection(K key) {
    if (selectionMode == TSelectionMode.none) return;

    isSelected(key) ? deselect(key) : select(key);
  }

  void select(K key) {
    if (selectionMode == TSelectionMode.none) return;

    final newSelectedKeys = selectionMode == TSelectionMode.single ? copyKeySet(<K>[key]) : copyKeySet(selectedKeys)
      ..add(key);

    updateState(selectedKeys: newSelectedKeys, who: 'selectKey');
  }

  void deselect(K key) {
    if (selectionMode == TSelectionMode.none) return;

    final newSelectedKeys = copyKeySet(selectedKeys)..remove(key);
    updateState(selectedKeys: newSelectedKeys, who: 'deselectKey');
  }

  void selectKeys(Iterable<K> keys) {
    if (selectionMode != TSelectionMode.multiple || keys.isEmpty) return;

    final newSelectedKeys = copyKeySet(selectedKeys)..addAll(keys);
    updateState(selectedKeys: newSelectedKeys, who: 'selectKeys');
  }

  void selectAll() => selectKeys(displayItemKeys);

  void clearSelection() {
    if (selectedKeys.isEmpty) return;
    updateState(selectedKeys: createEmptyKeySet(), who: 'clearSelection');
  }

  void toggleSelectAll() {
    if (selectionMode != TSelectionMode.multiple) return;
    hasSelection ? clearSelection() : selectAll();
  }

  /// Replaces the entire selected key set with [newSelectedKeys].
  ///
  /// Use this when you need to set selection state from an external source
  /// (e.g., syncing with a value notifier or external value).
  void updateSelectionState(LinkedHashSet<K> newSelectedKeys) {
    updateState(who: 'updateSelectionState', selectedKeys: newSelectedKeys);
  }
}
