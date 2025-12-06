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

  /// The set of selected item keys.
  LinkedHashSet<K> get selectedKeys => value.selectedKeys;

  /// The list of selected items.
  List<T> get selectedItems => getItemsFromKeys(selectedKeys);

  /// Whether any items are selected.
  bool get hasSelection => selectedKeys.isNotEmpty;

  /// Whether multiple items are selected.
  bool get hasMultipleSelection => selectedKeys.length > 1;

  /// The number of selected items.
  int get selectedCount => selectedKeys.length;

  /// Whether all items are selected.
  bool get isAllSelected => value.displayItems.isNotEmpty && value.displayItems.length == selectedCount;

  /// Whether some (but not all) items are selected.
  bool get isSomeSelected => hasSelection && !isAllSelected;

  /// Tristate selection value (true/null/false).
  bool? get selectionTristate => isAllSelected
      ? true
      : isSomeSelected
          ? null
          : false;

  /// Human-readable selection information.
  String get selectionInfo {
    if (selectedCount == 0) return 'No items selected';
    if (selectedCount == 1) return '1 item selected';
    return '$selectedCount items selected';
  }

  bool isItemKeySelected(K key) => selectedKeys.contains(key);

  void toggleSelectionByKey(K key) {
    if (selectionMode == TSelectionMode.none) return;

    final isSelected = isItemKeySelected(key);
    isSelected ? deselectItemKey(key) : selectItemKey(key);
  }

  void selectItemKey(K key) {
    if (selectionMode == TSelectionMode.none) return;

    final newSelectedKeys = selectionMode == TSelectionMode.single ? LinkedHashSet<K>.from([key]) : LinkedHashSet<K>.from(selectedKeys)
      ..add(key);

    updateSelectionState(newSelectedKeys, who: 'selectItemKey');
  }

  void deselectItemKey(K key) {
    if (selectionMode == TSelectionMode.none) return;

    final newSelectedKeys = LinkedHashSet<K>.from(selectedKeys)..remove(key);
    updateSelectionState(newSelectedKeys, who: 'deselectItemKey');
  }

  void selectItemKeys(Iterable<K> keys) {
    if (selectionMode != TSelectionMode.multiple || keys.isEmpty) return;

    final newSelectedKeys = LinkedHashSet<K>.from(selectedKeys)..addAll(keys);
    updateSelectionState(newSelectedKeys, who: 'selectItemKeys');
  }

  void isItemSelected(T item) => isItemKeySelected(itemKey(item));

  void toggleSelection(T item) => toggleSelectionByKey(itemKey(item));

  void selectItem(T item) => selectItemKey(itemKey(item));

  void deselectItem(T item) => deselectItemKey(itemKey(item));

  void selectItems(Iterable<T> items) => selectItemKeys(items.map((item) => itemKey(item)));

  void selectAll() => selectItemKeys(listItemKeys);

  void clearSelection() {
    if (selectedKeys.isEmpty) return;
    updateSelectionState(LinkedHashSet<K>(), who: 'clearSelection');
  }

  void toggleSelectAll() {
    if (selectionMode != TSelectionMode.multiple) return;
    hasSelection ? clearSelection() : selectAll();
  }

  void updateSelectionState(LinkedHashSet<K> selectedKeys, {String who = ''}) {
    updateState(
      who: 'updateSelectionState $who',
      selectedKeys: selectedKeys,
    );
  }
}
