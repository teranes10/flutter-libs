part of 'list_controller.dart';

extension TListControllerSelection<T, K> on TListController<T, K> {
  bool get selectable => selectionMode != TSelectionMode.none;
  bool get isMultiSelect => selectionMode == TSelectionMode.multiple;
  LinkedHashSet<K> get selectedKeys => value.selectedKeys;
  List<T> get selectedItems => getItemsFromKeys(selectedKeys);
  bool get hasSelection => selectedKeys.isNotEmpty;
  bool get hasMultipleSelection => selectedKeys.length > 1;
  int get selectedCount => selectedKeys.length;
  bool get isAllSelected => value.displayItems.isNotEmpty && value.displayItems.length == selectedCount;
  bool get isSomeSelected => hasSelection && !isAllSelected;
  bool? get selectionTristate => isAllSelected
      ? true
      : isSomeSelected
          ? null
          : false;

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
